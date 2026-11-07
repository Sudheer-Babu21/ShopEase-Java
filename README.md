# ShopEase - Online Shopping Cart Web Application

A robust, enterprise-grade, database-driven **Online Shopping Cart Web Application** built from scratch in Java using Servlets 4.0, JDBC with connection pooling and concurrency control, Oracle Database XE 10g, Apache Tomcat 9.0.120, BCrypt security, and modern Bootstrap 5 styling.

---

## 1. Project Overview

ShopEase delivers a secure and responsive e-commerce web platform featuring separate interfaces and capabilities for two distinct roles:

1. **Customer**:
   - Browse catalog with keyword search and category filtering
   - Sort products by price (low/high) and title
   - Oracle 10g compatible `ROWNUM` pagination
   - View rich product details and live inventory availability
   - Persistent database-backed shopping cart (login required)
   - Concurrency-safe atomic checkout with database row locking (`FOR UPDATE`)
   - Cash on Delivery (COD) and Mock Payment simulation
   - Customer order history with historical unit purchase price preservation
   - Profile management and self-service password update

2. **Administrator**:
   - Executive dashboard with net revenue, order volume, pending status, and low-stock alerts
   - Full Product lifecycle management: add, edit, price/stock adjustments, soft deactivation/reactivation
   - Safe multipart image upload with MIME validation, size limits (2MB), and random filename hashing
   - Category management with foreign-key referential integrity protection
   - Order fulfillment workflow with finite state machine validation (`PLACED` &rarr; `PACKED` &rarr; `SHIPPED` &rarr; `DELIVERED` or `CANCELLED`)
   - Automatic inventory replenishment upon order cancellation
   - User directory audit view (strictly protects BCrypt password hashes)

---

## 2. Mandatory Technology Stack

| Component | Specification |
|---|---|
| **Language & Runtime** | Java 21 (JDK 21.0.12 LTS) |
| **Backend Architecture** | Java Servlets 4.0 (`javax.servlet.*`) |
| **View Layer** | JavaServer Pages (JSP), HTML5, CSS3, Vanilla JS, Bootstrap 5.3.3 |
| **Persistence** | Raw JDBC with `PreparedStatement` & transactions (No ORM / No Spring) |
| **Database** | Oracle Database XE 10g Release 10.2.0.1.0 (`localhost:1521:XE`) |
| **Application Server** | Apache Tomcat 9.0.120 (`HTTP Port 8086`) |
| **Build & Packaging** | Apache Maven 3.9.9 (`WAR` packaging) |
| **Password Security** | BCrypt (`org.mindrot:jbcrypt:0.4`) |
| **Context Path** | `/OnlineShoppingCart` |

---

## 3. Project Directory Structure

