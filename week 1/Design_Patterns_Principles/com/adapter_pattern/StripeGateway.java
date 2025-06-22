package Design_Patterns_Principles.com.adapter_pattern;

public class StripeGateway {
    public void charge(double amount) {
        System.out.println("Charging amount via Stripe: ₹" + amount);
    }
}
