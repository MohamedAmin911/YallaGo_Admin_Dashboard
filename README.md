YallaGo - Admin Dashboard

![1](assets/images/logo5.png)


This is the central command and control center for the YallaGo ride-hailing platform. This web-based admin dashboard is a full-stack application designed for platform owners to manage drivers, monitor trips, and ensure the safety and efficiency of the entire ecosystem. It interacts in real-time with the same Firebase backend as the customer and driver mobile apps.


![2](assets/admin.mp4)


✨ Features
The admin dashboard provides a comprehensive suite of tools for platform management.

🔑 Driver Management
Verification Queue: View a real-time list of all newly registered drivers awaiting approval.

Detailed Driver Review: Click on any pending driver to view all their submitted information in one place, including:

Profile details (name, photo).

Vehicle details (model, license plate, photo).

Uploaded legal documents (Driver's License, National ID, etc.).

Approve & Reject: Securely approve or reject driver applications with a single click, which instantly updates their status in the database and unlocks the "Go Online" feature in their mobile app.

View All Drivers: See a full list of all registered drivers (pending, approved, and rejected).

🗺️ Real-Time Monitoring
Live Map: View the real-time GPS location of all online drivers moving on a live Google Map.

Trip Monitoring: See a live feed of all ongoing trips.


📊 Data Management
Customer List: View and search through a complete list of all registered customers.

Trip History: View and filter a complete history of all trips taken on the platform.


💰 Payouts & Finance (In Progress)
Driver Balances: View the current earnings balance for each driver.

Payout Management: The dashboard is designed to be the central place for initiating, approving and tracking driver payouts.


🛠️ Tech Stack & Architecture
This dashboard was built as a full-stack web application.

Frontend: (e.g., React, Angular, Vue, or plain HTML/CSS/JS)

Backend & Database: Firebase (Firestore for real-time data, Firebase Auth for admin login).

Mapping: Google Maps Platform (JavaScript SDK).


🚀 How to Run
To set up and run this project locally, you will need to:

Clone the repository:

```
git clone <https://gitlab.com/mohamed-amin-dev/YallaGo_Admin_Dashboard>
cd YallaGo-Admin-Dashboard
```


Set up Firebase:

Set up a new web app in your existing Firebase project.

Create a .env file in the root of the project and add your Firebase web app configuration keys.

Install dependencies and run:

```
npm install
npm start
```

---

## ⚖️ License & Usage

This project is licensed under a custom portfolio license. Please see the `LICENSE.md` file for full details.

-   **You ARE allowed to:** View, download, and run the code for personal, educational, and evaluation purposes.
-   **You are NOT allowed to:** Use this code for any commercial purpose, distribute it, or sell it.

This repository is intended to be a showcase of my skills and should be treated as such.

---

👤 Author
Mohamed Amin

LinkedIn: [linkedin.com/in/mohamed-amin-002849189/](url)

Email: mohamed.amin911911@gmail.com
