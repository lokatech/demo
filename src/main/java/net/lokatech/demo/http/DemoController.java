package net.lokatech.demo.http;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
class HomeController {

    // Define variables for rate limiting
    private static final int RATE_LIMIT = 5; // Maximum allowed requests
    private static final long RATE_LIMIT_RESET_INTERVAL = 60 * 1000; // 1 minute in milliseconds
    private int requestCount = 0; // Counter for requests
    private long lastResetTime = System.currentTimeMillis(); // Time of the last reset

    @GetMapping("/test")
    String hello() {
        return "hello";
    }

    // Simulate a NullPointerException and apply rate limiting
    // filter pattern [($.log.level = "ERROR") && ($.log.message = "*NullPointerException*")]
    @GetMapping("/null-pointer-exception")
    public String throwNullPointerException() {
        performRateLimiting();
        String nullString = null;
        return nullString.length() + ""; // This will throw NullPointerException
    }

    // Simulate an ArithmeticException (division by zero) and apply rate limiting
    // filter pattern [($.log.level = "ERROR") && ($.log.message = "*ArithmeticException*")]
    @GetMapping("/arithmetic-exception")
    public String throwArithmeticException() {
        performRateLimiting();
        int result = 5 / 0; // This will throw ArithmeticException
        return String.valueOf(result);
    }

    // Simulate an ArrayIndexOutOfBoundsException and apply rate limiting
    // filter pattern [($.log.level = "ERROR") && ($.log.message = "*ArrayIndexOutOfBoundsException*")]
    @GetMapping("/array-index-exception")
    public String throwArrayIndexOutOfBoundsException() {
        performRateLimiting();
        int[] arr = new int[5];
        int value = arr[10]; // This will throw ArrayIndexOutOfBoundsException
        return String.valueOf(value);
    }

    // Simulate a NumberFormatException and apply rate limiting
    // filter pattern [($.log.level = "ERROR") && ($.log.message = "*NumberFormatException*")]
    @GetMapping("/number-format-exception")
    public String throwNumberFormatException() {
        performRateLimiting();
        String invalidNumber = "abc";
        int number = Integer.parseInt(invalidNumber); // This will throw NumberFormatException
        return String.valueOf(number);
    }

    // Rate limiting logic
    private void performRateLimiting() {
        long currentTime = System.currentTimeMillis();

        // Check if it's time to reset the rate limiting counter
        if (currentTime - lastResetTime >= RATE_LIMIT_RESET_INTERVAL) {
            // Reset the counter and update the last reset time
            requestCount = 1;
            lastResetTime = currentTime;
        } else {
            // Increment the request count
            requestCount++;

            // Check if the request count exceeds the rate limit
            if (requestCount > RATE_LIMIT) {
                throw new RateLimitExceededException("Rate limit exceeded. Please try again later.");
            }
        }
    }

}