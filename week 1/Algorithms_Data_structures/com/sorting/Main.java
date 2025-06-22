package com.sorting;

public class Main {
    public static void main(String[] args) {
        Order[] orders = {
            new Order("O101", "Alice", 3000.50),
            new Order("O102", "Bob", 1500.75),
            new Order("O103", "Charlie", 4500.00),
            new Order("O104", "Daisy", 2000.00)
        };

        System.out.println("Original Orders:");
        for (Order o : orders) System.out.println(o);

        System.out.println("\nBubble Sort by totalPrice (descending):");
        SortService.bubbleSort(orders);
        for (Order o : orders) System.out.println(o);
        orders = new Order[] {
            new Order("O101", "Alice", 3000.50),
            new Order("O102", "Bob", 1500.75),
            new Order("O103", "Charlie", 4500.00),
            new Order("O104", "Daisy", 2000.00)
        };

        System.out.println("\nQuick Sort by totalPrice (descending):");
        SortService.quickSort(orders, 0, orders.length - 1);
        for (Order o : orders) System.out.println(o);
    }
}
