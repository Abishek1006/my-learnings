package Design_Patterns_Principles.com.dependency_injection;

public class CustomerRepositoryImpl implements CustomerRepository {
    @Override
    public String findCustomerById(String id) {
        return "Customer[id=" + id + ", name=John Doe]";
    }
}
