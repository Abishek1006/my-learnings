package Design_Patterns_Principles.com.mvc_pattern;

public class Main {
    public static void main(String[] args) {
        Student student = new Student("Alice", "S101", "A");
        StudentView view = new StudentView();
        StudentController controller = new StudentController(student, view);

        controller.updateView();

        controller.setStudentName("Alicia");
        controller.setStudentGrade("A+");

        controller.updateView();
    }
}
