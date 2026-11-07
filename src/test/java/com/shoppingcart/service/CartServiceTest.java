package com.shoppingcart.service;

import com.shoppingcart.model.CartItem;
import com.shoppingcart.model.Product;
import org.junit.Test;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.assertEquals;

public class CartServiceTest {

    @Test
    public void testCalculateCartTotal() {
        CartService cartService = new CartService(null, null);

        Product p1 = new Product();
        p1.setProductId(1L);
        p1.setName("Product 1");
        p1.setPrice(new BigDecimal("100.50"));
        p1.setActive(true);

        Product p2 = new Product();
        p2.setProductId(2L);
        p2.setName("Product 2");
        p2.setPrice(new BigDecimal("49.50"));
        p2.setActive(true);

        Product inactiveProd = new Product();
        inactiveProd.setProductId(3L);
        inactiveProd.setName("Discontinued Item");
        inactiveProd.setPrice(new BigDecimal("200.00"));
        inactiveProd.setActive(false); // Inactive items should not be billed

        List<CartItem> items = new ArrayList<>();

        CartItem item1 = new CartItem(1L, 10L, 1L, 2, p1); // 2 * 100.50 = 201.00
        CartItem item2 = new CartItem(2L, 10L, 2L, 1, p2); // 1 * 49.50 = 49.50
        CartItem item3 = new CartItem(3L, 10L, 3L, 1, inactiveProd);

        items.add(item1);
        items.add(item2);
        items.add(item3);

        BigDecimal total = cartService.calculateCartTotal(items);

        // Expected: 201.00 + 49.50 = 250.50
        assertEquals(new BigDecimal("250.50"), total);
    }

    @Test
    public void testEmptyCartTotal() {
        CartService cartService = new CartService(null, null);
        assertEquals(BigDecimal.ZERO, cartService.calculateCartTotal(new ArrayList<>()));
        assertEquals(BigDecimal.ZERO, cartService.calculateCartTotal(null));
    }
}