```
OnlineShoppingCart/
├── pom.xml                                      # Maven build configuration
├── mvn.cmd                                      # Self-contained Maven wrapper script
├── README.md                                    # Comprehensive system documentation
├── .gitignore                                   # Git ignore rules
├── database/                                    # Oracle XE 10g SQL scripts
│   ├── 01_create_user.sql                       # User & privilege provisioning
│   ├── 02_create_tables.sql                     # Relational DDL, PKs, FKs, CHECKs, indexes
│   ├── 03_create_sequences.sql                  # Primary key sequences
│   ├── 04_sample_data.sql                       # Seed categories, products, test users
│   └── 05_verification.sql                      # Schema validation & integrity checks
└── src/
    ├── main/
    │   ├── java/com/shoppingcart/
    │   │   ├── exception/
    │   │   │   └── AppException.java            # Centralized business/DB runtime exception
    │   │   ├── util/
    │   │   │   ├── DBConnection.java            # JNDI & DriverManager connection provider
    │   │   │   ├── PasswordUtil.java            # BCrypt password hasher & verifier
    │   │   │   ├── ValidationUtil.java          # Input validator, XSS escaping, filename sanitizer
    │   │   │   ├── CSRFUtil.java                # Cryptographic CSRF token manager
    │   │   │   └── AdminSetupUtil.java          # Secure CLI tool for initial admin setup
    │   │   ├── model/
    │   │   │   ├── User.java                    # Customer & Admin user model
    │   │   │   ├── Category.java                # Product category model
    │   │   │   ├── Product.java                 # Catalog item with stock & active flag
    │   │   │   ├── CartItem.java                # Customer persistent cart line item
    │   │   │   ├── Order.java                   # Customer order header & status
    │   │   │   └── OrderItem.java               # Immutable line item with historical unit price
    │   │   ├── dao/
    │   │   │   ├── UserDAO.java                 # User persistence
    │   │   │   ├── CategoryDAO.java             # Category CRUD & constraint checks
    │   │   │   ├── ProductDAO.java              # Product CRUD & Oracle ROWNUM pagination
    │   │   │   ├── CartDAO.java                 # Persistent cart queries & modifications
    │   │   │   └── OrderDAO.java                # Transactional order inserts & dashboard metrics
    │   │   ├── service/
    │   │   │   ├── AuthService.java             # Authentication & customer registration
    │   │   │   ├── ProductService.java          # Catalog operations & category management
    │   │   │   ├── CartService.java             # Cart validations & stock bounds
    │   │   │   ├── CheckoutService.java         # Concurrency-safe 15-step checkout transaction
    │   │   │   └── OrderService.java            # Order tracking, state machine & inventory restore
    │   │   ├── filter/
    │   │   │   ├── CharacterEncodingFilter.java # Global UTF-8 encoding filter
    │   │   │   ├── AuthenticationFilter.java    # Route protector for /cart, /checkout, /orders, /profile
    │   │   │   └── AdminAuthorizationFilter.java# RBAC protector for /admin/*
    │   │   └── servlet/
    │   │       ├── AuthServlet.java             # Login & Registration controller
    │   │       ├── LogoutServlet.java           # Session termination controller
    │   │       ├── ProductServlet.java          # Storefront catalog & details controller
    │   │       ├── CartServlet.java             # Cart viewing, adding, updating, removing
    │   │       ├── CheckoutServlet.java         # Checkout address & payment controller
    │   │       ├── OrderServlet.java            # Customer order history & tracking
    │   │       ├── ProfileServlet.java          # Customer account management
    │   │       └── admin/
    │   │           ├── AdminDashboardServlet.java # Admin metrics & low-stock alerts
    │   │           ├── AdminProductServlet.java   # Product CRUD & image upload
    │   │           ├── AdminCategoryServlet.java  # Category management
    │   │           ├── AdminOrderServlet.java     # Order status transitions & fulfillment
    │   │           └── AdminUserServlet.java      # Customer account directory audit
    │   └── webapp/
    │       ├── index.jsp                        # Entrypoint redirect to /products
    │       ├── assets/
    │       │   ├── css/style.css                # Custom modern stylesheet
    │       │   ├── js/app.js                    # Interactive UI handlers & image preview
    │       │   └── images/                      # Seed product JPGs & fallback images
    │       │       └── uploads/                 # Target folder for admin image uploads
    │       └── WEB-INF/
    │           ├── web.xml                      # Deployment descriptor (Session & error pages)
    │           └── views/
    │               ├── common/                  # Reusable headers & footers
    │               ├── auth/                    # Login & Register views
    │               ├── products/                # Catalog & Detail views
    │               ├── cart/                    # Cart view
    │               ├── checkout/                # Checkout form & payment selector
    │               ├── orders/                  # Order history & confirmation views
    │               ├── profile/                 # Customer profile view
    │               ├── errors/                  # Custom 403, 404, 500 error pages
    │               └── admin/                   # Admin dashboard, products, categories, orders, users
    └── test/
        └── java/com/shoppingcart/
            ├── util/ValidationUtilTest.java     # Validation and sanitization tests
            ├── util/PasswordUtilTest.java       # BCrypt hashing & verification tests
            ├── service/CartServiceTest.java     # Cart total calculation tests
            └── dao/OracleIntegrationTest.java   # Live Oracle XE database integration test
```

---

## 4. Prerequisites & Environment Verification

Before running, confirm your local Windows 11 environment has:

1. **Oracle Database XE 10g**:
   - Listener: `localhost:1521`
   - SID: `XE`
   - Services Running: `OracleServiceXE` and `OracleXETNSListener`
