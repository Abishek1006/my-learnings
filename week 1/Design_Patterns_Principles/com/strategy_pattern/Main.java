package Design_Patterns_Principles.com.strategy_pattern;

public class Main {
    public static void main(String[] args) {
        PaymentContext context = new PaymentContext();

        context.setPaymentStrategy(new CreditCardPayment("1234-5678-9012-3456"));
        context.payAmount(2500.0);

        context.setPaymentStrategy(new GooglePayPayment("9876543210"));
        context.payAmount(1800.0);
    }
}
