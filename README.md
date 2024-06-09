# Library Management System

## Overview
The Library Management System is a robust project designed to manage the operations of a library. This includes cataloging books, tracking loans, managing member information, and ensuring data integrity through the use of advanced SQL features such as stored procedures, triggers, and views.

## Project Structure
The project is organized as follows:

### 1. Database Schema

**1.1. Create Database**
```sql
CREATE DATABASE LibraryDB;
USE LibraryDB;
```
**1.2 Create Tables**
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

