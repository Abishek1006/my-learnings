package com.search;

public class Main {
    public static void main(String[] args) {
        Product[] products = {
            new Product("P003", "Keyboard", "Electronics"),
            new Product("P001", "Laptop", "Electronics"),
            new Product("P002", "Mouse", "Electronics"),
            new Product("P004", "Desk", "Furniture")
        };

        System.out.println("Linear Search:");
        Product result1 = SearchService.linearSearch(products, "Mouse");
        System.out.println(result1 != null ? result1 : "Product not found");

        System.out.println("\nBinary Search (after sorting):");
        SearchService.sortByName(products);
        Product result2 = SearchService.binarySearch(products, "Mouse");
        System.out.println(result2 != null ? result2 : "Product not found");
    }
}
