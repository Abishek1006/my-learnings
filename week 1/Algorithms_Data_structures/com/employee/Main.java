package com.employee;

public class Main {
    public static void main(String[] args) {
        EmployeeManager manager = new EmployeeManager(5);

        Employee e1 = new Employee("E001", "Alice", "Developer", 70000);
        Employee e2 = new Employee("E002", "Bob", "Manager", 90000);
        Employee e3 = new Employee("E003", "Charlie", "Tester", 50000);

        manager.addEmployee(e1);
        manager.addEmployee(e2);
        manager.addEmployee(e3);

        System.out.println("\nAll Employees:");
        manager.displayAllEmployees();

        System.out.println("\nSearching for E002:");
        Employee found = manager.searchEmployee("E002");
        System.out.println(found != null ? found : "Not found");

        System.out.println("\nDeleting E001:");
        manager.deleteEmployee("E001");

        System.out.println("\nAfter Deletion:");
        manager.displayAllEmployees();
    }
}

