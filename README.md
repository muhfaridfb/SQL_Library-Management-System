# SQL Library Management System

## 1. Project Overview
Project ini merupakan implementasi dari sistem manajemen perpustakaan berbasis SQL. Tujuannya adalah untuk memahami konsep **Database Setup**, **CRUD Operation**, **CTAS (Create Table As Select)**, **Data Analysis**, dan **Advanced SQL Operations**. 

Struktur database mencakup tabel-tabel seperti `branch`, `employees`, `books`, `members`, `issued_status`, dan `return_status`, yang terhubung dengan relasi *foreign key* untuk menjaga integritas data.

---

## 2. Database Setup
Berikut adalah struktur tabel utama yang digunakan dalam proyek ini:

```sql
-- CREATE BRANCH TABLE
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
	branch_id VARCHAR (10) PRIMARY KEY,	
	manager_id	VARCHAR (10),
	branch_address VARCHAR (55),	
	contact_no VARCHAR (10)
);

ALTER TABLE branch
ALTER COLUMN contact_no TYPE VARCHAR(20);

-- CREATE EMPLOYEES TABLE
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
	emp_id VARCHAR (10) PRIMARY KEY,	
	emp_name VARCHAR (25),	
	position VARCHAR (25),
	salary INT,
	branch_id VARCHAR (25) 
);

-- CREATE BOOKS TABLE
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
	isbn VARCHAR (20) PRIMARY KEY,	
	book_title VARCHAR (75),	
	category VARCHAR (10),
	rental_price FLOAT,
	status	VARCHAR (15),
	author	VARCHAR (35),
	publisher VARCHAR (55)
);

ALTER TABLE books
ALTER COLUMN category TYPE VARCHAR(20);

-- CREATE MEMBERS TABLE
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
	member_id VARCHAR(10) PRIMARY KEY,	
	member_name	VARCHAR(25),
	member_address VARCHAR(75),
	reg_date DATE
);

-- CREATE ISSUED_STATUS TABLE
CREATE TABLE issued_status
(
	issued_id VARCHAR(10) PRIMARY KEY,	
	issued_member_id VARCHAR(10), 	
	issued_book_name VARCHAR(75),	
	issued_date	DATE,
	issued_book_isbn VARCHAR(25), 
	issued_emp_id VARCHAR(10) 
);

-- CREATE RETURN_STATUS TABLE
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
	return_id VARCHAR(10) PRIMARY KEY,	
	issued_id VARCHAR(10),	  
	return_book_name VARCHAR(75),	
	return_date	DATE,
	return_book_isbn VARCHAR(20)
);

-- FOREIGN KEYS
ALTER TABLE issued_status ADD CONSTRAINT fk_members FOREIGN KEY (issued_member_id) REFERENCES members(member_id);
ALTER TABLE issued_status ADD CONSTRAINT fk_books FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn);
ALTER TABLE issued_status ADD CONSTRAINT fk_employees FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id);
ALTER TABLE employees ADD CONSTRAINT fk_branch FOREIGN KEY (branch_id) REFERENCES branch(branch_id);
ALTER TABLE return_status ADD CONSTRAINT fk_issued_status FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id);
```

---

## 3. CRUD Operations
### Task 1: Create a New Member Record
```sql
INSERT INTO members (member_id, member_name, member_address, reg_date)
VALUES ('C112', 'Grace Lee', '912 Willow St', '2024-07-20');
SELECT * FROM members WHERE member_id = 'C112';
```

### Task 2: Update an Employee's Salary
```sql
UPDATE employees
SET salary = 48000
WHERE emp_id = 'E102';
SELECT * FROM employees WHERE emp_id = 'E102';
```

### Task 3: Delete a Record from Return Status Table
```sql
DELETE FROM return_status
WHERE return_id = 'R105';
SELECT * FROM return_status;
```

### Task 4: Retrieve All Books Written by a Specific Author
```sql
SELECT * FROM books WHERE author = 'J.D. Salinger';
```

### Task 5: List Members Who Have Issued More Than One Book
```sql
SELECT issued_emp_id, COUNT(*) AS total_book_issued
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;
```

---

