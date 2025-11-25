# 💰 InvestmentTracker

## 📘 Project Description

**InvestmentTracker** is a personal finance tracking web application built with **Flutter (for Web)** on the frontend and a **Node.js + PostgreSQL** backend.  
It’s inspired by finance apps and designed to help users **manage finances**, **track expenses**, **set budgets**, and **visualize goals**.

The app includes a complete **Guest Mode** for instant use for an interactive experience.  
The full version includes **secure user authentication**, **transaction management**, **budget creation**, and **goal tracking**, all connected to a live backend API.

---

## 📑 Table of Contents

* [Motivation](#-motivation)
* [Tech Stack](#-tech-stack)
* [Features](#-features)
* [Installation](#-installation)
* [Running the Project](#️-running-the-project)
* [How to Use](#-how-to-use)
* [What I Learned](#-what-i-learned)
* [Project Highlights](#-project-highlights)

---

## 💡 Motivation

* I wanted to learn **full-stack development** by building a complete, real-world project from scratch.  
* My goal was to understand how the **frontend, backend, and database** connect to create a dynamic, data-driven app.  
* I was motivated to implement **secure authentication** and manage **user-specific data** effectively.  

---


## 🛠 Tech Stack

* **Frontend:** Flutter (Web), Dart  
* **Backend:** Node.js, Express.js, bcryptjs, jsonwebtoken  
* **Database:** PostgreSQL  
* **UI / Charts:** fl_chart (Pie + Line charts)  
* **State Management:** StatefulWidget + setState (local state)  
* **Secure Storage:** flutter_secure_storage  
* **API Client:** http package  

---

## 🌟 Features

* 🧑‍💻 **Guest Mode:** Interactive "guest" version.  
* 🔐 **Secure Authentication:** Signup and login using **bcryptjs** for password hashing and **JWT** for secure sessions.  
* 💸 **Transaction Tracking:** Log expenses and income per user, stored in the database.  
* 🎯 **Budget & Goal Setting:** Create and manage personal budgets and financial goals.  
* 📊 **Interactive Dashboard:**  
  * Summary cards for **Net Worth**, **Income**, and **Expenses**  
  * Animated **pie chart** for expense summaries  
  * Dynamic **line chart** for investment performance  
* 👆 **Smooth Navigation:** PageView for horizontal swiping between screens.  
* 💻 **Responsive Layout:** Works seamlessly on browsers (Flutter Web).  

---

## 💻 Installation

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/investortrack.git
```
2. **Navigate to each folder and install dependencies**

* Backend:

```
cd InvestorTrack-Backend
npm install
```
* Frontend:
```
cd investortrack_web
flutter pub get
```

3.**Set up environment variables**

* Create a .env file inside the InvestorTrack-Backend folder with:
```
DB_USER=your_postgres_username
DB_HOST=localhost
DB_DATABASE=InvestorTrack
DB_PASSWORD=your_postgres_password
DB_PORT=5432
JWT_SECRET=your_secret_key_for_tokens
```

## ▶️ Running the Project

**Open two terminals — one for backend, one for frontend.**

* 1️⃣ Start Backend
```
cd InvestorTrack-Backend
npm run dev
```

* 2️⃣ Start Frontend
```
cd investortrack_web
flutter run -d chrome
```

## 🌐 Access the app:

* Frontend UI: http://localhost
* :<flutter_port> (e.g. http://localhost:57364)

* Backend API: http://localhost:3000

## 🧪 How to Use

* Swipe left/right to navigate between:
* Dashboard

* Transactions

* Budgets

* Goals

* Use the “+” button to add new transactions, budgets, or goals (saved locally in guest mode).

* Click “Login / Sign Up” in the top-right corner to switch to the real version.

* Create an account (saved in PostgreSQL).

* Login to access your personal dashboard connected to the backend API.

## 📚 What I Learned

* Connecting a Flutter frontend to a Node.js backend via REST APIs.

* Implementing secure authentication with bcryptjs and JWT.

* Managing data persistence using PostgreSQL and the pg library.

* Building both mock-data (guest) and live-data (authenticated) modes.

* Creating interactive UIs in Flutter using fl_chart and responsive layouts.

* Managing state locally with setState and persistent storage using flutter_secure_storage.

* Debugging full-stack communication between Dart and Node.js.

## 🚀 Project Highlights

* 🏗️ My first complete full-stack project built entirely from scratch.

* 🧠 Learned the data flow and separation of concerns in modern full-stack architecture.

* ⚡ Implemented local and remote state management.

* 📈 Integrated charts, authentication, and REST APIs in a single cohesive system.
