package com.shoppingcart.util;

import org.junit.Test;
import java.math.BigDecimal;

import static org.junit.Assert.*;

public class CurrencyUtilTest {

    @Test
    public void testFormatBigDecimal() {
        assertEquals("\u20B9499.00", CurrencyUtil.format(new BigDecimal("499.00")));
        assertEquals("\u20B91,299.00", CurrencyUtil.format(new BigDecimal("1299.00")));
        assertEquals("\u20B925,000.00", CurrencyUtil.format(new BigDecimal("25000.00")));
    }

    @Test
    public void testFormatNullAndZero() {
        assertEquals("\u20B90.00", CurrencyUtil.format((BigDecimal) null));
        assertEquals("\u20B90.00", CurrencyUtil.format(BigDecimal.ZERO));
    }

    @Test
    public void testFormatPrimitiveDouble() {
        assertEquals("\u20B9899.99", CurrencyUtil.format(899.99));
        assertEquals("\u20B90.00", CurrencyUtil.format(0.0));
    }

    @Test
    public void testGetSymbol() {
        assertEquals("\u20B9", CurrencyUtil.getSymbol());
    }
}
