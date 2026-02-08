"use client";

import { useEffect, useState } from "react";
import { 
  Loader2, 
  Search, 
  Calendar, 
  MoreHorizontal, 
  CheckCircle, 
  XCircle, 
  Truck, 
  Package,
  Clock
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Order, OrderStatus } from "@/lib/types";
import api from "@/lib/api";
import { formatCurrency, formatDate } from "@/lib/format";
import Link from "next/link";

const statusIcons: Record<OrderStatus, React.ReactNode> = {
  pending: <Clock className="h-4 w-4 text-yellow-500" />,
  confirmed: <CheckCircle className="h-4 w-4 text-blue-500" />,
  processing: <Package className="h-4 w-4 text-purple-500" />,
  shipped: <Truck className="h-4 w-4 text-indigo-500" />,
  delivered: <CheckCircle className="h-4 w-4 text-green-500" />,
  cancelled: <XCircle className="h-4 w-4 text-red-500" />,
};

const statusColors: Record<OrderStatus, string> = {
  pending: "bg-yellow-500/10 text-yellow-500",
  confirmed: "bg-blue-500/10 text-blue-500",
  processing: "bg-purple-500/10 text-purple-500",
  shipped: "bg-indigo-500/10 text-indigo-500",
  delivered: "bg-green-500/10 text-green-500",
  cancelled: "bg-red-500/10 text-red-500",
};

export default function OrderListPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      setLoading(true);
      const res = await api.get("/orders");
      // Sort by date desc (if not already)
      const sorted = (res.data || []).sort((a: Order, b: Order) => 
        new Date(b.placed_at).getTime() - new Date(a.placed_at).getTime()
      );
      setOrders(sorted);
    } catch (err) {
      console.error("Failed to fetch orders", err);
      setError("Failed to load orders");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-8 space-y-8 max-w-7xl mx-auto">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Orders</h1>
          <p className="text-muted-foreground mt-2">
            Manage your store's orders and shipments.
          </p>
        </div>
        <Button onClick={fetchOrders} variant="outline" size="sm">
          Refresh
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Recent Orders</CardTitle>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="flex justify-center p-8">
              <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
            </div>
          ) : error ? (
            <div className="text-center p-8 text-red-500">{error}</div>
          ) : orders.length === 0 ? (
            <div className="text-center p-8 text-muted-foreground">No orders found.</div>
          ) : (
            <div className="relative overflow-x-auto">
              <table className="w-full text-sm text-left">
                <thead className="text-xs uppercase bg-muted/50 text-muted-foreground">
                  <tr>
                    <th className="px-4 py-3">Order ID</th>
                    <th className="px-4 py-3">Date</th>
                    <th className="px-4 py-3">Customer</th>
                    <th className="px-4 py-3">Status</th>
                    <th className="px-4 py-3 text-right">Total</th>
                    <th className="px-4 py-3 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {orders.map((order) => (
                    <tr key={order.id} className="border-b last:border-0 hover:bg-muted/50 transition-colors">
                      <td className="px-4 py-3 font-mono text-muted-foreground">
                        #{order.id.slice(0, 8)}
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-2">
                          <Calendar className="h-3 w-3 text-muted-foreground" />
                          {formatDate(order.placed_at)}
                        </div>
                      </td>
                      <td className="px-4 py-3 font-medium">
                        {order.shipping_address?.name || "Unknown User"}
                        <div className="text-xs text-muted-foreground">{order.user_id}</div>
                      </td>
                      <td className="px-4 py-3">
                        <span className={`inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium ${statusColors[order.status] || "bg-gray-100 text-gray-800"}`}>
                           {statusIcons[order.status]}
                           <span className="capitalize">{order.status}</span>
                        </span>
                      </td>
                      <td className="px-4 py-3 text-right font-medium">
                        {formatCurrency(order.total_cents)}
                      </td>
                      <td className="px-4 py-3 text-right">
                        <Link href={`/orders/${order.id}`}>
                          <Button variant="ghost" size="sm">
                            View
                          </Button>
                        </Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
