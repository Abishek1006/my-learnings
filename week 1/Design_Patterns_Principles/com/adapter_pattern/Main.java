package Design_Patterns_Principles.com.adapter_pattern;

public class Main {
    public static void main(String[] args) {
        PaymentProcessor stripeProcessor = new StripeAdapter(new StripeGateway());

        stripeProcessor.processPayment(8500.0);
    }
}
