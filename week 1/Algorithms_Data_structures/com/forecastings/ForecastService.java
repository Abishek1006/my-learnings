package com.forecastings;

import java.util.Map;

public class ForecastService {
    public static double forecastValueRecursive(double initialValue, double growthRate, int years) {
        if (years == 0) return initialValue;
        return forecastValueRecursive(initialValue, growthRate, years - 1) * (1 + growthRate);
    }
    public static double forecastValueMemoized(double initialValue, double growthRate, int years, Map<Integer, Double> memo) {
        if (years == 0) return initialValue;
        if (memo.containsKey(years)) return memo.get(years);

        double value = forecastValueMemoized(initialValue, growthRate, years - 1, memo) * (1 + growthRate);
        memo.put(years, value);
        return value;
    }
}
