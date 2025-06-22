package Design_Patterns_Principles.com.observer_pattern;

public class WebApp implements Observer {
    private String name;

    public WebApp(String name) {
        this.name = name;
    }

    @Override
    public void update(double price) {
        System.out.println(name + " received stock price update: ₹" + price);
    }
}
