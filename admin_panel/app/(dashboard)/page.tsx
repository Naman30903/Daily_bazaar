"use client";

import { useEffect, useState } from "react";
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  Tooltip, 
  ResponsiveContainer, 
  LineChart, 
  Line, 
  AreaChart, 
  Area 
} from "recharts";
import { 
  TrendingUp, 
  Users, 
  DollarSign, 
  CreditCard, 
  AlertTriangle, 
  ShoppingBag,
  ArrowRight
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import api from "@/lib/api";
import { Order, Product, OrderStatus } from "@/lib/types";
import { formatCurrency } from "@/lib/format";
import Link from "next/link";

interface DashboardStats {
  revenue: number;
  orders: number;
  activeProducts: number;
  lowStockCount: number;
  recentOrders: Order[];
  salesData: { name: string; sales: number }[];
}

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats>({
    revenue: 0,
    orders: 0,
    activeProducts: 0,
    lowStockCount: 0,
    recentOrders: [],
    salesData: []
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        const [ordersRes, productsRes] = await Promise.all([
          api.get("/orders?limit=1000"), // Fetch recent 1000 orders
          api.get("/products?limit=1000") // Fetch up to 1000 products
        ]);

        const orders: Order[] = ordersRes.data || [];
        const products: Product[] = productsRes.data || [];

        // 1. Calculate Total Revenue (paid orders)
        // Assume non-cancelled/non-pending orders count as revenue, or just 'delivered'/'shipped'
        const validOrders = orders.filter(o => o.status !== "cancelled");
        const revenue = validOrders.reduce((sum, o) => sum + o.total_cents, 0);

        // 2. Counts
        const orderCount = orders.length;
        const activeProducts = products.filter(p => p.active).length;
        const lowStockCount = products.filter(p => p.stock < 10).length;

        // 3. Sales Data (Last 7 Days)
        const salesMap = new Map<string, number>();
        const today = new Date();
        for (let i = 6; i >= 0; i--) {
          const d = new Date(today);
          d.setDate(d.getDate() - i);
          const key = d.toLocaleDateString("en-US", { weekday: 'short' });
          salesMap.set(key, 0);
        }

        validOrders.forEach(o => {
          const d = new Date(o.placed_at);
          // Only count if within last 7 days roughly
          const diffTime = Math.abs(today.getTime() - d.getTime());
          const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
          if (diffDays <= 7) {
            const key = d.toLocaleDateString("en-US", { weekday: 'short' });
            if (salesMap.has(key)) {
              salesMap.set(key, (salesMap.get(key) || 0) + (o.total_cents / 100));
            }
          }
        });

        const salesData = Array.from(salesMap.entries()).map(([name, sales]) => ({ name, sales }));

        setStats({
          revenue,
          orders: orderCount,
          activeProducts,
          lowStockCount,
          recentOrders: orders.slice(0, 5), // Top 5 recent
          salesData
        });

      } catch (error) {
        console.error("Dashboard fetch error", error);
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, []);

  if (loading) {
    return <div className="p-8 flex justify-center"><div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full"/></div>;
  }

  return (
    <div className="space-y-8">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold tracking-tight">Admin Dashboard</h1>
        <div className="flex gap-2">
           <Link href="/products/import">
             <Button variant="outline">
               <TrendingUp className="mr-2 h-4 w-4" />
               Import Products
             </Button>
           </Link>
           <Link href="/products/add">
             <Button>
               <ShoppingBag className="mr-2 h-4 w-4" />
               Add Product
             </Button>
           </Link>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(stats.revenue)}</div>
            <p className="text-xs text-muted-foreground">Lifetime volume</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Orders</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.orders}</div>
            <p className="text-xs text-muted-foreground">Total received</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Products</CardTitle>
            <ShoppingBag className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.activeProducts}</div>
            <p className="text-xs text-muted-foreground">Currently listed</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Low Stock Alerts</CardTitle>
            <AlertTriangle className="h-4 w-4 text-orange-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">{stats.lowStockCount}</div>
            <p className="text-xs text-muted-foreground">Items with stock &lt; 10</p>
          </CardContent>
        </Card>
      </div>

      {/* Charts and Lists */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <Card className="col-span-4">
          <CardHeader>
            <CardTitle>Sales Overview (Last 7 Days)</CardTitle>
          </CardHeader>
          <CardContent className="pl-2">
            <div className="h-[300px] w-full">
               <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={stats.salesData}>
                  <defs>
                    <linearGradient id="colorSales" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#8884d8" stopOpacity={0.8}/>
                      <stop offset="95%" stopColor="#8884d8" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <XAxis dataKey="name" stroke="#888888" fontSize={12} tickLine={false} axisLine={false} />
                  <YAxis stroke="#888888" fontSize={12} tickLine={false} axisLine={false} tickFormatter={(value) => `$${value}`} />
                  <Tooltip 
                    formatter={(value: any) => [`$${Number(value).toFixed(2)}`, "Sales"]}
                    contentStyle={{ backgroundColor: '#1e1e2e', color: '#f3f4f6', border: '1px solid #374151', borderRadius: '8px' }}
                  />
                  <Area type="monotone" dataKey="sales" stroke="#8884d8" fillOpacity={1} fill="url(#colorSales)" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        <Card className="col-span-3">
          <CardHeader>
            <CardTitle>Recent Orders</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-8">
              {stats.recentOrders.map((order, i) => (
                <div key={i} className="flex items-center">
                  <span className="relative flex h-9 w-9 shrink-0 overflow-hidden rounded-full bg-muted items-center justify-center">
                     <Users className="h-4 w-4" />
                  </span>
                  <div className="ml-4 space-y-1">
                    <p className="text-sm font-medium leading-none">{order.shipping_address?.name || "Customer"}</p>
                    <p className="text-xs text-muted-foreground">{order.id.slice(0, 8)}</p>
                  </div>
                  <div className="ml-auto font-medium">+{formatCurrency(order.total_cents)}</div>
                </div>
              ))}
              <Link href="/orders" className="block w-full">
                <Button variant="outline" className="w-full">
                   View All Orders <ArrowRight className="ml-2 h-4 w-4" />
                </Button>
              </Link>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
