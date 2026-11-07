package com.shoppingcart.util;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.NumberFormat;
import java.util.Currency;
import java.util.Locale;

/**
 * Enterprise utility for Indian Rupee (₹ - INR) currency formatting.
 * Formats monetary amounts according to Indian numbering standards (e.g. ₹1,299.00, ₹25,000.00).
 */
public final class CurrencyUtil {

    public static final String RUPEE_SYMBOL = "\u20B9";
    private static final Locale INDIA_LOCALE = Locale.of("en", "IN");
    private static final Currency INR_CURRENCY = Currency.getInstance("INR");

    private CurrencyUtil() {
        // Utility class
    }

    /**
     * Formats a BigDecimal into Indian Rupee representation (e.g., ₹1,299.00, ₹25,000.00).
     * Returns ₹0.00 if input is null.
     */
    public static String format(BigDecimal amount) {
        if (amount == null) {
            return RUPEE_SYMBOL + "0.00";
        }
        return formatInternal(amount.doubleValue());
    }

    /**
     * Formats a primitive double or Double into Indian Rupee representation.
     */
    public static String format(double amount) {
        return formatInternal(amount);
    }

    /**
     * Formats a Double object into Indian Rupee representation.
     */
    public static String format(Double amount) {
        if (amount == null) {
            return RUPEE_SYMBOL + "0.00";
        }
        return formatInternal(amount);
    }

    /**
     * Formats an integer / long amount.
     */
    public static String format(long amount) {
        return formatInternal((double) amount);
    }

    /**
     * Returns the official Indian Rupee currency symbol (₹).
     */
    public static String getSymbol() {
        return RUPEE_SYMBOL;
    }

    private static String formatInternal(double amount) {
        NumberFormat nf = NumberFormat.getCurrencyInstance(INDIA_LOCALE);
        nf.setCurrency(INR_CURRENCY);
        if (nf instanceof DecimalFormat) {
            DecimalFormat df = (DecimalFormat) nf;
            DecimalFormatSymbols symbols = df.getDecimalFormatSymbols();
            symbols.setCurrencySymbol(RUPEE_SYMBOL);
            df.setDecimalFormatSymbols(symbols);
            df.setMinimumFractionDigits(2);
            df.setMaximumFractionDigits(2);
            return df.format(amount);
        }
        return RUPEE_SYMBOL + String.format(INDIA_LOCALE, "%,.2f", amount);
    }
}
