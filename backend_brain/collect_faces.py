import cv2
import os
import time

# Initialize picam and AI
stream_url = "http://10.184.244.223:5000/video_feed"
print("Connecting to Smart Glasses Camera...")
cap = cv2.VideoCapture(stream_url)
cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
face_cascade = cv2.CascadeClassifier(cascade_path)

# Ask for the person's name
name = input("Enter the name of the person (e.g., SAGAR... ): ").lower()
folder_path = os.path.join("database", name)
os.makedirs(folder_path, exist_ok=True)

print(f"\n📷 Starting Director Mode. Follow the on-screen instructions!")
count = 0
last_capture_time = time.time()

while True:
    success, frame = cap.read()
    if not success:
        break

    # Flip the frame so it acts like a mirror (easier for the user to follow)
    frame = cv2.flip(frame, 1)
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    
    # Detect faces
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

    # --- THE DIRECTOR: Tell the user what to do ---
    instruction = ""
    if count < 20:
        instruction = "1/5: Look Straight at camera"
    elif count < 40:
        instruction = "2/5: Turn head slightly LEFT"
    elif count < 60:
        instruction = "3/5: Turn head slightly RIGHT"
    elif count < 80:
        instruction = "4/5: Look slightly UP and DOWN"
    else:
        instruction = "5/5: Make faces (Smile, Frown, Talk)"

    current_time = time.time()

    for (x, y, w, h) in faces:
        if w < 100 or h < 100:
            continue
        # Only take a photo every 0.2 seconds to give them time to move
        if current_time - last_capture_time > 0.2:
            count += 1
            last_capture_time = current_time
            
            # Crop and save
            face_img = gray[y:y+h, x:x+w]
            file_name = os.path.join(folder_path, f"{count}.jpg")
            cv2.imwrite(file_name, face_img)
        
        # Draw UI
        cv2.rectangle(frame, (x, y), (x+w, y+h), (0, 255, 255), 2)
        cv2.putText(frame, f"Captured: {count}/100", (x, y-10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 255), 2)

    # Put the instructions at the bottom of the screen
    cv2.putText(frame, instruction, (20, 450), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)

    cv2.imshow("Data Collector - Director Mode", frame)

    if count >= 100:
        print(f"✅ Successfully collected 100 perfect photos for {name}!")
        break
    
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()