2. **Java Development Kit**:
   - JDK 21 installed at `C:\Program Files\Java\jdk-21.0.12`
3. **Apache Tomcat**:
   - Tomcat 9.0.120 installed at `C:\Program Files\Apache Software Foundation\Tomcat 9.0`
4. **Oracle JDBC Driver**:
   - `D:\ojdbc14.jar` or `C:\oraclexe\app\oracle\product\10.2.0\server\jdbc\lib\ojdbc14.jar`

---

## 5. Oracle Database Setup & Execution Order

All database scripts are in `database/`. Execute them in the exact numerical order shown below.

### Step 5.1: Create Application User (as SYSDBA)

Open PowerShell and run SQL*Plus as SYSDBA:
```powershell
& "C:\oraclexe\app\oracle\product\10.2.0\server\bin\sqlplus.exe" "/ as sysdba" @database/01_create_user.sql
```
*Creates user `shoppingcart` identified by `shoppingcart123` with `CONNECT`, `RESOURCE`, and `CREATE VIEW` privileges.*

### Step 5.2: Create Tables, Sequences, Seed Data & Verify (as `shoppingcart`)

Run scripts 02 through 05 as `shoppingcart`:
```powershell
& "C:\oraclexe\app\oracle\product\10.2.0\server\bin\sqlplus.exe" "shoppingcart/shoppingcart123@localhost:1521/XE" @database/02_create_tables.sql
& "C:\oraclexe\app\oracle\product\10.2.0\server\bin\sqlplus.exe" "shoppingcart/shoppingcart123@localhost:1521/XE" @database/03_create_sequences.sql
& "C:\oraclexe\app\oracle\product\10.2.0\server\bin\sqlplus.exe" "shoppingcart/shoppingcart123@localhost:1521/XE" @database/04_sample_data.sql
& "C:\oraclexe\app\oracle\product\10.2.0\server\bin\sqlplus.exe" "shoppingcart/shoppingcart123@localhost:1521/XE" @database/05_verification.sql
```

Verification script output confirms:
- **6 Tables**: `USERS`, `CATEGORIES`, `PRODUCTS`, `CART_ITEMS`, `ORDERS`, `ORDER_ITEMS`
- **6 Sequences**: `SEQ_USERS`, `SEQ_CATEGORIES`, `SEQ_PRODUCTS`, `SEQ_CART_ITEMS`, `SEQ_ORDERS`, `SEQ_ORDER_ITEMS`
- **10 Check Constraints**: Non-negative prices/stock, allowed statuses, roles, and payment modes.

---

## 6. Oracle JDBC Driver Placement

To enable database operations across both Tomcat standalone and Eclipse:

### 1. Tomcat Shared Library (Mandatory for Tomcat runtime)
Copy `D:\ojdbc14.jar` into Tomcat's `lib` directory:
```powershell
Copy-Item "D:\ojdbc14.jar" -Destination "C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\ojdbc14.jar" -Force
```

### 2. Maven Local Repository (Pre-installed)
The driver has been installed into your local Maven cache under coordinates:
- `groupId`: `com.oracle`
- `artifactId`: `ojdbc14`
- `version`: `10.2.0.4.0`

---

## 7. How to Build with Maven

The project root includes a wrapper script `.\mvn.cmd` configured to use JDK 21 and the embedded Maven runtime:

### Clean and Build WAR:
```powershell
.\mvn.cmd clean package
```

### Run Unit and Database Integration Tests:
```powershell
.\mvn.cmd test
```

Build artifact generated:
`target/OnlineShoppingCart.war` (Size: ~1.7 MB)

---

## 8. Apache Tomcat 9.0.120 Configuration (Port 8086)

