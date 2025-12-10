📱 Contacts App – iOS

A modern, feature-rich contacts management application built with SwiftUI and MVVM architecture.

✨ Features

Core Functionality
	•	✅ Create, edit, and delete contacts
	•	✅ Add profile photo (Camera / Photo Library)
	•	✅ Sync with iOS native Contacts app
	•	✅ Real-time smart search
	•	✅ Alphabetical grouping
	•	✅ Swipe actions (edit/delete)
	•	✅ Profile detail view with edit toggle
	•	✅ Phone badge for device-synced contacts

Advanced Features
	•	🎨 Dominant shadow color extraction based on profile image
	•	🎬 Lottie animations for success states
	•	📊 Offline-first approach via SwiftData
	•	🔄 Auto sync with backend API
	•	🔍 Search history with persistence
	•	📱 Responsive & adaptive layout
	•	🖼️ Image compression and optimized caching

⸻

🏗️ Architecture

Folder Structure (MVVM)

Nexoft-TestCase
│
├── Models
│   └── Contact.swift
│
├── Views
│   ├── ContactsRootView.swift
│   ├── NewContactView.swift
│   ├── EditContactView.swift
│   └── Components/
│
├── ViewModels
│   ├── ContactsViewModel.swift
│   ├── NewContactViewModel.swift
│   └── EditContactViewModel.swift
│
├── Manager
│   ├── API/
│   └── LocalDB/
│
└── Resources
    └── Lottie, Assets, Extensions

Design Principles
	•	SOLID
	•	DRY
	•	KISS
	•	Clean separation of concerns
	•	Reusable UI components and extensions

⸻

🚀 Tech Stack

Category	Technology
UI Framework	SwiftUI
Architecture	MVVM
Database	SwiftData
Networking	URLSession + async/await
Animations	Lottie
Contacts	CNContactStore


⸻

📸 Screenshots

Screenshots & demo videos are included in Google Drive and delivered via email due to file size constraints.

⸻

🎯 Key Implementations

1. Dominant Color Shadow

2. Swipe Actions
	•	Edit → opens EditContactView
	•	Delete → confirmation dialog + animation
	•	Smooth spring animations & haptic feedback

3. Search History
	•	Persistent storage (UserDefaults)
	•	Tap to re-search
	•	Clear-all and remove-single-item actions

4. Phone Integration
	•	Detects if contact exists in device
	•	Save to device using CNMutableContact
	•	Permission handling for Contacts usage

⸻

🔧 Installation

Prerequisites
	•	Xcode 15+
	•	iOS 18+
	•	Swift 5.9+

Setup Steps

git clone https://github.com/yourusername/nexoft-testcase.git
cd nexoft-testcase
open Nexoft-TestCase.xcodeproj

Update API Base URL (if needed)

Manager / API / APIEnvironment.swift

static let baseURL = "http://146.59.52.68:11235/"


⸻

🌐 API Integration

Base URL

http://146.59.52.68:11235/

Endpoints

Method	Endpoint	Description
GET	/users	Fetch all contacts
POST	/users	Create contact
PUT	/users/:id	Update contact
DELETE	/users/:id	Delete contact
POST	/upload	Upload profile image


⸻

📝 Usage Guide

Creating a Contact
	1.	Tap the + button
	2.	Enter name, surname, phone
	3.	Add photo (optional)
	4.	Tap Done

Editing
	•	Tap contact → menu → Edit
OR
	•	Swipe left → Edit button

Deleting
	•	Swipe left → Delete
OR
	•	Open contact → menu → Delete

Saving to iOS Contacts
	•	Open contact → Save to My Phone Contact
	•	Grant permission if first time

⸻

🎨 UI/UX Highlights
	•	Empty states with illustrations
	•	“No results” messages
	•	Smooth loading progress
	•	Success toasts
	•	Delete confirmation dialog
	•	Seamless view/edit toggle
	•	Automatic keyboard dismissal

⸻

🧪 Testing Checklist
	•	Create/edit/delete contact
	•	Minimal contact creation
	•	Search by name or phone
	•	Search history persistence
	•	Swipe actions smooth
	•	Device contacts sync

⸻

🐛 Known Issues
	•	Image upload depends on stable network
	•	Contacts permission required
	•	Search is substring-based only (not fuzzy search)

⸻

🔮 Future Enhancements
	•	Dark mode
	•	Favorites / groups
	•	Call & message actions
	•	QR code share
	•	Duplicate detection
	•	iCloud sync

👤 Author

Talha Batuhan Irmalı
iOS Developer

🔗 GitHub:
https://github.com/Batuhanirmali

🔗 LinkedIn:
[https://www.linkedin.com/in/batuhanirmali/](https://www.linkedin.com/in/talhabatuhanirmali/)

⸻

📄 License

This project was developed as a technical assessment for Nexoft.
All rights reserved.

⸻

📌 Note

Screenshots and UI demonstration videos are provided via Google Drive link and also delivered through email due to file size constraints.
