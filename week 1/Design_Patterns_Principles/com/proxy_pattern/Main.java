package Design_Patterns_Principles.com.proxy_pattern;

public class Main {
    public static void main(String[] args) {
        Image image1 = new ProxyImage("design-pattern.png");

        // Image will be loaded and displayed
        image1.display();

        // Image will be retrieved from cache
        image1.display();
    }
}
