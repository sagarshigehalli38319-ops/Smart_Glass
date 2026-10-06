import cv2
import os
import numpy as np
import socket
import time

# --- 1. INITIALIZE OPENCV AI ---
cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
face_cascade = cv2.CascadeClassifier(cascade_path)
recognizer = cv2.face.LBPHFaceRecognizer_create()

# --- 2. LOAD DATABASE (With Lighting Equalizer Fix) ---
database_path = "database"
faces = []
labels = []
name_dictionary = {}
current_id = 0

print("\n========================================")
print("📂 Scanning database for known faces...")

for person_name in os.listdir(database_path):
    person_folder = os.path.join(database_path, person_name)
    if os.path.isdir(person_folder):
        name_dictionary[current_id] = person_name.upper()
        loaded_count = 0 
        
        for filename in os.listdir(person_folder):
            if filename.endswith((".jpg", ".png", ".jpeg")):
                filepath = os.path.join(person_folder, filename)
                img = cv2.imread(filepath, cv2.IMREAD_GRAYSCALE)
                
                if img is not None:
                    # THE FIX: Strip lighting/shadows from the training photo
                    equalized_img = cv2.equalizeHist(img)
                    faces.append(equalized_img)
                    labels.append(current_id)
                    loaded_count += 1
                    
        print(f"✅ Loaded {loaded_count} photos for {person_name.upper()} (ID: {current_id})")
        current_id += 1

if len(faces) > 0:
    print("\n🧠 Training the AI... Please wait...")
    recognizer.train(faces, np.array(labels))
    print("🚀 AI Training Complete!")
print("========================================\n")

# --- 3. SET UP THE WI-FI SOCKET SERVER ---
HOST = '0.0.0.0'
PORT = 8555

server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server_socket.bind((HOST, PORT))
server_socket.listen(1)

print("\n========================================")
print(f"📡 SERVER IS LIVE on Port {PORT}")
print(f"⏳ Type this IP into your Flutter app: 10.184.244.53")
print("========================================\n")

# The script stops here until your phone connects
client_socket, client_address = server_socket.accept()
client_socket.settimeout(0.5) # Prevents the phone from freezing the AI loop
print(f"✅ Phone Successfully Connected from {client_address}!")

# --- 4. CONNECT TO SMART GLASSES (RASPBERRY PI) ---
stream_url = "http://10.184.244.223:5000/video_feed"
print("Opening Camera Stream...")

cap = cv2.VideoCapture(stream_url)
cap.set(cv2.CAP_PROP_BUFFERSIZE, 1) # Stops MJPEG desync crashes

if not cap.isOpened():
    print("Error: Could not connect to the glasses.")
    exit()

# Memory variables
last_sent_name = None 
last_sent_time = 0 
last_face_time = time.time()
path_clear_announced = False

while True:
    success, frame = cap.read()
    if not success:
        continue

    gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    
    # minNeighbors=8 ignores false positives like fans/shadows
    detected_faces = face_cascade.detectMultiScale(gray_frame, scaleFactor=1.1, minNeighbors=8, minSize=(30,30))
    
    current_time = time.time()

    if len(detected_faces) > 0:
        path_clear_announced = False 
        last_face_time = current_time 
        
        for (x, y, w, h) in detected_faces:
            name = "Unknown" 
            color = (0, 0, 255) 
            
            if len(faces) > 0:
                # Isolate the face from the frame
                face_roi = gray_frame[y:y+h, x:x+w]
                
                # THE FIX: Strip lighting/shadows from the LIVE face
                face_roi = cv2.equalizeHist(face_roi)
                
                # Predict using the equalized face
                # Predict using the equalized face
                label_id, confidence = recognizer.predict(face_roi)
                raw_guess = name_dictionary.get(label_id, "Unknown")
                
                # THE ULTRA-STRICT THRESHOLD
                if confidence < 40: 
                    name = raw_guess
                    color = (0, 255, 0) 
                    print(f"✅ MATCH FOUND: {name} | Score: {confidence:.1f}")
                else:
                    print(f"❌ REJECTED: Looked like {raw_guess}, but score was too high ({confidence:.1f})")
            
            # --- THE FLICKER FIX (Hard Cooldown) ---
            # 5-second silence between ANY face alerts
            if (current_time - last_sent_time) >= 5.0:
                try:
                    print(f"🚀 Sending Alert to Phone: {name.capitalize()} detected!")
                    client_socket.sendall(name.encode('utf-8'))
                    last_sent_name = name
                    last_sent_time = current_time 
                except socket.timeout:
                    pass
                except Exception as e:
                    print("⚠️ Phone disconnected.")
                    break
            
            cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
            cv2.putText(frame, name.capitalize(), (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.75, color, 2)

    else:
        # --- NO FACES DETECTED ---
        if (current_time - last_face_time > 4.0) and not path_clear_announced:
            try:
                clear_msg = "Your path is clear, you can move"
                print(f"🟢 Sending Alert to Phone: {clear_msg}")
                client_socket.sendall(clear_msg.encode('utf-8'))
                
                path_clear_announced = True 
                last_sent_name = None 
                last_sent_time = 0 
                
            except socket.timeout:
                pass
            except Exception as e:
                print("⚠️ Phone disconnected.")
                break

    cv2.imshow("Smart Glasses Brain", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
client_socket.close()
server_socket.close()