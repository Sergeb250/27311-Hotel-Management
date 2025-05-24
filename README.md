Hotel Management System – PL/SQL 

Phase 1: Problem Definition & Requirements

🔍 Problem Definition

Hotels often struggle with fragmented operations across bookings, guest services, room allocation, and billing. This lack of integration leads to manual data entry, increased chances of overbooking or billing errors, and inefficient service delivery.

💡 Solution Overview

This system offers an integrated hotel management solution built using Oracle PL/SQL to manage:

Real-time room availability & status tracking

Guest registration & reservation

Staff management

Additional services (e.g., spa, room service)

Centralized billing and payment tracking

Role-based access for hotel staff

🌟 Target Users

Hotel Managers (Full access)

Receptionists (Booking, guest check-in/check-out)

Accounting Staff (Billing & Payments)

Housekeeping Supervisors (Room status)

🗂️ Key Entities

Hotels: Hotel profile information

Guests: Personal and contact info

Staff: Roles, departments, and hotel linkage

Room Types & Rooms: Capacity, pricing, status

Reservations & Reservation Details

Services & Service Bookings

Payments

🏰 Anticipated Benefits

Centralized data for hotel operations

Faster guest check-in and service processing

Improved billing accuracy

Better room allocation and housekeeping coordination

Phase 2: Business Process Modeling (BPMN)

🌟 Scope & Objectives

The BPMN model represents the full guest lifecycle, from initial reservation to check-out and post-stay payment. The primary goals are:

Streamlined reservations and room assignments

Real-time coordination across departments

Automated billing and service integration

🧑‍🤝 Key Actors (Swimlanes)

Guest: Makes reservation, checks in/out

Receptionist: Creates and modifies reservations

System: Assigns rooms, logs actions, calculates totals

Housekeeping: Receives updates on room status

Accounts: Confirms payments, processes invoices

⟳ Logical Flow Summary

Guest makes a reservation

Receptionist assigns room(s) based on availability

System logs reservation and sends updates to housekeeping

Services booked are attached to the reservation

Guest checks out and payment is processed

✅ Process Highlights

Service booking generates charges automatically

Real-time room status updates

Trigger-driven notifications for late check-outs or unpaid balances

Phase 3: Logical Model Design

📃 Entity-Relationship (ER) Model

Normalized to 3NF, the following main tables are defined:

HOTELS: hotel_id, name, contact info, star_rating

STAFF: staff_id, hotel_id, name, role, department

ROOM_TYPES: room_type_id, type_name, base_price

ROOMS: room_id, room_number, floor, room_type_id

GUESTS: guest_id, full details, id_number

RESERVATIONS: reservation_id, guest_id, hotel_id, status

RESERVATION_DETAILS: room_id, adults, children

SERVICES: service_id, service_name, price, hotel_id

SERVICE_BOOKINGS: service_booking_id, reservation_id, quantity

PAYMENTS: payment_id, reservation_id, amount, method, status

🔗 Relationships & Constraints

ROOMS to ROOM_TYPES: Many-to-One

ROOMS to HOTELS: Many-to-One

STAFF to HOTELS: Many-to-One

RESERVATIONS to GUESTS and HOTELS: Many-to-One

RESERVATION_DETAILS to RESERVATIONS & ROOMS: Many-to-One

SERVICE_BOOKINGS to SERVICES & RESERVATIONS: Many-to-One

PAYMENTS to RESERVATIONS: Many-to-One

⚖️ Constraints Summary

Primary Keys on all IDs

Foreign Keys for inter-table dependencies

CHECK Constraints on status and values (e.g., star_rating, price > 0)

UNIQUE and NOT NULL constraints on critical columns (e.g., emails, room numbers)

⚛️ Normalization to 3NF

No repeating groups or multivalued fields (1NF)

Full functional dependency on PKs (2NF)

No transitive dependencies (3NF)

Phase 4: Database Creation and Naming

✅ Status

Due to Oracle XE limitations on the current local setup, full container database creation (CDB + PDB) was not possible. Therefore, all scripts are executed under a default XE schema for demonstration.

OEM Screenshots: Not available due to instance limitations. SQL scripts and schema details are provided for review.

Phase 5: DDL Scripting and Execution

⚒️ Execution Environment

DDL scripts were created and successfully executed using Oracle Live SQL.

Tables include:

Hotels, Staff, Room_Types, Rooms, Guests

Reservations, Reservation_Details, Services

Service_Bookings, Payments

All foreign keys, data types, and constraints are in place as per the logical model.

Phase 6: Database Interaction and Transactions

📊 Problem for Analysis

Goal: Track hotel revenue and occupancy per room type.

Identify the top 3 and bottom 3 room types based on revenue

Monitor room utilization per week/month

Analyze service usage by guests

🔧 Features Demonstrated

PL/SQL procedures to check availability, process bookings

Triggers to prevent double bookings

Exception handling for overlapping dates or invalid guests

Packages to bundle related operations (e.g., reservation + service booking)
