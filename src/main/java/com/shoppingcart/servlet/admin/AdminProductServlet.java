package com.shoppingcart.servlet.admin;

import com.shoppingcart.exception.AppException;
import com.shoppingcart.model.Category;
import com.shoppingcart.model.Product;
import com.shoppingcart.service.ProductService;
import com.shoppingcart.util.CSRFUtil;
import com.shoppingcart.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller for Administrator Product catalog management, inventory adjustments, and safe image uploads.
 */
@WebServlet(name = "AdminProductServlet", urlPatterns = {
        "/admin/products",
        "/admin/products/add",
        "/admin/products/edit",
        "/admin/products/toggle"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      // 1MB
        maxFileSize = 2 * 1024 * 1024,        // 2MB
        maxRequestSize = 4 * 1024 * 1024      // 4MB
)
public class AdminProductServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminProductServlet.class.getName());
    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList(".jpg", ".jpeg", ".png", ".webp");

    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        CSRFUtil.getToken(request.getSession(true));

        if ("/admin/products/add".equals(path)) {
            showAddForm(request, response);
        } else if ("/admin/products/edit".equals(path)) {
            showEditForm(request, response);
        } else {
            showProductList(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!CSRFUtil.isValid(request)) {
            request.getSession().setAttribute("errorMessage", "Invalid security token. Please try again.");
            response.sendRedirect(request.getContextPath() + "/admin/products");
            return;
        }

        String path = request.getServletPath();
        try {
            if ("/admin/products/toggle".equals(path)) {
                handleToggleStatus(request, response);
            } else {
                handleSaveProduct(request, response);
            }
        } catch (AppException e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/products");
        }
    }

    private void showProductList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int page = ValidationUtil.parsePositiveInt(request.getParameter("page"), 1);
        int pageSize = 10;

        String categoryParam = request.getParameter("category");
        Long categoryId = null;
        if (categoryParam != null && !categoryParam.trim().isEmpty()) {
            try {
                categoryId = Long.parseLong(categoryParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        String keyword = request.getParameter("q");
        String sortBy = request.getParameter("sort");

        int totalCount = productService.countAllProductsForAdmin(categoryId, keyword);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<Product> products = productService.getAllProductsForAdmin(page, pageSize, categoryId, keyword, sortBy);
        List<Category> categories = productService.getAllCategories();

        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("selectedCategory", categoryId);
        request.setAttribute("searchKeyword", keyword != null ? keyword.trim() : "");

        request.getRequestDispatcher("/WEB-INF/views/admin/products/list.jsp").forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("categories", productService.getAllCategories());
        request.setAttribute("product", new Product());
        request.getRequestDispatcher("/WEB-INF/views/admin/products/form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/products");
            return;
        }

        try {
            long productId = Long.parseLong(idParam.trim());
            Optional<Product> prodOpt = productService.getProductById(productId);
            if (prodOpt.isEmpty()) {
                request.getSession().setAttribute("errorMessage", "Product not found.");
                response.sendRedirect(request.getContextPath() + "/admin/products");
                return;
            }

            request.setAttribute("product", prodOpt.get());
            request.setAttribute("categories", productService.getAllCategories());
            request.getRequestDispatcher("/WEB-INF/views/admin/products/form.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/products");
        }
    }

    private void handleSaveProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("productId");
        Long productId = (idParam != null && !idParam.trim().isEmpty()) ? Long.parseLong(idParam.trim()) : null;

        String name = request.getParameter("name");
        long categoryId = Long.parseLong(request.getParameter("categoryId"));
        String description = request.getParameter("description");
        BigDecimal price = new BigDecimal(request.getParameter("price"));
        int stockQty = Integer.parseInt(request.getParameter("stockQty"));
        boolean active = "1".equals(request.getParameter("active")) || "true".equalsIgnoreCase(request.getParameter("active"));
        String existingImagePath = request.getParameter("existingImagePath");

        // Process file upload safely
        String imagePath = existingImagePath;
        Part filePart = null;
        try {
            filePart = request.getPart("imageFile");
        } catch (Exception ignored) {}

        if (filePart != null && filePart.getSize() > 0) {
            imagePath = processImageUpload(filePart, request);
        } else if (imagePath == null || imagePath.trim().isEmpty()) {
            imagePath = "assets/images/placeholder.jpg";
        }

        Product product = new Product();
        product.setProductId(productId);
        product.setCategoryId(categoryId);
        product.setName(name);
        product.setDescription(description);
        product.setPrice(price);
        product.setStockQty(stockQty);
        product.setImagePath(imagePath);
        product.setActive(active);

        productService.saveProduct(product);
        request.getSession().setAttribute("successMessage", "Product saved successfully!");
        response.sendRedirect(request.getContextPath() + "/admin/products");
    }

    private void handleToggleStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        long productId = Long.parseLong(request.getParameter("productId"));
        boolean currentActive = Boolean.parseBoolean(request.getParameter("currentActive"));

        productService.toggleProductStatus(productId, !currentActive);
        request.getSession().setAttribute("successMessage", "Product status updated.");
        response.sendRedirect(request.getContextPath() + "/admin/products");
    }

    private String processImageUpload(Part filePart, HttpServletRequest request) throws AppException {
        String submittedName = ValidationUtil.sanitizeFileName(filePart.getSubmittedFileName());
        if (submittedName == null || !submittedName.contains(".")) {
            throw new AppException("Invalid image file name.");
        }

        String ext = submittedName.substring(submittedName.lastIndexOf('.')).toLowerCase();
        if (!ALLOWED_EXTENSIONS.contains(ext)) {
            throw new AppException("Unsupported image format. Allowed formats: " + ALLOWED_EXTENSIONS);
        }

        String mimeType = filePart.getContentType();
        if (mimeType == null || !mimeType.startsWith("image/")) {
            throw new AppException("Uploaded file is not a valid image.");
        }

        // Validate image content signature (magic bytes) to prevent disguised executable uploads
        byte[] header = new byte[12];
        try (InputStream in = filePart.getInputStream()) {
            int bytesRead = in.read(header);
            if (bytesRead < 12 || !isValidImageHeader(header, ext)) {
                throw new AppException("File content does not match a recognized, permitted image format.");
            }
        } catch (IOException e) {
            throw new AppException("Unable to verify uploaded image content.");
        }

        // Generate unique server-side filename
        String safeName = UUID.randomUUID().toString() + ext;
        String uploadDirPath = request.getServletContext().getRealPath("/assets/images/uploads");

        File uploadDir = new File(uploadDirPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        File targetFile = new File(uploadDir, safeName);
        try (InputStream in = filePart.getInputStream()) {
            Files.copy(in, targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Failed to write image file", e);
            throw new AppException("Failed to store uploaded image.");
        }

        return "assets/images/uploads/" + safeName;
    }

    private static boolean isValidImageHeader(byte[] b, String ext) {
        if (b == null || b.length < 12) return false;

        // JPEG: FF D8 FF
        if ((".jpg".equals(ext) || ".jpeg".equals(ext))
                && (b[0] & 0xFF) == 0xFF && (b[1] & 0xFF) == 0xD8 && (b[2] & 0xFF) == 0xFF) {
            return true;
        }

        // PNG: 89 50 4E 47 0D 0A 1A 0A
        if (".png".equals(ext)
                && (b[0] & 0xFF) == 0x89 && (b[1] & 0xFF) == 0x50
                && (b[2] & 0xFF) == 0x4E && (b[3] & 0xFF) == 0x47) {
            return true;
        }

        // WEBP: RIFF....WEBP
        if (".webp".equals(ext)
                && b[0] == 'R' && b[1] == 'I' && b[2] == 'F' && b[3] == 'F'
                && b[8] == 'W' && b[9] == 'E' && b[10] == 'B' && b[11] == 'P') {
            return true;
        }

        return false;
    }
}
