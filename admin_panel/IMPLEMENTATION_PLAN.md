# Admin Panel Implementation Plan

This document outlines the plan for implementing the **Excel Product Upload** feature, along with the **Order Management System** and **Analytics Dashboard**.

## 1. Feature: Bulk Product Upload via Excel
**Goal:** Allow admins to upload a `.xlsx` or `.csv` file containing multiple products to populate the database efficiently.

### 1.1. Technology Stack
- **Frontend library:** `xlsx` (SheetJS) for parsing Excel files in the browser.
- **UI Components:** `lucide-react` for icons, `shadcn/ui` components (Table, Button, Progress, Alert).

### 1.2. Workflow
1.  **File Selection:**
    - user navigates to `/products/import`.
    - Drag-and-drop zone or "Select File" button.
2.  **Client-Side Parsing:**
    - The file is read and parsed into a JSON array.
    - **Header Validation:** Ensure columns match expected fields: `Name`, `Description`, `Price`, `Stock`, `Category`, `ImageURL` (optional).
3.  **Data Validation & Mapping:**
    - **Price:** Convert "10.99" to cents (`1099`).
    - **Categories:** Fetch all categories from `GET /api/categories`. Match the text in the "Category" column (e.g., "Electronics") to the corresponding UUID. If no match is found, flag as an error or create a "Uncategorized" tag.
    - **Validation:** Ensure required fields (`Name`, `Price`, `Stock`) are present.
4.  **Batch Upload:**
    - Iterate through valid rows.
    - Send a `POST /api/products` request for each item.
    - Display a **Progress Bar** (e.g., "Importing 10/50...").
5.  **Completion Report:**
    - Show a summary: "45 products imported successfully, 5 failed."
    - List detailed errors for failed rows (e.g., "Row 4: Invalid price").

### 1.3. Expected Excel Structure
| Name | Description | Price | Stock | Active | SKU | Category | Rating |
|------|-------------|-------|-------|--------|-----|----------|--------|
| Apple | Red fruit | 1.50 | 100 | TRUE | AP-001 | Fruits | 4.5 |
| Bread | Whole wheat | 2.00 | 50 | TRUE | BR-002 | Bakery | 4.0 |

---

## 2. Feature: Order Management System (Most Important)
**Goal:** Enable admins to view, process, and update customer orders.

### 2.1. Key Components
1.  **Order List View (`/orders`)**:
    - A data table displaying all orders.
    - **Columns:** Order ID, Customer Name, Date, Total Amount, Status (Pending, Shipped, Delivered, Cancelled).
    - **Filters:** Filter by Status or Date range.
    - **API:** `GET /api/orders` (requires Admin privileges).
2.  **Order Details View (`/orders/[id]`)**:
    - Detailed view of a specific order.
    - **Sections:**
        - Customer Info (Name, Address).
        - Line Items (Product Name, Qty, Price).
        - Order Summary (Subtotal, Tax, Total).
    - **API:** `GET /api/orders/{id}`.
3.  **Status Workflow**:
    - Action buttons to change status:
        - "Mark as Shipped"
        - "Mark as Delivered"
        - "Cancel Order"
    - **API:** `PUT /api/orders/{id}/status`.

---

## 3. Feature: Analytics Dashboard (Most Useful)
**Goal:** Replace hardcoded dashboard data with real-time insights to drive business decisions.

### 3.1. Key Metrics
1.  **Total Revenue:** Sum of all `paid` orders.
2.  **Order Volume:** Number of orders placed today/this week.
3.  **Low Stock Alerts:** List products where `stock < 10` to prompt restocking.
4.  **Top Selling Products:** Bar chart showing top 5 products by quantity sold.

### 3.2. Implementation Strategy
- **Frontend Aggregation (Phase 1):**
    - Fetch all orders via `GET /api/orders` on load.
    - Calculate metrics client-side (suitable for < 1000 orders).
- **Backend Aggregation (Phase 2):**
    - Create a dedicated endpoint `GET /api/admin/analytics` that returns pre-calculated stats (using SQL `COUNT`, `SUM`, etc.) for performance.

---

## 4. Next Steps
1.  **Approve Plan:** Confirm this roadmap.
2.  **Install Dependencies:** `npm install xlsx` in `admin_panel`.
3.  **Scaffold Import Page:** Create `app/products/import/page.tsx`.
