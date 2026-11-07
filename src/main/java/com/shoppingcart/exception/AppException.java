package com.shoppingcart.exception;

/**
 * Base custom runtime exception for application business and database errors.
 */
public class AppException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public AppException(String message) {
        super(message);
    }

    public AppException(String message, Throwable cause) {
        super(message, cause);
    }
}
