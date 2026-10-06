# 🕶️ Smart Glasses AI

## Real-Time Facial Recognition and Navigation Assistant

Smart Glasses AI is an edge-computing computer vision system designed to act as a wearable visual assistant. The system captures live video through a Raspberry Pi camera, processes facial recognition and navigation logic on a local computer, and sends real-time alerts to a Flutter mobile application for text-to-speech feedback.

The project uses a distributed architecture to keep the wearable hardware lightweight, power-efficient, and practical for real-time use.

---

## ✨ Features

- Live video capture using a Raspberry Pi camera.
- MJPEG video streaming over a local Wi-Fi network.
- Real-time face detection using Haar Cascade Classifiers.
- Face recognition using the LBPH algorithm.
- Lighting normalization using histogram equalization.
- Unknown-person rejection using a strict recognition threshold.
- TCP socket communication between the processing computer and mobile application.
- Text-to-speech alerts through a Flutter application.
- Path-clearance detection using a configurable timeout.
- Audio cooldown logic to prevent repeated notifications.
- Edge processing without requiring cloud services or a GPU.

---

## 🏗️ System Architecture

The system is divided into three functional nodes:

```text
┌─────────────────────┐
│  Raspberry Pi       │
│  Camera Capture     │
│  "The Eyes"         │
└──────────┬──────────┘
           │ MJPEG stream over Wi-Fi
           ▼
┌─────────────────────┐
│  PC / Laptop        │
│  AI Processing      │
│  "The Brain"        │
└──────────┬──────────┘
           │ TCP socket alerts
           ▼
┌─────────────────────┐
│  Flutter Mobile App │
│  TTS Feedback       │
│  "The Voice"        │
└─────────────────────┘
```

### 1. The Eyes — Raspberry Pi

The Raspberry Pi is connected to a camera module and acts as the wearable visual sensor. It runs a lightweight Flask server that captures video using the camera hardware and broadcasts an MJPEG stream over the local network.

### 2. The Brain — Processing Computer

A PC or laptop receives the video stream and performs the computationally intensive tasks:

- Face detection.
- Face recognition.
- Image preprocessing.
- Recognition confidence evaluation.
- Navigation and path-clearance logic.
- TCP socket communication with the mobile application.

### 3. The Voice — Flutter Application

The Flutter application connects to the processing computer through Wi-Fi. It receives text-based alerts such as:

```text
Keerthana detected
Unknown person detected
Your path is clear
```

The application converts these messages into audio using text-to-speech functionality.

---

## 🔩 Hardware Requirements

| Component | Description |
|---|---|
| Raspberry Pi | Raspberry Pi 3 or Raspberry Pi 4 recommended |
| Camera | Raspberry Pi Camera Module v1 or v2 |
| MicroSD card | Required for Raspberry Pi OS |
| Processing computer | Windows, Linux, or macOS |
| Smartphone | Runs the Flutter application |
| Network | Mobile hotspot or local Wi-Fi router |

> All devices must be connected to the same local network.

---

## 💻 Software Requirements

### Raspberry Pi

- Raspberry Pi OS Legacy 64-bit.
- Python 3.
- OpenCV.
- Flask.
- V4L2-compatible camera support.

### Processing Computer

- Python 3.8 or newer recommended.
- OpenCV with contrib modules.
- NumPy.
- Flask.

### Mobile Application

- Flutter SDK.
- Android Studio or Visual Studio Code.
- A device or emulator with text-to-speech support.

---

## 📁 Project Structure

A typical processing-computer project structure looks like this:

```text
Smart_Glasses_Project/
├── glasses_brain.py
├── stream.py
├── requirements.txt
└── database/
    ├── SAGAR/
    │   ├── face_001.jpg
    │   ├── face_002.jpg
    │   └── ...
    └── person2/
        ├── face_001.jpg
        ├── face_002.jpg
        └── ...
```

The `database` directory contains face images organized into one folder per person.

For reliable training, use multiple images with variation in:

