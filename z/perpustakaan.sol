// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract perpustakaan {
    address public Admin;
    uint public bookCount;

    struct Book {
        string title;
        string author;
        string isbn;
        bool isAvailable;
    }

    mapping(uint => Book) public books;
    mapping(string => uint) public bookIdByISBN;

    event BookAdded(uint indexed bookId, string title, string author, string isbn);
    event BookUpdated(uint indexed bookId, string title, string author, string isbn);
    event BookRemoved(uint indexed bookId);
    event BookBorrowed(uint indexed bookId);
    event BookReturned(uint indexed bookId);

    modifier onlyAdmin() {
        require(msg.sender == Admin, "Only the Admin can call this function");
        _;
    }

    constructor() {
        Admin = msg.sender;
    }

    function addBook(string memory title, string memory author, string memory isbn) public onlyAdmin {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(author).length > 0, "Author cannot be empty");
        require(bytes(isbn).length > 0, "ISBN cannot be empty");
        require(bookIdByISBN[isbn] == 0, "ISBN already exists");

        uint bookId = bookCount;
        books[bookId] = Book(title, author, isbn, true);
        bookIdByISBN[isbn] = bookId;
        bookCount++;

        emit BookAdded(bookId, title, author, isbn);
    }

    function updateBook(uint bookId, string memory title, string memory author, string memory isbn) public onlyAdmin {
        require(bookId < bookCount, "Invalid book ID");

        Book storage book = books[bookId];

        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(author).length > 0, "Author cannot be empty");
        require(bytes(isbn).length > 0, "ISBN cannot be empty");
        require(bookIdByISBN[isbn] == 0 || bookIdByISBN[isbn] == bookId, "ISBN already exists");

        book.title = title;
        book.author = author;
        book.isbn = isbn;

        bookIdByISBN[isbn] = bookId;

        emit BookUpdated(bookId, title, author, isbn);
    }

    function removeBook(uint bookId) public onlyAdmin {
        require(bookId < bookCount, "Invalid book ID");

        Book storage book = books[bookId];
        require(book.isAvailable, "Book is currently borrowed");

        string memory isbn = book.isbn;
        delete books[bookId];
        delete bookIdByISBN[isbn];

        emit BookRemoved(bookId);
    }

    function borrowBook(uint bookId) public {
        require(bookId < bookCount, "Invalid book ID");

        Book storage book = books[bookId];
        require(book.isAvailable, "Book is not available for borrowing");

        book.isAvailable = false;
        emit BookBorrowed(bookId);
    }

    function returnBook(uint bookId) public {
        require(bookId < bookCount, "Invalid book ID");

        Book storage book = books[bookId];
        require(!book.isAvailable, "Book is already available");

        book.isAvailable = true;
        emit BookReturned(bookId);
    }

    function getBookByISBN(string memory isbn) public view returns (uint) {
        return bookIdByISBN[isbn];
    }
}

#// Masih binggung caranya
