"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation"; // Correct import
import { 
  ArrowLeft, 
  MapPin, 
  CreditCard, 
  Package, 
  Truck, 
  CheckCircle, 
  XCircle,
  Clock,
  Printer
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Order, OrderStatus } from "@/lib/types";
import api from "@/lib/api";
import { formatCurrency, formatDate } from "@/lib/format";

const statusSteps: OrderStatus[] = ["pending", "confirmed", "processing", "shipped", "delivered"];

export default function OrderDetailsPage() {
  const params = useParams();
  const router = useRouter();
  const id = params?.id as string;

  const [order, setOrder] = useState<Order | null>(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);

  useEffect(() => {
    if (id) fetchOrder();
  }, [id]);

  const fetchOrder = async () => {
    try {
      setLoading(true);
      const res = await api.get(`/orders/${id}`);
      setOrder(res.data);
    } catch (err) {
      console.error("Failed to fetch order", err);
      // alert("Failed to load order details");
    } finally {
      setLoading(false);
    }
  };

  const handleStatusUpdate = async (newStatus: OrderStatus) => {
    if (!order) return;
    try {
      setUpdating(true);
      await api.put(`/orders/${order.id}/status`, { status: newStatus });
      setOrder({ ...order, status: newStatus });
    } catch (err) {
      console.error("Failed to update status", err);
      alert("Failed to update status");
    } finally {
      setUpdating(false);
    }
  };

  if (loading) {
    return <div className="p-8 text-center text-muted-foreground">Loading order details...</div>;
  }

  if (!order) {
    return (
      <div className="p-8 text-center space-y-4">
        <div className="text-red-500">Order not found</div>
        <Button onClick={() => router.back()}>Go Back</Button>
      </div>
    );
  }

  const currentStepIndex = statusSteps.indexOf(order.status);
  const isCancelled = order.status === "cancelled";

  return (
    <div className="p-8 space-y-8 max-w-5xl mx-auto">
      <div className="flex items-center gap-4">
        <Button variant="outline" size="icon" onClick={() => router.back()}>
          <ArrowLeft className="h-4 w-4" />
        </Button>
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Order #{order.id.slice(0, 8)}</h1>
          <p className="text-muted-foreground flex items-center gap-2 text-sm mt-1">
            <Clock className="h-3 w-3" />
            Placed on {formatDate(order.placed_at)}
          </p>
        </div>
        <div className="ml-auto flex gap-2">
          <Button variant="outline" onClick={() => window.print()}>
            <Printer className="mr-2 h-4 w-4" />
            Print
          </Button>
          {!isCancelled && order.status !== "delivered" && (
            <Button 
               variant="destructive" 
               onClick={() => handleStatusUpdate("cancelled")}
               disabled={updating}
            >
              Cancel Order
            </Button>
          )}
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        <div className="md:col-span-2 space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Order Items</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {order.items?.map((item, idx) => (
                  <div key={idx} className="flex justify-between items-start border-b last:border-0 pb-4 last:pb-0">
                    <div>
                      <div className="font-medium text-base">{item.product_id} (Product Name Placeholder)</div>
                      <div className="text-sm text-muted-foreground">Qty: {item.quantity}</div>
                    </div>
                    <div className="text-right font-medium">
                      {formatCurrency(item.unit_price_cents * item.quantity)}
                    </div>
                  </div>
                ))}
                <div className="pt-4 border-t flex justify-between font-bold text-lg">
                  <span>Total</span>
                  <span>{formatCurrency(order.total_cents)}</span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Status Workflow */}
          <Card>
            <CardHeader>
              <CardTitle>Order Status</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="relative flex justify-between mb-8">
                 {/* Progress Bar Background */}
                 <div className="absolute top-1/2 left-0 right-0 h-1 bg-muted -translate-y-1/2 z-0" />
                 
                 {/* Active Progress */}
                 {!isCancelled && (
                   <div 
                     className="absolute top-1/2 left-0 h-1 bg-primary -translate-y-1/2 z-0 transition-all duration-500"
                     style={{ width: `${(currentStepIndex / (statusSteps.length - 1)) * 100}%` }}
                   />
                 )}

                 {statusSteps.map((step, idx) => {
                   const isActive = idx <= currentStepIndex && !isCancelled;
                   const isCurrent = idx === currentStepIndex && !isCancelled;
                   return (
                     <div key={step} className="relative z-10 flex flex-col items-center gap-2 bg-background p-2 -my-2">
                       <div className={`w-8 h-8 rounded-full flex items-center justify-center border-2 transition-colors ${
                         isActive ? "bg-primary border-primary text-primary-foreground" : "bg-muted border-muted-foreground text-muted-foreground"
                       }`}>
                         {idx < currentStepIndex ? <CheckCircle className="h-4 w-4" /> : <div className="h-2 w-2 rounded-full bg-current" />}
                       </div>
                       <span className="text-xs font-medium capitalize">{step}</span>
                     </div>
                   );
                 })}
              </div>

              {!isCancelled && order.status !== "delivered" && (
                <div className="flex justify-end gap-2">
                  <span className="text-sm text-muted-foreground self-center mr-2">Move to next step:</span>
                   {currentStepIndex < statusSteps.length - 1 && (
                      <Button 
                        onClick={() => handleStatusUpdate(statusSteps[currentStepIndex + 1])}
                        disabled={updating}
                      >
                        Mark as {statusSteps[currentStepIndex + 1]}
                      </Button>
                   )}
                </div>
              )}
              {isCancelled && (
                <div className="bg-red-50 text-red-600 p-4 rounded-lg flex items-center gap-2">
                  <XCircle className="h-5 w-5" />
                  <span className="font-medium">This order has been cancelled.</span>
                </div>
              )}
            </CardContent>
          </Card>
        </div>

        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Customer Details</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-start gap-3">
                <div className="p-2 bg-muted rounded-full">
                  <MapPin className="h-4 w-4 text-muted-foreground" />
                </div>
                <div className="text-sm">
                  <div className="font-medium">Shipping Address</div>
                  <div className="text-muted-foreground mt-1">
                    {order.shipping_address?.name}<br />
                    {order.shipping_address?.street}<br />
                    {order.shipping_address?.city}, {order.shipping_address?.state} {order.shipping_address?.zip}<br />
                    {order.shipping_address?.country}
                  </div>
                </div>
              </div>
              <div className="flex items-start gap-3">
                 <div className="p-2 bg-muted rounded-full">
                  <CreditCard className="h-4 w-4 text-muted-foreground" />
                </div>
                <div className="text-sm">
                  <div className="font-medium">Payment Info</div>
                  <div className="text-muted-foreground mt-1">
                    Via {order.payment_metadata?.provider || "Stripe"}
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
