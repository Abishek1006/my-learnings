package com.inventory;

import java.util.HashMap;
import java.util.Map;
public class InventoryManager  {
    private Map<String, Product> inventory;

    public InventoryManager() {
        inventory = new HashMap<>();
    }
    public void addProduct(Product product) {
        if (inventory.containsKey(product.getProductId())) {
            System.out.println("Product ID already exists.");
            return;
        }
        inventory.put(product.getProductId(), product);
        System.out.println("Product added.");
    }
    public void updateProduct(String productId, int newQuantity, double newPrice) {
        Product product = inventory.get(productId);
        if (product != null) {
            product.setQuantity(newQuantity);
            product.setPrice(newPrice);
            System.out.println("Product updated.");
        } else {
            System.out.println("Product not found.");
        }
    }
    public void deleteProduct(String productId) {
        if (inventory.remove(productId) != null) {
            System.out.println("Product deleted.");
        } else {
            System.out.println("Product not found.");
        }
    }
    public void viewInventory() {
        for (Product product : inventory.values()) {
            System.out.println(product);
        }
    }
}
