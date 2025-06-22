package Design_Patterns_Principles.com.decorator_pattern;

public class Main {
    public static void main(String[] args) {

        Notifier notifier = new EmailNotifier();

        notifier.send("Your order has been shipped.");
    }
}
