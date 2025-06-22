package Design_Patterns_Principles.com.dependency_injection;

public class Main {
    public static void main(String[] args) {
        CustomerRepository repo = new CustomerRepositoryImpl();
        CustomerService service = new CustomerService(repo);

        service.getCustomerDetails("C101");
    }
}
