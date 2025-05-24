# 🏨 Hotel Management System (Advanced Database Project)

Welcome to the **Hotel Management System** project!  
This project is part of an **Advanced Database Programming and Administration** course. It demonstrates advanced SQL programming and design techniques using **PostgreSQL**, including:

- DDL & DML operations
- Triggers
- Procedures and functions (with cursors and exception handling)
- Window functions
- Auditing and package-based control
- Complete ER/UML modeling and normalization

---

## 👨‍💻 Developer Info

**Name:** Igizeneza Serge Benit  
**Student ID:** 27311  
**Group     :** monday
**Email:** [hacksergeb@gmail.com](mailto:hacksergeb@gmail.com)

---

## 📌 Project Overview

This system is built to manage hotel-related data and operations such as bookings, payments, staff, services, and more. It is structured to enforce data integrity, normalization, and advanced audit mechanisms.

---

## 🧩 ER Model Summary

### 📄 Entities & Attributes

- **Hotels** (`hotel_id` PK, `name`, `address`, `star_rating`, etc.)
- **Staff** (`staff_id` PK, `hotel_id` FK, `name`, `position`, etc.)
- **Room_Types** (`room_type_id` PK, `hotel_id` FK, `type_name`, `base_price`, `capacity`)
- **Rooms** (`room_id` PK, `hotel_id` FK, `room_type_id` FK, `room_number`, `status`)
- **Guests** (`guest_id` PK, `name`, `email`, `phone`, etc.)
- **Reservations** (`reservation_id` PK, `guest_id` FK, `hotel_id` FK, `check_in_date`, `check_out_date`, `status`)
- **Reservation_Details** (`reservation_detail_id` PK, `reservation_id` FK, `room_id` FK, `adults`, `children`)
- **Services** (`service_id` PK, `hotel_id` FK, `name`, `price`, `category`)
- **Service_Bookings** (`service_booking_id` PK, `reservation_id` FK, `service_id` FK, `date`, `status`)
- **Payments** (`payment_id` PK, `reservation_id` FK, `amount`, `method`, `status`)

### 🔗 Key Relationships

- **One-to-Many**:
  - Hotel → Staff, Room_Types, Rooms, Services
  - Guest → Reservations
  - Reservation → Reservation_Details, Service_Bookings, Payments

- **Many-to-Many (via junction tables)**:
  - Reservation ↔ Rooms (via `Reservation_Details`)
  - Reservation ↔ Services (via `Service_Bookings`)

### 🛡️ Constraints

- **PK/FK**: All relationships enforced via foreign keys.
- **NOT NULL**: Required on critical fields (e.g., `hotel_id`, `guest_id`).
- **UNIQUE**: Email, phone (Guests, Hotels); `room_number` per hotel.
- **CHECK**:
  - `star_rating` (must be between 1–5)
  - Valid status values (e.g., `"Available"`, `"Occupied"` for Rooms)
- **DEFAULT**: `CURRENT_DATE` for booking and registration dates.

### ✅ Normalization (3NF)

- No redundant data (e.g., pricing is only in `Room_Types`)
- All non-key attributes depend solely on the primary key
- Ensures scalability and integrity of the database

---

## 📁 Project Artifacts & Features

### 🧠 UML Diagram

Visualizes the system from an object-oriented perspective.  
📷 **UML Image:** *(Coming soon)*
![ER Diagram](https://github.com/Sergeb250/27311-Hotel-Management/blob/b2a24d50f7f2c12d9402cb8e9c412dee820fab18/screenshots/uml.png)

---

### 📌 Entity Relationship (ER) Diagram

📷 **ER Diagram:**  
![ER Diagram](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/ERdiagram.png)

---

### 🔧 DDL & DML Operations

- Table creation, alteration, and constraints  
📷 **Images:**  
![Alter 1](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/alter%20(2).png)  
![Alter 2](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/alter.png)

---

### 📊 Windows Functions

📷 **Window Function Image:**  
![Window Function](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/WINDOW_fuction.png)

---

### 🔁 Procedures, Cursors & Exception Handling

📷 **Procedure Images:**  
![Cursor 1](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/cursor.png)  
![Cursor 2](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/cursor%20(2).png)  
![Fetch Cursor](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/fetch%20cursor.png)  
![Cursor Result](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/cursorresult.png)

---

### 🛡️ Advanced Database Auditing & Packages

📷 **Auditing Package Images:**  
![Package 1](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/package.png)  
![Package 2](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/package2.png)  
![Package Result](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/package%20result.png)

---

### ➕ Insert Operation

📷 **Insert Example:**  
![Insert](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/insert.png)

---

### 🔍 Select Operation

📷 **Select Results:**  
![Select](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/select.png)  
![Guests](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/guests.png)

---

### ❌ Delete Operation

📷 **Delete Example:**  
![Delete](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/delete.png)

---

### 📊 Tables Snapshot

📷 **Tables View:**  
![Tables](https://github.com/Sergeb250/27311-Hotel-Management/blob/f88116eaa72460798829728bd7fd2c51c7880252/screenshots/Screenshot%202025-05-24%20213614.png)

---

## ✅ Conclusion

This project showcases a full database system implementation with proper normalization, constraints, and enterprise features like procedures and audit control. It is a solid base for real-world hotel management systems or academic demonstration.

---

## 📎 License

This project is licensed for academic purposes only. For any commercial use, contact the developer.