### Step 8.1: Configure HTTP Connector Port to 8086
Open `C:\Program Files\Apache Software Foundation\Tomcat 9.0\conf\server.xml` and update the HTTP Connector to port `8086`:
```xml
<Connector port="8086" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

### Step 8.2: Deploy Application WAR
Copy `target\OnlineShoppingCart.war` to Tomcat's `webapps` folder:
```powershell
Copy-Item "target\OnlineShoppingCart.war" -Destination "C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\OnlineShoppingCart.war" -Force
```

### Step 8.3: Start Tomcat Server
In PowerShell:
```powershell
$env:CATALINA_HOME = "C:\Program Files\Apache Software Foundation\Tomcat 9.0"
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21.0.12"
& "$env:CATALINA_HOME\bin\startup.bat"
```

---

## 9. Setting Up and Running in Eclipse IDE

1. Launch **Eclipse JEE** (`C:\Users\USER\eclipse\jee-2025-06\eclipse\eclipse.exe`).
2. Go to **File &rarr; Import... &rarr; Maven &rarr; Existing Maven Projects**.
3. Browse to `C:\Users\USER\eclipse-workspace-web\onlineshoppingcart\OnlineShoppingCart` and click **Finish**.
4. In the **Servers** tab:
   - Click **New &rarr; Server &rarr; Apache &rarr; Tomcat v9.0 Server**.
   - Point the Tomcat installation directory to `C:\Program Files\Apache Software Foundation\Tomcat 9.0`.
   - Select JRE: `JavaSE-21` (`C:\Program Files\Java\jdk-21.0.12`).
   - Double-click the server in the Servers view and change the HTTP port to `8086`.
   - Right-click Tomcat server &rarr; **Add and Remove...** &rarr; Add `OnlineShoppingCart` &rarr; Click **Finish**.
   - Start the server.

---

## 10. Accessing the Web Application

Open your browser and navigate to:

- **Customer Storefront**:
  `http://localhost:8086/OnlineShoppingCart/products`
- **Customer Sign In**:
  `http://localhost:8086/OnlineShoppingCart/auth/login`
- **Customer Registration**:
  `http://localhost:8086/OnlineShoppingCart/auth/register`
- **Admin Console**:
  `http://localhost:8086/OnlineShoppingCart/admin/dashboard`

---

## 11. Initial Accounts and Testing Credentials

The database seed provides two demonstration accounts hashed with BCrypt (log rounds = 10):

| Role | Email | Password | Allowed Access |
|---|---|---|---|
| **Administrator** | `admin@shoppingcart.com` | `Admin@123` | Full Admin Console (`/admin/*`) & Storefront |
| **Customer** | `john@example.com` | `Customer@123` | Storefront, Cart, Checkout, Order History |

### Initializing Custom Administrator Accounts (CLI Setup Tool):
To create or reset an administrator account securely outside of public HTTP endpoints:
```powershell
& "C:\Program Files\Java\jdk-21.0.12\bin\java.exe" -cp "target\classes;D:\ojdbc14.jar;C:\Users\USER\.m2\repository\org\mindrot\jbcrypt\0.4\jbcrypt-0.4.jar" com.shoppingcart.util.AdminSetupUtil "Super Admin" "superadmin@shoppingcart.com" "SecureAdmin@2026" "9876543200"
```

---

## 12. Security Implementation Details

1. **SQL Injection Prevention**: 100% of SQL queries utilize parameterized `PreparedStatement`. No untrusted input is concatenated into SQL strings.
2. **Password Security**: Passwords are never stored in plaintext and never logged. BCrypt with 10 salt rounds is applied.
3. **Session Fixation Defense**: Successful authentication invokes `HttpServletRequest.changeSessionId()` to renew the session identifier upon login.
4. **Authorization Enforcement**: 
   - Public customer registration strictly hardcodes `role = 'CUSTOMER'` to prevent privilege escalation.
   - Server-side `AdminAuthorizationFilter` checks `user.isAdmin()` on the server session for all `/admin/*` URLs and yields HTTP 403 on violations.
   - Customers can only access their own orders (`order.userId == currentUser.userId`). Attempting to manipulate `id` in the URL yields an Access Denied error.
5. **CSRF Protection**: All state-modifying POST requests (`/cart/add`, `/cart/update`, `/cart/remove`, `/checkout`, `/admin/*`) require a cryptographically random, session-validated CSRF token.
6. **XSS Protection**: HTML escaping (`ValidationUtil.escapeHtml()`) is applied across all user-supplied outputs.
7. **Safe Image Uploads**: Admin product uploads enforce a 2MB max file size, validate MIME types against `image/*`, generate random UUID filenames, and strip path traversal characters.
8. **Concurrency Control & Inventory Lock**: The checkout flow disables auto-commit, locks relevant product rows in ascending ID order using `SELECT ... FOR UPDATE`, validates stock, and performs conditional updates (`WHERE STOCK_QTY >= ?`) before clearing the cart and committing.

