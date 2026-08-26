# GaragemVendas-db

> 🇧🇷 **Leia este README em Português:** [README_PT.md](./README_PT.md)

**🚗 Garage Sales & Inventory Management System**

A robust relational database system designed for managing automotive inventory and sales operations using PostgreSQL. The project applies core database engineering principles to ensure data integrity, role-based security, and operational automation.

---

## 🎯 Project Objective

Demonstrate practical SQL proficiency in a real-world business scenario, covering everything from 3NF data normalization to stored procedures, triggers, RBAC security, and analytical queries.

---

## 🛠️ Tech Stack

* **Database Engine:** PostgreSQL
* **Database Management Tool:** DBeaver
* **Query Language:** SQL (ANSI/ISO) & PL/pgSQL

---

## 🏗️ Data Modeling & Architecture (DDL)

The database schema strictly adheres to the **3rd Normal Form (3NF)** to eliminate data redundancy and prevent update anomalies:

* **Normalization:** Logical separation into dedicated entities (`cars`, `brands`, `customers`, `vehicle_status`, and `sales`).
* **Hierarchical Structure:** Implemented a `self-join` relationship on the `employees` table to handle organizational hierarchies (managers and subordinates) within a single entity.
* **Performance Optimization:** B-Tree indexing applied to the `model` column to optimize text-search queries across large datasets.

---

## 🚀 Technical Highlights & Features

### 1. Automated Auditing (Triggers & Procedures)
Implemented the `trg_auditoria_preco` trigger for real-time audit logging. Any vehicle price modification automatically records the previous price, updated price, timestamp, and user ID into an audit log table.

### 2. Transaction Safety (ACID Compliance)
Developed the `sp_registrar_venda_segura` stored procedure to enforce strict atomicity. Sales registration and inventory status updates execute as a single unit of work—rolling back entirely in case of failure to prevent financial or inventory discrepancies.

### 3. Security & Access Control (DCL / RBAC)
Configured **Role-Based Access Control (RBAC)** to enforce the principle of least privilege:
* **Sales Role:** Restricted permissions limited to querying available inventory and inserting new sales records.
* **Manager Role:** Full administrative privileges, including record deletion and audit log inspection.

### 4. Advanced Analytics (DQL & Views)
* **Common Table Expressions (CTEs):** Utilized CTEs for complex revenue reports, calculating total sales share per brand with high query readability.
* **Database Views:** Created reusable views (such as `vw_estoque_disponivel`) to abstract complex joins for daily operational reporting.

---

## 📂 Getting Started

1. Ensure **PostgreSQL** is installed and running on your environment.
2. Clone this repository:
   ```bash
   git clone [https://github.com/MatheusKoppN/GaragemVendas-db.git](https://github.com/MatheusKoppN/GaragemVendas-db.git)


3. Execute the `VendaDeCarros.sql` script via your preferred database client (e.g., DBeaver, `psql`).


4. The script includes seed data for immediate testing (brands, vehicles, and initial employee records).



---

## 👨‍💻 Author

**Matheus Kopp do Nascimento**

*Software & Data Engineering Student | Electrical Engineering Student*

* **LinkedIn:** [linkedin.com/in/matheus-kopp-do-nascimento-426a783b5](https://www.linkedin.com/in/matheus-kopp-do-nascimento-426a783b5/)

* **Email:** matheuskoppn@gmail.com