- Facial angle.
- Distance from the camera.
- Lighting conditions.
- Facial expression.
- Camera position.

---

# 🚀 Setup Guide

## Phase 1: Raspberry Pi Setup

### 1. Configure the Camera

SSH into the Raspberry Pi:

```bash
ssh pi@<RASPBERRY_PI_IP>
```

Open the Raspberry Pi configuration tool:

```bash
sudo raspi-config
```

Navigate to:

```text
Interface Options
└── Legacy Camera
    └── Enable
```

Reboot the Raspberry Pi:

```bash
sudo reboot
```

> This project was developed for Raspberry Pi OS Legacy with the older camera driver workflow. Camera behavior may differ on newer Raspberry Pi OS versions using the modern `libcamera` stack.

### 2. Verify Camera Detection

Run:

```bash
vcgencmd get_camera
```

Expected output:

```text
supported=1 detected=1
```

If the camera is not detected:

- Check the ribbon cable orientation.
- Reconnect the cable firmly.
- Confirm that Legacy Camera is enabled.
- Reboot the Raspberry Pi.
- Verify that the camera module is compatible with the selected OS.

### 3. Install Raspberry Pi Dependencies

```bash
sudo apt update
sudo apt install python3-opencv python3-flask -y
```

### 4. Start the Video Stream

Copy `stream.py` to the Raspberry Pi and run:

```bash
python3 stream.py
```

The stream should be available at:

```text
http://<RASPBERRY_PI_IP>:5000
```

Use the Raspberry Pi's actual local IP address instead of `<RASPBERRY_PI_IP>`.

---

## Phase 2: Processing Computer Setup

### 1. Create a Virtual Environment

From the project directory:

```bash
python -m venv .venv
```

Activate it on Windows:

```powershell
.venv\Scripts\activate
```

Activate it on Linux or macOS:

```bash
source .venv/bin/activate
```

### 2. Install Dependencies

```bash
pip install opencv-contrib-python numpy flask
```

You can also create a `requirements.txt` file:

```text
opencv-contrib-python
numpy
flask
```

Then install the dependencies with:

```bash
pip install -r requirements.txt
```

### 3. Configure the Raspberry Pi Stream URL

In `glasses_brain.py`, update the stream URL:

```python
stream_url = "http://<RASPBERRY_PI_IP>:5000/video_feed"
```

Example:

```python
stream_url = "http://192.168.43.120:5000/video_feed"
```

The exact URL depends on the endpoint implemented in `stream.py`.

### 4. Start the AI Processing Script

```bash
python glasses_brain.py
```

The script should:

1. Connect to the Raspberry Pi stream.
2. Read incoming video frames.
3. Detect faces.
4. Normalize the detected face region.
5. Identify known or unknown people.
6. Send alerts to the Flutter application.
7. Display the processed video feed.

---

## Phase 3: Flutter Application Setup

### 1. Install Flutter Dependencies

From the Flutter application directory:

```bash
flutter pub get
```

### 2. Configure the Processing Computer IP

Update the Flutter application with the local IP address of the processing computer.

The mobile phone and processing computer must be connected to the same Wi-Fi network.

### 3. Connect to the Brain

The application connects to the processing computer through TCP port `8555`:

```text
PC_IP_ADDRESS:8555
```

Example:

```text
192.168.43.100:8555
```

### 4. Run the Application

```bash
flutter run
```

The application listens for messages and converts them into speech.

---

# ▶️ System Startup Sequence

Follow this order when starting the complete system:

### 1. Connect all devices

Connect the following devices to the same hotspot or Wi-Fi router:

- Raspberry Pi.
- Processing PC or laptop.
- Mobile phone.

### 2. Start the Raspberry Pi stream

```bash
python3 stream.py
```

### 3. Start the processing computer

```bash
python glasses_brain.py
```

### 4. Start the Flutter application

```bash
flutter run
```

### 5. Verify communication

Confirm that:

- The processing computer receives the video.
- Faces are detected in the video window.
- The Flutter application connects to port `8555`.
- Audio alerts are generated correctly.

---

# 🧠 Machine Learning Pipeline

The system uses a classical computer vision pipeline rather than a deep learning model. This approach reduces computational requirements and allows the system to run on a local computer without a dedicated GPU.

## 1. Face Detection — Haar Cascade

The Haar Cascade Classifier detects faces in each video frame.

It searches for visual patterns commonly found in human faces, such as:

- Eye regions.
- Nose bridges.
- Cheek regions.
- Contrast differences between facial features.

The detector returns a bounding box around each detected face. The background is removed, and only the face region is passed to the recognition model.

Typical detection parameters include:

- `scaleFactor`.
- `minNeighbors`.
- Minimum face size.

A higher `minNeighbors` value can reduce false positives but may also make detection less sensitive.

## 2. Lighting Normalization — Histogram Equalization

Lighting changes can significantly affect face recognition. A face captured under a bright light may have very different pixel values from the same face captured in a dark room.

The system applies histogram equalization using:

```python
cv2.equalizeHist()
```

This preprocessing step is applied consistently to:

- Training images.
- Live face regions.

The goal is to reduce the influence of shadows and improve recognition consistency.

## 3. Face Recognition — LBPH

The system uses the Local Binary Patterns Histograms recognizer.

LBPH works by:

1. Dividing the face image into local regions.
2. Comparing each pixel with neighboring pixels.
3. Generating local binary patterns.
4. Creating histograms from those patterns.
5. Comparing the live face with the stored training faces.

The recognizer returns a distance or confidence score. Lower distances generally indicate a closer match.

> The score is not a universal probability. The threshold must be calibrated using the project's camera, lighting, training images, and environment.

---

# 🛡️ Recognition and Safety Logic

## Unknown-Person Threshold

LBPH is a best-match algorithm, meaning it may return the closest known person even when the face belongs to a stranger.

To reduce false identifications, the system applies a strict threshold:

```python
if confidence < 40:
    identity = predicted_name
else:
    identity = "Unknown"
```

The value `40` is an initial project-specific threshold and should be calibrated experimentally.

For safety-critical use, the system should prefer reporting `Unknown` rather than confidently announcing an incorrect identity.

## Path-Clearance Timer

The system tracks whether faces or obstacles are present in the current visual field.

If no face is detected for a configured period, the system sends a path-clearance message:

```text
Your path is clear, you can move
```

The current project behavior uses a timeout of approximately four seconds.

## Audio Cooldown

Without a cooldown, the system could send the same alert repeatedly at video frame rate.

A communication cooldown of approximately five seconds is used to:

- Prevent repeated speech.
- Reduce socket traffic.
- Avoid overwhelming the Flutter text-to-speech queue.
- Improve the user experience.

---

# 🐛 Engineering Challenges and Solutions

## 1. MJPEG Boundary Desynchronization

### Problem

The video stream occasionally failed with an error similar to:

```text
Expected boundary '--' not found
```

This can occur when network instability causes the stream reader to lose synchronization with the MJPEG frame boundary.

### Solution

The processing pipeline was improved by:

- Limiting the OpenCV capture buffer.
- Dropping delayed frames instead of processing stale frames.
- Adding a non-blocking socket timeout.
- Preventing mobile-network interruptions from freezing the AI loop.

Example optimization:

```python
cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
```

The exact effectiveness of this property may depend on the OpenCV backend and operating system.

## 2. Lighting and Shadow Overconfidence

### Problem

The recognizer sometimes matched an unknown person to a known identity because of lighting and shadows.

### Solution

Histogram equalization was applied to both:

- Training images.
- Live face regions.

This improves consistency between the stored database and live camera frames.

## 3. Incorrect Unknown Classification

### Problem

LBPH always attempts to return its closest known match.

### Solution

A strict distance threshold was added:

```python
if confidence < THRESHOLD:
    return predicted_name
return "Unknown"
```