## 4. CTAS (Create Table As Select)
### Task 6: Create Summary Table of Books Issued by Each Employee
```sql
CREATE TABLE employee_issued_cnt AS
SELECT 
	e.emp_id,
	e.emp_name,
	e.position,
	COUNT(ist.issued_id) AS total_books_issued
FROM employees AS e
LEFT JOIN issued_status AS ist ON e.emp_id = ist.issued_emp_id
GROUP BY e.emp_id, e.emp_name, e.position;

SELECT * FROM employee_issued_cnt;
```

---

## 5. Data Analysis & Findings
### Task 7: Retrieve All Books from a Specific Publisher
```sql
SELECT * FROM books WHERE publisher = 'Penguin Books';
```

### Task 8: Find Total Rental Income by Author
```sql
SELECT 
	b.author,
	SUM(b.rental_price) AS total_income,
	COUNT(*) AS total_books_issued
FROM issued_status AS ist
JOIN books AS b ON b.isbn = ist.issued_book_isbn
GROUP BY b.author
ORDER BY total_income DESC;
```

### Task 9: List Members Who Registered Within the Last 2 Years
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '2 years'
ORDER BY reg_date DESC;
```

### Task 10: List Employees with Their Branch and Manager Info
```sql
SELECT 
	e1.emp_id,
	e1.emp_name,
	e1.position,
	e1.salary,
	b.*,
	e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b ON e1.branch_id = b.branch_id
JOIN employees AS e2 ON e2.emp_id = b.manager_id;
```

### Task 11: Create a Table for Mid-Priced Books (5 - 7)
```sql
CREATE TABLE mid_priced_books AS
SELECT * FROM books WHERE rental_price BETWEEN 5.00 AND 7.00;
```

### Task 12: Retrieve Books That Haven’t Been Returned Yet
```sql
SELECT * FROM issued_status AS ist
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

---

## 6. Advanced SQL Operations
### Task 13: Identify Members Who Returned Books Late (>20 Days)
```sql
SELECT 
	m.member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	rs.return_date,
	(rs.return_date - ist.issued_date) AS total_days,
	CASE 
		WHEN (rs.return_date - ist.issued_date) > 20 THEN 'Late'
		ELSE 'On Time'
	END AS return_status
FROM issued_status AS ist
JOIN members AS m ON m.member_id = ist.issued_member_id
JOIN books AS b ON b.isbn = ist.issued_book_isbn
JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE (rs.return_date - ist.issued_date) > 20
ORDER BY total_days DESC;
```

### Task 14: Branch Activity Report
```sql
CREATE TABLE branch_activity_report AS
SELECT 
	b.branch_id,
	COUNT(DISTINCT e.emp_id) AS total_employees,
	COUNT(DISTINCT ist.issued_member_id) AS active_members,
	COUNT(ist.issued_id) AS total_issued_books
FROM branch AS b
JOIN employees AS e ON e.branch_id = b.branch_id
LEFT JOIN issued_status AS ist ON ist.issued_emp_id = e.emp_id
GROUP BY b.branch_id;

SELECT * FROM branch_activity_report;
```

### Task 15: Members Who Haven’t Borrowed in the Last 2 Years
```sql
CREATE TABLE inactive_members AS
SELECT * FROM members
WHERE member_id NOT IN (
	SELECT DISTINCT issued_member_id
	FROM issued_status
	WHERE issued_date >= CURRENT_DATE - INTERVAL '2 years'
);

SELECT * FROM inactive_members;
```

### Task 16: Top 5 Most Active Members
```sql
SELECT 
	m.member_id,
	m.member_name,
	COUNT(ist.issued_id) AS total_books_issued
FROM members AS m
JOIN issued_status AS ist ON ist.issued_member_id = m.member_id
GROUP BY m.member_id, m.member_name
ORDER BY total_books_issued DESC
LIMIT 5;
```

---

## 7. Visual References
### Entity Relationship Diagram (ERD)
![ERD](https://github.com/muhfaridfb/SQL_Library-Management-System/blob/main/library_erd.png)

### Library Interface Preview
![Library](https://github.com/muhfaridfb/SQL_Library-Management-System/blob/main/library.jpg)

---

## 8. Summary
Proyek ini menunjukkan penerapan lengkap SQL mulai dari pembuatan tabel, manipulasi data (CRUD), analisis dengan query agregat, hingga pembuatan laporan lanjutan. Struktur ini dapat dikembangkan untuk implementasi sistem manajemen perpustakaan yang lebih kompleks di masa depan.
