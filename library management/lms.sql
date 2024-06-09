SELECT * FROM Books;
SELECT * FROM Borrowers;
SELECT * FROM Transactions;
SELECT * FROM Books WHERE Copies_Available > 0;
SELECT b.Title, t.Borrow_Date, t.Due_Date 
FROM Transactions t
JOIN Books b ON t.Book_ID = b.Book_ID
WHERE t.Borrower_ID = 1 AND t.Returned = FALSE;
UPDATE Transactions 
SET Returned = TRUE, Return_Date = CURDATE() 
WHERE Transaction_ID = 1;

UPDATE Books 
SET Copies_Available = Copies_Available + 1 
WHERE Book_ID = (SELECT Book_ID FROM Transactions WHERE Transaction_ID = 1);