The threshold should be validated using both known-person and unknown-person test images.

## 4. Double-Crop Training Bug

### Problem

The training pipeline attempted to run Haar Cascade detection on images that had already been cropped to the face region.

Because the images no longer contained the expected full-face context, the detector sometimes failed and silently discarded valid training samples.

### Solution

The training pipeline was changed to:

- Treat already-cropped images as valid face inputs.
- Avoid running a second face-detection step on those images.
- Append the normalized face arrays directly to the LBPH training dataset.

## 5. Raspberry Pi Camera Driver Conflicts

### Problem

The camera was not detected correctly after changing the operating system or camera stack.

### Solution

The project used:

- Raspberry Pi OS Legacy 64-bit.
- Legacy Camera configuration.
- Native camera access through the V4L2-compatible workflow.
- OpenCV capture through the supported camera interface.

> Camera support depends on the Raspberry Pi model, OS version, camera module, and driver configuration. Verify the setup on the actual hardware before deployment.

---

# 🧪 Testing Checklist

## Raspberry Pi

- [ ] Camera ribbon cable is connected correctly.
- [ ] Camera is detected by the operating system.
- [ ] `stream.py` starts without errors.
- [ ] The MJPEG stream opens in a browser.
- [ ] The Raspberry Pi and PC are on the same network.

## Processing Computer

- [ ] Python dependencies are installed.
- [ ] The Raspberry Pi IP address is correct.
- [ ] The face database contains valid images.
- [ ] Known faces are detected and identified.
- [ ] Unknown faces are rejected.
- [ ] The processing window remains responsive.
- [ ] The socket server starts on port `8555`.

## Flutter Application

- [ ] The PC IP address is configured correctly.
- [ ] The application connects to port `8555`.
- [ ] Incoming messages are displayed or logged.
- [ ] Text-to-speech works.
- [ ] Repeated alerts are suppressed by the cooldown.

---

# 🔐 Privacy and Security

This project processes facial images and identity information. Use it responsibly.

Recommended practices:

- Obtain consent before collecting or storing anyone's face images.
- Do not commit private face databases to a public repository.
- Do not store passwords, API keys, or private network credentials in source code.
- Keep `.env` files and private configuration files out of Git.
- Use a private repository for sensitive training data.
- Delete face images that are no longer required.
- Clearly inform users when facial recognition is active.
- Do not rely on this prototype as the sole system for safety-critical navigation.

---

# ⚠️ Limitations

- Recognition accuracy depends heavily on lighting and camera quality.
- LBPH performance may decrease with significant changes in pose or distance.
- The system requires all devices to be connected to the same local network.
- Network interruptions can affect video streaming and alert delivery.
- The current path-clearance logic is not a complete obstacle-detection system.
- A face detector does not identify every physical obstacle.
- Threshold values require calibration for each environment.
- Raspberry Pi camera support may differ between Legacy and modern camera stacks.
- The system is a research and prototype platform, not a certified assistive device.

---

# 🔮 Future Improvements

- Add object and obstacle detection using a lightweight neural network.
- Add depth sensing or ultrasonic distance measurement.
- Replace raw TCP messages with a structured protocol such as JSON.
- Add automatic device discovery instead of manually entering IP addresses.
- Add encrypted communication between nodes.
- Use a more robust face-embedding model for recognition.
- Add offline voice prompts on the processing computer.
- Add battery monitoring for the wearable hardware.
- Add automatic reconnection after network failure.
- Add unit tests and integration tests.
- Add configurable thresholds through a settings file.
- Store event logs without storing unnecessary biometric data.
- Add support for newer Raspberry Pi camera stacks.


This project combines:

- Raspberry Pi camera streaming.
- Flask networking.
- OpenCV computer vision.
- Haar Cascade face detection.
- LBPH face recognition.
- Python socket programming.
- Flutter mobile development.
- Text-to-speech interaction.

If this project helps you, consider giving the repository a star and opening an issue with suggestions or improvements.
