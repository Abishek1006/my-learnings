package Design_Patterns_Principles.com.factory_method;

public class PdfDocument implements Document {
    @Override
    public void open() {
        System.out.println("Opening PDF document.");
    }
}
