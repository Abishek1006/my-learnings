package com.task;

public class TaskManager {
    private Task head;

    public TaskManager() {
        head = null;
    }
    public void addTask(Task newTask) {
        if (head == null) {
            head = newTask;
        } else {
            Task current = head;
            while (current.next != null) {
                current = current.next;
            }
            current.next = newTask;
        }
        System.out.println("Task added.");
    }
    public Task searchTask(String taskId) {
        Task current = head;
        while (current != null) {
            if (current.getTaskId().equals(taskId)) {
                return current;
            }
            current = current.next;
        }
        return null;
    }
    public void deleteTask(String taskId) {
        if (head == null) {
            System.out.println("No tasks to delete.");
            return;
        }

        if (head.getTaskId().equals(taskId)) {
            head = head.next;
            System.out.println("Task deleted.");
            return;
        }

        Task current = head;
        while (current.next != null && !current.next.getTaskId().equals(taskId)) {
            current = current.next;
        }

        if (current.next != null) {
            current.next = current.next.next;
            System.out.println("Task deleted.");
        } else {
            System.out.println("Task not found.");
        }
    }
    public void displayAllTasks() {
        if (head == null) {
            System.out.println("No tasks to display.");
            return;
        }

        Task current = head;
        while (current != null) {
            System.out.println(current);
            current = current.next;
        }
    }
}
