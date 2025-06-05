# govindalpha

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Step-by-Step Plan for Task Management App with Offline AI Sentiment Analysis

### Task 1: Offline Task Management App

1. **Project Setup**
   - [x] Initialize Flutter project (already done).
   - [x] Set up folder structure for modular code (e.g., `models`, `screens`, `services`, `db`).

2. **Task Data Model**
   - [x] Define a `Task` model with fields: `id`, `title`, `description`, `status`, `sentiment`.

3. **Local Database (SQLite)**
   - [x] Add `sqflite` and `path_provider` dependencies.
   - [x] Implement SQLite helper/service for CRUD operations.
   - [x] Create database schema for tasks.

4. **Task Management UI**
   - [x] Create screens for:
     - Task list (view all tasks)
     - Add/Edit task
     - Delete task
   - [x] Use state management (e.g., Provider, Riverpod, or Bloc).

5. **Offline Functionality**
   - [x] Ensure all CRUD operations work offline.
   - [x] Store changes locally when offline.

6. **Sync Logic (Mock Server)**
   - [x] Simulate online/offline mode toggle.
   - [x] Implement mock sync with a fake server (local JSON or in-memory).
   - [x] Handle conflict resolution (e.g., prompt user or use "last write wins").

### Task 2: Offline AI Sentiment Analysis

7. **Integrate TensorFlow Lite**
   - [x] Add `tflite_flutter` dependency.
   - [x] Download and add a pre-trained sentiment analysis model (from TensorFlow Hub).

8. **Sentiment Analysis Logic**
   - [x] Integrate the model and logic to analyze task descriptions and store the sentiment in the database.

9. **Display Sentiment**
   - [x] Display sentiment in the UI (with color coding).

### Task 3: APK Generation & Testing

10. **Build APK**
    - [ ] Generate APK for Android.

11. **Testing**
    - [ ] Test offline task management and sentiment analysis.
    - [ ] Test online mode and syncing.
    - [ ] Document testing steps in README.

---

**Progress Tracking:**
- [ ] = To Do
- [x] = Done
