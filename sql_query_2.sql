-- Library Management SQL P2--

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM members;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;

-- Task 13 Identify Members Who Returned Books Late (Member yang mengembalikan buku lebih dari 20 hari sejak tanggal pinjam)
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
JOIN 
	members AS m 
	ON m.member_id = ist.issued_member_id
JOIN 
	books AS b 
	ON b.isbn = ist.issued_book_isbn
JOIN 
	return_status AS rs 
	ON rs.issued_id = ist.issued_id
WHERE (rs.return_date - ist.issued_date) > 20
ORDER BY total_days DESC;

/*Task 14 Branch Activity Report Create a report showing 
for each branch the total number of employees, active 
members (who issued books), and total books issued.*/
CREATE TABLE branch_activity_report AS
SELECT 
    b.branch_id,
    COUNT(DISTINCT e.emp_id) AS total_employees,
    COUNT(DISTINCT ist.issued_member_id) AS active_members,
    COUNT(ist.issued_id) AS total_issued_books
FROM branch AS b
JOIN 
	employees AS e 
	ON e.branch_id = b.branch_id
LEFT JOIN 
	issued_status AS ist 
	ON ist.issued_emp_id = e.emp_id
GROUP BY b.branch_id;

--Check result--
SELECT * FROM branch_activity_report

/*Task 15 Members Who Haven’t Borrowed in the Last 6 Months:
Use a CTAS query to create a table inactive_members that
lists all members who have not issued any books in the 
last 2 years. */
CREATE TABLE inactive_members AS
SELECT * FROM members
WHERE member_id NOT IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL '2 years'
);

SELECT * FROM inactive_members;

/*Task 16 Top 5 Most Active Members: Find the top 5 members 
who have issued the most books. Display member ID, name, and 
number of books issued.*/
SELECT 
    m.member_id,
    m.member_name,
    COUNT(ist.issued_id) AS total_books_issued
FROM members AS m
JOIN issued_status AS ist ON ist.issued_member_id = m.member_id
GROUP BY m.member_id, m.member_name
ORDER BY total_books_issued DESC
LIMIT 5;