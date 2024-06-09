CREATE DATABASE LibraryDB;
USE LibraryDB;
-- Books table
CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    ISBN VARCHAR(20) UNIQUE NOT NULL,
    Publisher VARCHAR(100),
    YearPublished YEAR
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


-- find all books by a specfic author:
SELECT b.Title 
FROM Books b
JOIN BookAuthors ba ON b.BookID = ba.BookID
JOIN Authors a ON ba.AuthorID = a.AuthorID
WHERE a.FirstName = 'Harper' AND a.LastName = 'Lee';

-- list all overdue books:
SELECT m.FirstName, m.LastName, b.Title, l.LoanDate, l.ReturnDate 
FROM Loans l
JOIN Members m ON l.MemberID = m.MemberID
JOIN Books b ON l.BookID = b.BookID
WHERE l.Returned = FALSE AND l.ReturnDate < CURDATE();

-- count the number of books in each category:
SELECT c.CategoryName, COUNT(bc.BookID) AS NumberOfBooks
FROM Categories c
JOIN BookCategories bc ON c.CategoryID = bc.CategoryID
GROUP BY c.CategoryName;

-- find the most borrowed books:
SELECT b.Title, COUNT(l.LoanID) AS TimesBorrowed
FROM Books b
JOIN Loans l ON b.BookID = l.BookID
GROUP BY b.Title
ORDER BY TimesBorrowed DESC;

-- optimization and indexing
CREATE INDEX idx_author_name ON Authors (FirstName, LastName);
CREATE INDEX idx_book_title ON Books (Title);
CREATE INDEX idx_member_name ON Members (FirstName, LastName);

-- procedure to add a new book:
DELIMITER //
CREATE PROCEDURE AddBook (
    IN pTitle VARCHAR(255), 
    IN pISBN VARCHAR(20), 
    IN pPublisher VARCHAR(100), 
    IN pYearPublished YEAR
)
BEGIN
    INSERT INTO Books (Title, ISBN, Publisher, YearPublished) 
    VALUES (pTitle, pISBN, pPublisher, pYearPublished);
END //
DELIMITER ;

-- procedure to loan a book
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
END //
DELIMITER ;

-- procedure to return a book
DELIMITER //
CREATE PROCEDURE ReturnBook (IN pLoanID INT)
BEGIN
    UPDATE Loans 
    SET Returned = TRUE 
    WHERE LoanID = pLoanID;
END //
DELIMITER ;

-- trigger to update book availability on loan
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

-- trigger to update book availability on return
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

-- view for borrowed books:
CREATE VIEW BorrowedBooks AS
SELECT b.Title, m.FirstName, m.LastName, l.LoanDate, l.ReturnDate
FROM Loans l
JOIN Books b ON l.BookID = b.BookID
JOIN Members m ON l.MemberID = m.MemberID
WHERE l.Returned = FALSE;

-- view for member loan history
CREATE VIEW MemberLoanHistory AS
SELECT m.MemberID, m.FirstName, m.LastName, b.Title, l.LoanDate, l.ReturnDate, l.Returned
FROM Loans l
JOIN Members m ON l.MemberID = m.MemberID
JOIN Books b ON l.BookID = b.BookID;

-- view for book details with authors and categories
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
