package Design_Patterns_Principles.com.builder_pattern;

public class Main {
    public static void main(String[] args) {
        Computer basicComputer = new Computer.Builder()
                .setCPU("Intel i5")
                .setRAM("8GB")
                .setStorage("256GB SSD")
                .build();

        System.out.println("Basic: " + basicComputer);

        Computer gamingRig = new Computer.Builder()
                .setCPU("Intel i9")
                .setRAM("32GB")
                .setStorage("1TB SSD")
                .setGPU("NVIDIA RTX 4080")
                .build();

        System.out.println("Gaming Rig: " + gamingRig);
    }
}
