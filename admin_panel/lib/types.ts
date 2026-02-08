export interface Product {
  id: string;
  name: string;
  description?: string;
  sku?: string;
  price_cents: number;
  stock: number;
  active: boolean;
  created_at: string;
  metadata?: Record<string, any>;
  categories?: Category[];
  images?: ProductImage[];
  variants?: ProductVariant[];
  rating?: number;
  review_count?: number;
  delivery_minutes?: number;
  weight?: string;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  position?: number;
}

export interface ProductVariant {
  id: string;
  name: string;
  price_cents: number;
  weight?: string;
}

export interface ProductImage {
  id: string;
  product_id: string;
  url: string;
  position: number;
}

export interface AddProductVariant {
  name: string;
  price_cents: number;
  weight?: string;
}

export interface AddProductImage {
  url: string;
  position: number;
}

export interface AddProduct {
  name: string;
  description?: string;
  sku?: string;
  price_cents: number;
  stock: number;
  active: boolean;
  category_ids: string[];
  metadata?: Record<string, any>;
  variants?: AddProductVariant[];
  images?: AddProductImage[];
  weight?: string; 
  mrp_cents?: number;
}

export interface Order {
  id: string;
  user_id: string;
  subtotal_cents: number;
  shipping_cents: number;
  tax_cents: number;
  total_cents: number;
  status: OrderStatus;
  placed_at: string;
  shipping_address?: Record<string, any>;
  payment_metadata?: Record<string, any>;
  items?: OrderItem[];
}

export interface OrderItem {
  id: string;
  order_id: string;
  product_id: string;
  quantity: number;
  unit_price_cents: number;
}

export type OrderStatus = "pending" | "confirmed" | "processing" | "shipped" | "delivered" | "cancelled";
