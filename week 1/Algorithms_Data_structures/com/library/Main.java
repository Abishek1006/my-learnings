package com.library;

public class Main {
    public static void main(String[] args) {
        Book[] books = {
            new Book("B003", "Java Programming", "Alice"),
            new Book("B001", "Data Structures", "Bob"),
            new Book("B002", "Algorithms", "Charlie"),
            new Book("B004", "Operating Systems", "Dave")
        };

        System.out.println("Linear Search for 'Algorithms':");
        Book result1 = LibraryService.linearSearch(books, "Algorithms");
        System.out.println(result1 != null ? result1 : "Book not found");

        System.out.println("\nSorting books by title for binary search...");
        LibraryService.sortByTitle(books);

        System.out.println("\nBinary Search for 'Algorithms':");
        Book result2 = LibraryService.binarySearch(books, "Algorithms");
        System.out.println(result2 != null ? result2 : "Book not found");
    }
}
