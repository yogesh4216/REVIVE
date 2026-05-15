# Revive: Edge-AI CPR Coach & Emergency Assistant
**Gemma 4 Impact Challenge Submission**

Revive is a life-saving, fully local mobile application designed to guide users through emergency CPR procedures. By integrating on-device sensor data with the Gemma 4 model, Revive provides a critical bridge between bystander intervention and professional medical protocols during out-of-hospital cardiac arrests.

---

## Key Features

### Hands-Free AI Assistant
Revive features a voice-activated assistant powered by Gemma 4. Utilizing a continuous listening loop with noise-cancellation logic, the system allows users to receive immediate, medically accurate guidance without interrupting life-saving chest compressions.

### Voice-Activated Emergency Dialing
In a crisis, manual dialing can cost precious seconds. Revive monitors for emergency keywords such as "Call 911" or "Ambulance." Upon detection, the application automatically initiates a direct call to emergency services hands-free.

### Real-Time Sensor Fusion
The application processes smartphone accelerometer data at 50Hz to provide real-time feedback:
*   Compression Tracking: Accurately counts every compression with zero latency.
*   Rhythm Analysis: Monitors compression frequency against the 110 BPM clinical target.
*   Visual Feedback: A professional-grade BPM monitor coaches the rescuer to maintain the optimal 100-120 BPM range.

### Local-First Frontier Intelligence
Revive operates independently of cloud connectivity by running the Gemma 4 model locally via an Ollama tunnel. This architecture ensures:
*   High-Performance Inference: Optimized processing paths for rapid response times.
*   Data Privacy: All medical interaction data remains strictly local to the device.
*   Operational Resilience: Reliable performance in disaster zones or areas without cellular coverage.

---

## Technical Architecture

*   Framework: Flutter (Dart) utilizing StreamBuilder for reactive, high-performance UI updates.
*   Sensors: high-frequency motion tracking via the sensors_plus package.
*   AI Engine: Gemma 4 running locally through the Ollama framework.
*   Voice Pipeline: Continuous Speech-to-Text (STT) and Text-to-Speech (TTS) with an integrated header-based status interface.
*   Lifecycle Management: Advanced resource handling via WidgetsBindingObserver for system stability.

---

## Model Selection: Gemma 4

The Gemma 4 model was selected as the core intelligence engine for several strategic reasons:
*   Medical Accuracy: Gemma 4 demonstrates superior capability in following complex system prompts and delivering concise, actionable medical advice.
*   Efficiency: The model architecture provides an ideal balance of intelligence and inference speed on consumer-grade hardware.
*   User Experience: The model is specifically tuned to maintain a calm and professional tone, which is vital for managing user stress during emergencies.

---

## Installation and Setup

### Server Configuration (Ollama)
1. Install Ollama from the official website.
2. Download the model using the command: `ollama pull gemma4:latest`.
3. Establish a secure tunnel: `ngrok http 11434`.
4. Update the service endpoint in the application configuration.

### Mobile Application Deployment
1. Ensure Flutter (version 3.10 or higher) is installed.
2. Connect a physical Android device for sensor testing.
3. Deploy using the command: `flutter run`.

---

**Every Second Counts. Every Life Matters.**


