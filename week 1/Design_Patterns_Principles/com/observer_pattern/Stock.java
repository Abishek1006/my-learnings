package Design_Patterns_Principles.com.observer_pattern;

public interface Stock {
    void register(Observer observer);
    void deregister(Observer observer);
    void notifyObservers();
    void setPrice(double price);
}
