"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { 
  LayoutDashboard, 
  ShoppingBag, 
  Package, 
  Settings, 
  LogOut,
  Upload
} from "lucide-react";
import { Button } from "@/components/ui/button";

const navItems = [
  { href: "/", label: "Dashboard", icon: LayoutDashboard },
  { href: "/orders", label: "Orders", icon: Package },
  { href: "/products", label: "Products", icon: ShoppingBag },
  { href: "/products/import", label: "Import Products", icon: Upload }, // Direct link for now
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <div className="w-64 border-r border-sidebar-border bg-sidebar min-h-screen flex flex-col fixed left-0 top-0 bottom-0 z-50">
      <div className="p-6 border-b border-sidebar-border">
        <h1 className="text-xl font-bold flex items-center gap-2 text-sidebar-foreground">
          Daily Bazaar
        </h1>
      </div>
      <div className="flex-1 p-4 space-y-2">
        {navItems.map((item) => {
          const isActive = pathname === item.href || (item.href !== "/" && pathname.startsWith(item.href));
          return (
            <Link key={item.href} href={item.href} className="block">
              <Button 
                variant={isActive ? "secondary" : "ghost"} 
                className={`w-full justify-start ${isActive ? 'bg-sidebar-accent text-sidebar-accent-foreground' : 'text-sidebar-foreground hover:bg-sidebar-accent/50 hover:text-sidebar-accent-foreground'}`}
              >
                <item.icon className="mr-2 h-4 w-4" />
                {item.label}
              </Button>
            </Link>
          );
        })}
      </div>
      <div className="p-4 border-t border-sidebar-border">
        <Button variant="ghost" className="w-full justify-start text-destructive hover:text-destructive hover:bg-destructive/10">
          <LogOut className="mr-2 h-4 w-4" />
          Logout
        </Button>
      </div>
    </div>
  );
}