---

## 13. Manual Integration Test Checklist (30 Test Cases)

| # | Test Scenario | Expected Result | Status |
|---|---|---|---|
| 1 | Database schema verification | All 6 tables, sequences, and constraints exist | PASS (Verified via `05_verification.sql`) |
| 2 | JDBC connection | Driver connects to `localhost:1521:XE` | PASS (Verified via `OracleIntegrationTest`) |
| 3 | Customer registration | New user inserted with `CUSTOMER` role & BCrypt hash | PASS |
| 4 | Duplicate email rejection | Form displays error; second registration blocked | PASS |
| 5 | Login with valid credentials | Session created; session ID renewed; redirect to store | PASS |
| 6 | Rejection of invalid credentials | Generic error displayed; no session created | PASS |
| 7 | Logout operation | Session invalidated; redirected to login with logout notice | PASS |
| 8 | Product search | Matches keyword in title or description | PASS |
| 9 | Category filtering | Lists only products in selected category | PASS |
| 10 | ROWNUM pagination | Correct slice of items displayed; page count accurate | PASS (Verified via `OracleIntegrationTest`) |
| 11 | Add-to-cart operation | Item added to `CART_ITEMS` with quantity | PASS |
| 12 | Cart quantity update | Quantity and subtotal update dynamically | PASS |
| 13 | Cart removal | Line item removed; total recomputed | PASS |
| 14 | Rejection of invalid quantities | Values &le; 0 or &gt; available stock rejected | PASS |
| 15 | Checkout with COD | Order created with `COD` payment method; cart cleared | PASS |
| 16 | Checkout with Mock payment | Order created with `MOCK` payment method; cart cleared | PASS |
| 17 | Concurrency stock reduction | `STOCK_QTY` decreased by purchase count atomically | PASS |
| 18 | Rollback on checkout failure | If stock insufficient, entire transaction rolls back | PASS |
| 19 | Insufficient-stock handling | Rejects checkout with clear error message | PASS |
| 20 | Order history | Customer sees their past orders and item details | PASS |
| 21 | Unauthorized access to another user's order | Attempting to view another user's order ID returns 403 | PASS |
| 22 | Admin product CRUD | Admin can create, edit, and view products | PASS |
| 23 | Admin category management | Categories can be added, updated; deletion blocked if products exist | PASS |
| 24 | Admin order status changes | Follows allowed lifecycle (`PLACED` &rarr; `PACKED` &rarr; `SHIPPED` &rarr; `DELIVERED`) | PASS |
| 25 | Unauthorized access to admin endpoints | Non-admin redirected to 403 Forbidden page | PASS |
| 26 | CSRF token rejection | Requests with missing or altered token return error | PASS |
| 27 | Invalid image upload rejection | Non-image files or files &gt; 2MB rejected | PASS |
| 28 | Session expiration & logout | Expired sessions redirect to login with notification | PASS |
| 29 | Empty catalog & empty cart handling | Clean empty-state screens displayed | PASS |
| 30 | Clean Maven build & packaging | `OnlineShoppingCart.war` builds with zero errors | PASS (Verified via `.\mvn.cmd clean package`) |

---

## 14. Troubleshooting & FAQ

1. **ORA-00911: invalid character during SQL script execution**:
   - Ensure `SET DEFINE OFF;` is present at the beginning of SQL files containing ampersands (e.g. `Home & Kitchen`).
2. **HTTP 404 on Tomcat startup**:
   - Verify Tomcat HTTP connector port in `conf/server.xml` is set to `8086`.
   - Ensure the WAR was copied to `webapps/OnlineShoppingCart.war`.
3. **`ClassNotFoundException: oracle.jdbc.OracleDriver` in Tomcat**:
   - Confirm `ojdbc14.jar` was copied to `C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\`.
4. **Mock Payment Notice**:
   - Mock payment is strictly a demonstration feature to simulate card approval. No real payment gateways or credit cards are accepted.
