package Design_Patterns_Principles.com.strategy_pattern;

public class PaymentContext {
    private PaymentStrategy strategy;

    public void setPaymentStrategy(PaymentStrategy strategy) {
        this.strategy = strategy;
    }

    public void payAmount(double amount) {
        if (strategy == null) {
            System.out.println("Payment strategy not set.");
            return;
        }
        strategy.pay(amount);
    }
}
