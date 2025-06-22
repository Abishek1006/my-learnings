package com.inventory;

public class Main {
    public static void main(String[] args) {
        InventoryManager manager = new InventoryManager();

        Product p1 = new Product("P001", "Laptop", 10, 55000.0);
        Product p2 = new Product("P002", "Mouse", 50, 500.0);

        manager.addProduct(p1);
        manager.addProduct(p2);
        manager.viewInventory();

        manager.updateProduct("P001", 8, 53000.0);
        manager.deleteProduct("P002");

        manager.viewInventory();
    }
}
