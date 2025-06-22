package Design_Patterns_Principles.com.observer_pattern;

public class Main {
    public static void main(String[] args) {
        StockMarket stockMarket = new StockMarket();
        Observer webClient = new WebApp("WebClient");

        stockMarket.register(webClient);

        stockMarket.setPrice(500.0);
        stockMarket.setPrice(520.0);

        stockMarket.deregister(webClient);
        stockMarket.setPrice(530.0);
    }
}
