package com.task;

public class Main {
    public static void main(String[] args) {
        TaskManager manager = new TaskManager();

        Task t1 = new Task("T001", "Fix bugs", "Pending");
        Task t2 = new Task("T002", "Write docs", "In Progress");
        Task t3 = new Task("T003", "Deploy app", "Pending");

        manager.addTask(t1);
        manager.addTask(t2);
        manager.addTask(t3);

        System.out.println("\nAll Tasks:");
        manager.displayAllTasks();

        System.out.println("\nSearching for T002:");
        Task found = manager.searchTask("T002");
        System.out.println(found != null ? found : "Not found");

        System.out.println("\nDeleting T001:");
        manager.deleteTask("T001");

        System.out.println("\nAfter Deletion:");
        manager.displayAllTasks();
    }
}
