# Library Management System

## Overview
The Library Management System is a robust project designed to manage the operations of a library. This includes cataloging books, tracking loans, managing member information, and ensuring data integrity through the use of advanced SQL features such as stored procedures, triggers, and views.

## Project Structure
The project is organized as follows:

### 1.Database Schema

**1.1.Create Database**
```sql
CREATE DATABASE LibraryDB;
USE LibraryDB;
```
**1.2.Create Tables**
```
-- Books table
CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    ISBN VARCHAR(20) UNIQUE NOT NULL,
    Publisher VARCHAR(100),
    YearPublished YEAR,
    Available BOOLEAN DEFAULT TRUE
);

-- Authors table
CREATE TABLE Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100)
);

-- BookAuthors table (many-to-many relationship)
CREATE TABLE BookAuthors (
    BookID INT,
    AuthorID INT,
    PRIMARY KEY (BookID, AuthorID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

-- Categories table
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) UNIQUE NOT NULL
);

-- BookCategories table (many-to-many relationship)
CREATE TABLE BookCategories (
    BookID INT,
    CategoryID INT,
    PRIMARY KEY (BookID, CategoryID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Members table
CREATE TABLE Members (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    DateOfBirth DATE,
    Address VARCHAR(255),
    Phone VARCHAR(20),
    Email VARCHAR(100) UNIQUE
);

-- Loans table
CREATE TABLE Loans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    BookID INT,
    MemberID INT,
    LoanDate DATE,
    ReturnDate DATE,
    Returned BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);

-- Staff table
CREATE TABLE Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Position VARCHAR(100)
);
```
**1.3.Insert sample Data**
```
-- Insert sample data into Books
INSERT INTO Books (Title, ISBN, Publisher, YearPublished) VALUES
('The Great Gatsby', '9780743273565', 'Scribner', 1925),
('To Kill a Mockingbird', '9780061120084', 'J.B. Lippincott & Co.', 1960);

-- Insert sample data into Authors
INSERT INTO Authors (FirstName, LastName) VALUES
('F. Scott', 'Fitzgerald'),
('Harper', 'Lee');

-- Insert sample data into BookAuthors
INSERT INTO BookAuthors (BookID, AuthorID) VALUES
(1, 1), -- The Great Gatsby by F. Scott Fitzgerald
(2, 2); -- To Kill a Mockingbird by Harper Lee

-- Insert sample data into Categories
INSERT INTO Categories (CategoryName) VALUES
('Classic'),
('Fiction');

-- Insert sample data into BookCategories
INSERT INTO BookCategories (BookID, CategoryID) VALUES
(1, 1), -- The Great Gatsby is a Classic
(2, 1), -- To Kill a Mockingbird is a Classic
(2, 2); -- To Kill a Mockingbird is also Fiction

-- Insert sample data into Members
INSERT INTO Members (FirstName, LastName, DateOfBirth, Address, Phone, Email) VALUES
('John', 'Doe', '1980-01-15', '123 Main St', '555-5555', 'johndoe@example.com'),
('Jane', 'Smith', '1990-05-22', '456 Elm St', '555-5556', 'janesmith@example.com');

-- Insert sample data into Loans
INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate, Returned) VALUES
(1, 1, '2023-06-01', '2023-06-15', FALSE),
(2, 2, '2023-06-03', '2023-06-17', TRUE);

-- Insert sample data into Staff
INSERT INTO Staff (FirstName, LastName, Position) VALUES
('Alice', 'Johnson', 'Librarian'),
('Bob', 'Williams', 'Assistant Librarian');
```
### 2. Stored Procedures
**2.1.Procedure to Add a New Book**
```
-- Insert sample data into Books
INSERT INTO Books (Title, ISBN, Publisher, YearPublished) VALUES
('The Great Gatsby', '9780743273565', 'Scribner', 1925),
('To Kill a Mockingbird', '9780061120084', 'J.B. Lippincott & Co.', 1960);

-- Insert sample data into Authors
INSERT INTO Authors (FirstName, LastName) VALUES
('F. Scott', 'Fitzgerald'),
('Harper', 'Lee');

-- Insert sample data into BookAuthors
INSERT INTO BookAuthors (BookID, AuthorID) VALUES
(1, 1), -- The Great Gatsby by F. Scott Fitzgerald
(2, 2); -- To Kill a Mockingbird by Harper Lee

-- Insert sample data into Categories
INSERT INTO Categories (CategoryName) VALUES
('Classic'),
('Fiction');

-- Insert sample data into BookCategories
INSERT INTO BookCategories (BookID, CategoryID) VALUES
(1, 1), -- The Great Gatsby is a Classic
(2, 1), -- To Kill a Mockingbird is a Classic
(2, 2); -- To Kill a Mockingbird is also Fiction

-- Insert sample data into Members
INSERT INTO Members (FirstName, LastName, DateOfBirth, Address, Phone, Email) VALUES
('John', 'Doe', '1980-01-15', '123 Main St', '555-5555', 'johndoe@example.com'),
('Jane', 'Smith', '1990-05-22', '456 Elm St', '555-5556', 'janesmith@example.com');

-- Insert sample data into Loans
INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate, Returned) VALUES
(1, 1, '2023-06-01', '2023-06-15', FALSE),
(2, 2, '2023-06-03', '2023-06-17', TRUE);

-- Insert sample data into Staff
INSERT INTO Staff (FirstName, LastName, Position) VALUES
('Alice', 'Johnson', 'Librarian'),
('Bob', 'Williams', 'Assistant Librarian');
```
**2.2.Procedure to Loan a Book**
```
DELIMITER //
CREATE PROCEDURE LoanBook (
    IN pBookID INT, 
    IN pMemberID INT, 
    IN pLoanDate DATE, 
    IN pReturnDate DATE
)
BEGIN
    INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate, Returned) 
    VALUES (pBookID, pMemberID, pLoanDate, pReturnDate, FALSE);
    UPDATE Books 
    SET Available = FALSE 
    WHERE BookID = pBookID;
END //
DELIMITER ;
```
**2.3.Procedure to Return a Book**
```
DELIMITER //
CREATE PROCEDURE ReturnBook (IN pLoanID INT)
BEGIN
    DECLARE bookID INT;
    SELECT BookID INTO bookID FROM Loans WHERE LoanID = pLoanID;
    UPDATE Loans 
    SET Returned = TRUE 
    WHERE LoanID = pLoanID;
    UPDATE Books 
    SET Available = TRUE 
    WHERE BookID = bookID;
END //
DELIMITER ;
```
### 3.Triggers
**3.1.Trigger to Update Book Availability on Loan**
```
DELIMITER //
CREATE TRIGGER AfterLoanInsert
AFTER INSERT ON Loans
FOR EACH ROW
BEGIN
    UPDATE Books 
    SET Available = FALSE 
    WHERE BookID = NEW.BookID;
END //
DELIMITER ;
```
**3.2. Trigger to Update Book Availability on Return**
```
DELIMITER //
CREATE TRIGGER AfterLoanUpdate
AFTER UPDATE ON Loans
FOR EACH ROW
BEGIN
    IF NEW.Returned = TRUE THEN
        UPDATE Books 
        SET Available = TRUE 
        WHERE BookID = NEW.BookID;
    END IF;
END //
DELIMITER ;
```
### 4. Views
**4.1. View for Borrowed Books**
```
CREATE VIEW BorrowedBooks AS
SELECT b.Title, m.FirstName, m.LastName, l.LoanDate, l.ReturnDate
FROM Loans l
JOIN Books b ON l.BookID = b.BookID
JOIN Members m ON l.MemberID = m.MemberID
WHERE l.Returned = FALSE;

```
**4.2. View for Member Loan History**
```
CREATE VIEW MemberLoanHistory AS
SELECT m.MemberID, m.FirstName, m.LastName, b.Title, l.LoanDate, l.ReturnDate, l.Returned
FROM Loans l
JOIN Members m ON l.MemberID = m.MemberID
JOIN Books b ON l.BookID = b.BookID;
```
**4.3. View for Book Details with Authors and Categories**
```
CREATE VIEW BookDetails AS
SELECT b.BookID, b.Title, b.ISBN, b.Publisher, b.YearPublished,
    GROUP_CONCAT(DISTINCT CONCAT(a.FirstName, ' ', a.LastName) ORDER BY a.LastName SEPARATOR ', ') AS Authors,
    GROUP_CONCAT(DISTINCT c.CategoryName ORDER BY c.CategoryName SEPARATOR ', ') AS Categories
FROM Books b
LEFT JOIN BookAuthors ba ON b.BookID = ba.BookID
LEFT JOIN Authors a ON ba.AuthorID = a.AuthorID
LEFT JOIN BookCategories bc ON b.BookID = bc.BookID
LEFT JOIN Categories c ON bc.CategoryID = c.CategoryID
GROUP BY b.BookID, b.Title, b.ISBN, b.Publisher, b.YearPublished;
```



