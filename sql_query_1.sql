SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM members;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;

-- Project Task -- 
-- Task 1 Create a New Member Record --
INSERT INTO members (member_id, member_name, member_address, reg_date)
VALUES ('C112', 'Grace Lee', '912 Willow St', '2024-07-20');
--CHECK RESULT--
SELECT * FROM members WHERE member_id = 'C112';

--TASK 2 Update an Employee's Salary --
UPDATE employees
SET salary = 48000
WHERE emp_id = 'E102';
--CHECK RESULT--
SELECT * FROM employees WHERE emp_id = 'E102'

--TASK 3 Delete a Record from Return Status Table
DELETE FROM return_status
WHERE return_id = 'R105';
--CHECK RESULT--
SELECT * FROM return_status;

--TASK 4 Retrieve All Books Written by a Specific Author (Example: J.D Salinger)--
SELECT *
FROM books
WHERE author = 'J.D. Salinger';

--TASK 5 List Members Who Have Issued More Than One --
SELECT
    issued_emp_id,
    COUNT(*) as total_book_issued
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;


--CTAS Create Table As Select--
--TASK 6 Create Summary Table of Books Issued by Each Employee: Membuat tabel baru (employee_issued_cnt) yang menampilkan setiap pegawai dan total jumlah buku yang telah mereka keluarkan (issued).--
CREATE TABLE employee_issued_cnt AS
SELECT 
    e.emp_id,
    e.emp_name,
    e.position,
    COUNT(ist.issued_id) AS total_books_issued
FROM employees AS e
LEFT JOIN issued_status AS ist
ON e.emp_id = ist.issued_emp_id
GROUP BY e.emp_id, e.emp_name, e.position;

SELECT * FROM employee_issued_cnt;

--DATA ANALYSIS & FINDINGS --
--TASK 7 Retrieve All Books in a Specific Publisher--
SELECT *
FROM books
WHERE publisher = 'Penguin Books';

--TASK 8 Find Total Rental Income by Author-
SELECT 
    b.author,
    SUM(b.rental_price) AS total_income,
    COUNT(*) AS total_books_issued
FROM issued_status AS ist
JOIN books AS b
ON b.isbn = ist.iss  ued_book_isbn
GROUP BY b.author
ORDER BY total_income DESC;

--TASK 9 List Members Who Registered Within the Last 365 days--
SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '2 years'
ORDER BY reg_date DESC;

--TASK 10 List Employees with Their Branch and Manager Info--
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id

--TASK 11 Create a Table for Mid-Priced Books (5 and 7)--
CREATE TABLE mid_priced_books AS
SELECT *
FROM books 
WHERE rental_price BETWEEN 5.00 AND 7.00;

--TASK 12 Retrieve the List of Books That Haven’t Been Returned Yet--
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

/*
*/
