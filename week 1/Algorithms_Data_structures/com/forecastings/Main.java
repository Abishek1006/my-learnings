package com.forecastings;

import java.util.HashMap;

public class Main {
    public static void main(String[] args) {
        double initialValue = 10000.0;
        double growthRate = 0.10;
        int years = 5;

        System.out.println("Forecast using plain recursion:");
        double plainResult = ForecastService.forecastValueRecursive(initialValue, growthRate, years);
        System.out.printf("Year %d forecast: ₹%.2f%n", years, plainResult);

        System.out.println("\nForecast using memoized recursion:");
        double memoizedResult = ForecastService.forecastValueMemoized(initialValue, growthRate, years, new HashMap<>());
        System.out.printf("Year %d forecast: ₹%.2f%n", years, memoizedResult);
    }
}
