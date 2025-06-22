package Design_Patterns_Principles.com.dependency_injection;

public class CustomerService {
    private CustomerRepository repository;

    public CustomerService(CustomerRepository repository) {
        this.repository = repository;
    }

    public void getCustomerDetails(String id) {
        String details = repository.findCustomerById(id);
        System.out.println("Fetched from repository: " + details);
    }
}
