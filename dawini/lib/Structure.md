# 📌 Project Structure( MVC Pattern)

This document outlines the project structure for the chatbot application using the **Model-View-Controller (MVC)** architecture. The MVC pattern helps maintain a clean separation of concerns and improve code organization and maintainability.

## 🏗️ MVC Architecture Overview

The **MVC (Model-View-Controller)** pattern divides the application into three main components:

- **🗄Model**: Manages the data, business logic, and API requests.
- **🖥 View**: Represents the user interface (Flutter pages) and displays data.
- **🕹 Controller**: Handles user interactions, updates models, and passes data to views.

---

## 📂 Project Folder Structure

<pre>
lib/
│
├── main.dart                          # 🚀 App entry point
│
├── role_selection_view.dart                   # 🔀 Page to choose between User or Doctor
│
├── theme/                             # 🎨 App-wide theme (colors, styles)
│   └── app_theme.dart
│
├── user/                              # 👤 User-side structure
│   ├── models/                        # 🗄 User data models
│   │   ├── chat_model.dart
│   │   ├── user_auth_model.dart
│   │   ├── user_cloud_model.dart
│   │   ├── chat_history_model.dart
│   │
│   ├── views/                         # 🎨 UI for user pages
│   │   ├── user_login_view.dart
│   │   ├── user_signup_view.dart
│   │   ├── user_home_view.dart
│   │   ├── user_profile_view.dart
│   │   ├── chat_view.dart
│   │   ├── chat_history_view.dart
│   │
│   ├── controllers/                   # 🕹 User logic/controllers
│   │   ├── user_auth_controller.dart
│   │   ├── user_cloud_controller.dart
│   │   ├── user_profile_controller.dart
│   │   ├── chat_controller.dart
│   │   ├── chat_history_controller.dart
│
├── doctor/                            # 🩺 Doctor-side structure
│   ├── models/                        # 🗄 Doctor data models
│   │   ├── doctor_auth_model.dart
│   │   ├── doctor_cloud_model.dart
│   │
│   ├── views/                         # 🎨 UI for doctor pages
│   │   ├── doctor_login_view.dart
│   │   ├── doctor_signup_view.dart
│   │   ├── doctor_profile_view.dart
│   │
│   ├── controllers/                   # 🕹 Doctor logic/controllers
│   │   ├── doctor_auth_controller.dart
│   │   ├── doctor_cloud_controller.dart
│   │   ├── doctor_profile_controller.dart

</pre>

##  How MVC Works in This Project

1. **View Layer** (`chat_view.dart`): The user interacts with the UI.
2. **Controller Layer** (`chat_controller.dart`): Handles user actions, processes data, and interacts with models.
3. **Model Layer** (`chat_model.dart`): Defines data structure, interacts with APIs, and processes business logic.
4. **View Updates** (`chat_view.dart`): Displays new or updated data to the user.

# Firestore Database Structure 🗄️

<pre>

doctors (Collection) 🗃️
│
├── doctorUID_X (Document)
│   ├── uid: "doctorUID_X" 🆔
│   ├── name: "د. …" 🏷️
│   ├── specialization: "التخصص" 🩻
│   ├── address: "العنوان التفصيلي" 📍
│   ├── city: "المدينة" 🏙️
│   ├── phone: "+20…" ☎️
│   ├── email: "doctor@example.com" 📧
│   ├── linkedinUrl: "https://…" 🔗
│   ├── facebookUrl: "https://…" 🔗
│   ├── latitude: 30.0444 🗺️
│   ├── longitude: 31.2357 🗺️
│   ├── starCount: 4.8 ⭐
│   └── patientReports (Subcollection)
│       ├── reportID_1 (Document)
│       │   ├── patientId: "userUID_1" 👤
│       │   ├── pdfUrl: "https://firebasestorage.googleapis.com/..." 📄
│       │   ├── sentAt: 2025-02-02T12:00:02Z ⏲️
│       ├── reportID_2 (Document)
│       │   ├── patientId: "userUID_2"
│       │   ├── pdfUrl: "https://..."
│       │   ├── sentAt: 2025-02-02T12:00:02Z ⏲️
|       └── …  
|
users (Collection) 🗃️
│
├── userUID_1 (Document)
│   ├── name: "User Name" 🏷️
│   ├── email: "user@example.com" 📧
|   |
|   └── medicalForms (Subcollection) 💊
│   │   ├── medicalForm_1 (Document)
│   │   │   ├── createdAt: Timestamp ⏲️
│   │   │   ├── report: "http://res.cloudinary.com/ds28kysew/image/upload/..." 📄
│   │   │   ├── العمر: "28"
│   │   │   ├── الوزن: "65"
│   │   │   ├── الطول: "165"
│   │   │   ├── الجنسية: "عربية"
│   │   │   ├── مكان الإقامة: "الخرطوم"
│   │   │   ├── الجنس: "أنثى"
│   │   │   ├── تفاصيل الحالة: "ضغط وسكر"
│   │   └── …
│   │
│   │
│   ├── chats (Subcollection)
│   │   ├── chatID_1 (Document)
│   │   │   ├── createdAt: Timestamp ⏳
│   │   │   ├── messages (Subcollection)
│   │   │   │   ├── messageID_1 (Document)
│   │   │   │   │   ├── text: "Hello, AI!" 💬
│   │   │   │   │   ├── timestamp: 2025-02-02T12:00:00Z ⏲️
│   │   │   │   │   ├── sender: "User" 👤
│   │   │   │   ├── messageID_2 (Document)
│   │   │   │   │   ├── text: "Hi! How can I assist?" 💬
│   │   │   │   │   ├── timestamp: 2025-02-02T12:00:02Z ⏲️
│   │   │   │   │   ├── sender: "AI" 🤖
│   │   ├── chatID_2 (Document)
│   │   │   ├── createdAt: Timestamp ⏳
│   │   │   ├── messages (Subcollection) ✉️
│   │   │   │   ├── messageID_1 (Document)
│   │   │   │   │   ├── text: "What is AI?" 💬
│   │   │   │   │   ├── timestamp: 2025-02-02T13:00:00Z ⏲️
│   │   │   │   │   ├── sender: "User" 👤
│   │   │   │   ├── messageID_2 (Document)
│   │   │   │   │   ├── text: "AI stands for Artificial Intelligence..." 💬
│   │   │   │   │   ├── timestamp: 2025-02-02T13:00:02Z ⏲️
│   │   │   │   │   ├── sender: "AI" 🤖
│   │   │   │   └── …  
│   │   │
│   │   └── …
│   └── …
</pre>