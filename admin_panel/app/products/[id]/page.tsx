"use client";

import { useState, useEffect, use } from "react";
import { useRouter } from "next/navigation";
import { 
  ArrowLeft, 
  Save, 
  Loader2, 
  AlertCircle,
  Trash2,
  Plus,
  X
} from "lucide-react";
import api from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Product } from "@/lib/types";

interface Category {
  id: string;
  name: string;
}

export default function EditProductPage({ params }: { params: Promise<{ id: string }> }) {
  const router = useRouter();
  // Unwrap params using React 19's use() hook
  const { id } = use(params);

  const [loading, setLoading] = useState(false);
  const [fetching, setFetching] = useState(true);
  const [categories, setCategories] = useState<Category[]>([]);
  const [fetchingCategories, setFetchingCategories] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Form State
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    sku: "",
    price: "",
    mrp: "",
    stock: "",
    weight: "",
    active: true,
    category_ids: [] as string[],
    variants: [] as { name: string; price: string; weight: string }[],
    images: [] as { url: string }[]
  });

  // Fetch Categories and Product Data
  useEffect(() => {
    async function fetchData() {
      try {
        setFetching(true);
        // Parallel fetch
        const [catRes, prodRes] = await Promise.all([
          api.get("/categories"),
          api.get(`/products/${id}`)
        ]);

        setCategories(catRes.data || []);
        
        const product: Product = prodRes.data;
        if (product) {
          setFormData({
            name: product.name,
            description: product.description || "",
            sku: product.sku || "",
            price: (product.price_cents / 100).toFixed(2),
            mrp: product.metadata?.mrp_cents ? (product.metadata.mrp_cents / 100).toFixed(2) : "",
            stock: product.stock.toString(),
            weight: product.weight || "",
            active: product.active,
            category_ids: product.categories ? product.categories.map(c => c.id) : [],
            variants: product.variants ? product.variants.map(v => ({
              name: v.name,
              price: (v.price_cents / 100).toFixed(2),
              weight: v.weight || ""
            })) : [],
            images: product.images ? product.images.map(img => ({ url: img.url })) : []
          });
        }
      } catch (err: any) {
        console.error("Failed to fetch data", err);
        setError("Failed to load product details");
      } finally {
        setFetching(false);
        setFetchingCategories(false);
      }
    }
    fetchData();
  }, [id]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSwitchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData(prev => ({ ...prev, active: e.target.checked }));
  };

  const handleCategoryChange = (categoryId: string) => {
    setFormData(prev => {
      const current = prev.category_ids;
      if (current.includes(categoryId)) {
        return { ...prev, category_ids: current.filter(id => id !== categoryId) };
      } else {
        return { ...prev, category_ids: [...current, categoryId] };
      }
    });
  };

  // Variant Handlers
  const addVariant = () => {
    setFormData(prev => ({
      ...prev,
      variants: [...prev.variants, { name: "", price: "", weight: "" }]
    }));
  };

  const removeVariant = (index: number) => {
    setFormData(prev => ({
      ...prev,
      variants: prev.variants.filter((_, i) => i !== index)
    }));
  };

  const updateVariant = (index: number, field: string, value: string) => {
    setFormData(prev => ({
      ...prev,
      variants: prev.variants.map((v, i) => i === index ? { ...v, [field]: value } : v)
    }));
  };

  // Image Handlers
  const addImage = () => {
    setFormData(prev => ({
      ...prev,
      images: [...prev.images, { url: "" }]
    }));
  };

  const removeImage = (index: number) => {
    setFormData(prev => ({
      ...prev,
      images: prev.images.filter((_, i) => i !== index)
    }));
  };

  const updateImage = (index: number, value: string) => {
    setFormData(prev => ({
      ...prev,
      images: prev.images.map((img, i) => i === index ? { url: value } : img)
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    // Basic Validation
    if (!formData.name) {
      setError("Product Name is required");
      setLoading(false);
      return;
    }
    if (!formData.price) {
        setError("Price is required");
        setLoading(false);
        return;
    }

    try {
      // Prepare Payload
      const priceCents = Math.round(parseFloat(formData.price) * 100);
      const mrpCents = formData.mrp ? Math.round(parseFloat(formData.mrp) * 100) : null;
      
      const payload = {
        name: formData.name,
        description: formData.description,
        sku: formData.sku,
        price_cents: priceCents,
        stock: parseInt(formData.stock) || 0,
        weight: formData.weight,
        active: formData.active,
        category_ids: formData.category_ids,
        variants: formData.variants.filter(v => v.name && v.price).map(v => ({
          name: v.name,
          price_cents: Math.round(parseFloat(v.price) * 100),
          weight: v.weight
        })),
        images: formData.images.filter(img => img.url).map((img, idx) => ({
          url: img.url,
          position: idx
        })),
        metadata: mrpCents ? { mrp_cents: mrpCents } : undefined
      };

      await api.put(`/products/${id}`, payload);
      
      router.push("/products"); 
    } catch (err: any) {
      console.error("Failed to update product", err);
      setError(err.response?.data?.message || "Failed to update product");
    } finally {
      setLoading(false);
    }
  };


  const handleDelete = async () => {
    if (!confirm("Are you sure you want to delete this product? This action cannot be undone.")) return;
    
    try {
      setLoading(true);
      await api.delete(`/products/${id}`);
      router.push("/products");
    } catch (err: any) {
      console.error("Failed to delete product", err);
      setError("Failed to delete product");
      setLoading(false);
    }
  };

  if (fetching) {
     return (
       <div className="flex h-screen items-center justify-center">
         <Loader2 className="h-8 w-8 animate-spin text-primary" />
       </div>
     );
  }

  return (
    <div className="p-8 space-y-8 bg-background min-h-screen">
      {/* Header */}
      <div className="flex items-center justify-between">
         <div className="flex items-center gap-4">
           <Button variant="outline" size="icon" onClick={() => router.back()}>
             <ArrowLeft className="h-4 w-4" />
           </Button>
           <div>
             <h1 className="text-3xl font-bold tracking-tight">Edit Product</h1>
             <p className="text-muted-foreground">Update product details and inventory.</p>
           </div>
         </div>
         <Button variant="destructive" size="sm" onClick={handleDelete}>
           <Trash2 className="mr-2 h-4 w-4" />
           Delete Product
         </Button>
      </div>

      <div className="grid gap-8 grid-cols-1 lg:grid-cols-3">
        {/* Main Form */}
        <div className="lg:col-span-2 space-y-8">
          <Card>
            <CardHeader>
              <CardTitle>Product Details</CardTitle>
              <CardDescription>
                Enter the core details of your product.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid gap-2">
                <Label htmlFor="name">Product Name *</Label>
                <Input 
                  id="name" 
                  name="name" 
                  value={formData.name} 
                  onChange={handleChange} 
                  placeholder="e.g. Wireless Headphones"
                  required
                />
              </div>
              
              <div className="grid gap-2">
                <Label htmlFor="description">Description</Label>
                <Textarea 
                  id="description" 
                  name="description" 
                  value={formData.description} 
                  onChange={handleChange} 
                  placeholder="Product description..."
                  rows={4}
                />
              </div>
            </CardContent>
          </Card>

          <Card>
             <CardHeader>
               <CardTitle>Pricing & Inventory</CardTitle>
             </CardHeader>
             <CardContent className="space-y-4">
               <div className="grid grid-cols-2 gap-4">
                 <div className="grid gap-2">
                   <Label htmlFor="price">Price *</Label>
                   <Input 
                     id="price" 
                     name="price" 
                     type="number"
                     step="0.01"
                     value={formData.price} 
                     onChange={handleChange} 
                     placeholder="0.00"
                     required
                   />
                 </div>
                 <div className="grid gap-2">
                   <Label htmlFor="mrp">MRP (Optional)</Label>
                   <Input 
                     id="mrp" 
                     name="mrp" 
                     type="number"
                     step="0.01"
                     value={formData.mrp} 
                     onChange={handleChange} 
                     placeholder="0.00"
                   />
                 </div>
               </div>

               <div className="grid grid-cols-2 gap-4">
                 <div className="grid gap-2">
                   <Label htmlFor="stock">Stock Quantity</Label>
                   <Input 
                     id="stock" 
                     name="stock" 
                     type="number"
                     value={formData.stock} 
                     onChange={handleChange} 
                     placeholder="0"
                   />
                 </div>
                 <div className="grid gap-2">
                   <Label htmlFor="sku">SKU</Label>
                   <Input 
                     id="sku" 
                     name="sku" 
                     value={formData.sku} 
                     onChange={handleChange} 
                     placeholder="e.g. PROD-001"
                   />
                 </div>
               </div>

                <div className="grid gap-2">
                   <Label htmlFor="weight">Weight / Unit</Label>
                   <Input 
                     id="weight" 
                     name="weight" 
                     value={formData.weight} 
                     onChange={handleChange} 
                     placeholder="e.g. 1.5kg or 500g"
                   />
                 </div>
              </CardContent>
           </Card>

          {/* Variants Card */}
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <div className="space-y-0.5">
                <CardTitle>Variants</CardTitle>
                <CardDescription>
                  Manage product variants (e.g., sizes, weights).
                </CardDescription>
              </div>
              <Button onClick={addVariant} variant="outline" size="sm" type="button">
                <Plus className="mr-2 h-4 w-4" /> Add Variant
              </Button>
            </CardHeader>
            <CardContent className="space-y-4">
              {formData.variants.length === 0 && (
                 <p className="text-sm text-muted-foreground text-center py-4 border border-dashed rounded-lg">
                   No variants added.
                 </p>
              )}
              {formData.variants.map((variant, index) => (
                <div key={index} className="flex gap-4 items-start p-4 border rounded-lg relative group">
                  <div className="grid gap-2 flex-1">
                    <Label>Variant Name</Label>
                    <Input 
                      value={variant.name} 
                      onChange={(e) => updateVariant(index, "name", e.target.value)}
                      placeholder="e.g. Small" 
                    />
                  </div>
                  <div className="grid gap-2 w-32">
                    <Label>Price</Label>
                    <Input 
                      type="number" 
                      value={variant.price} 
                      onChange={(e) => updateVariant(index, "price", e.target.value)}
                      placeholder="0.00" 
                    />
                  </div>
                  <div className="grid gap-2 w-32">
                    <Label>Weight</Label>
                    <Input 
                      value={variant.weight} 
                      onChange={(e) => updateVariant(index, "weight", e.target.value)}
                      placeholder="e.g. 500g" 
                    />
                  </div>
                  <Button 
                    variant="ghost" 
                    size="icon" 
                    className="absolute -top-2 -right-2 h-6 w-6 rounded-full bg-destructive text-destructive-foreground hover:bg-destructive shadow-sm opacity-0 group-hover:opacity-100 transition-opacity"
                    onClick={() => removeVariant(index)}
                    type="button"
                  >
                    <X className="h-3 w-3" />
                  </Button>
                </div>
              ))}
            </CardContent>
          </Card>

          {/* Images Card */}
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <div className="space-y-0.5">
                <CardTitle>Product Images</CardTitle>
                <CardDescription>
                  Manage image URLs for your product.
                </CardDescription>
              </div>
              <Button onClick={addImage} variant="outline" size="sm" type="button">
                <Plus className="mr-2 h-4 w-4" /> Add Image
              </Button>
            </CardHeader>
            <CardContent className="space-y-4">
              {formData.images.length === 0 && (
                 <p className="text-sm text-muted-foreground text-center py-4 border border-dashed rounded-lg">
                   No images added.
                 </p>
              )}
              {formData.images.map((img, index) => (
                <div key={index} className="flex gap-4 items-center">
                   <div className="h-12 w-12 bg-muted rounded overflow-hidden flex-shrink-0 border flex items-center justify-center">
                      {img.url ? <img src={img.url} alt="" className="h-full w-full object-cover" /> : <span className="text-xs text-muted-foreground">Preview</span>}
                   </div>
                   <div className="flex-1">
                     <Input 
                        value={img.url} 
                        onChange={(e) => updateImage(index, e.target.value)}
                        placeholder="https://example.com/image.jpg" 
                      />
                   </div>
                   <Button 
                    variant="ghost" 
                    size="icon" 
                    className="text-destructive hover:text-destructive hover:bg-destructive/10"
                    onClick={() => removeImage(index)}
                    type="button"
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              ))}
            </CardContent>
          </Card>
        </div>

        {/* Sidebar */}
        <div className="space-y-8">
           {/* Status Card */}
           <Card>
             <CardHeader>
               <CardTitle>Status</CardTitle>
             </CardHeader>
             <CardContent>
               <div className="flex items-center justify-between">
                 <Label htmlFor="active" className="text-base font-normal">Active Status</Label>
                 <Switch 
                   id="active"
                   checked={formData.active} 
                   onChange={handleSwitchChange}
                 />
               </div>
               <p className="text-xs text-muted-foreground mt-2">
                 Active products are visible to customers.
               </p>
             </CardContent>
           </Card>

           {/* Category Card */}
           <Card>
             <CardHeader>
               <CardTitle>Categories *</CardTitle>
             </CardHeader>
             <CardContent>
               {fetchingCategories ? (
                 <div className="flex justify-center p-4">
                   <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
                 </div>
               ) : categories.length === 0 ? (
                 <p className="text-sm text-yellow-500 flex items-center gap-2">
                   <AlertCircle className="h-4 w-4" /> No categories found.
                 </p>
               ) : (
                 <div className="space-y-2 max-h-60 overflow-y-auto pr-2">
                   {categories.map(cat => (
                     <label key={cat.id} className="flex items-center space-x-2 cursor-pointer hover:bg-muted/50 p-2 rounded transition-colors">
                       <input 
                         type="checkbox" 
                         checked={formData.category_ids.includes(cat.id)}
                         onChange={() => handleCategoryChange(cat.id)}
                         className="h-4 w-4 rounded border-input text-primary focus:ring-primary"
                       />
                       <span className="text-sm">{cat.name}</span>
                     </label>
                   ))}
                 </div>
               )}
             </CardContent>
           </Card>
           
           {/* Actions */}
           <Button className="w-full" size="lg" onClick={handleSubmit} disabled={loading}>
             {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Save className="mr-2 h-4 w-4" />}
             {loading ? "Updating..." : "Update Product"}
           </Button>
           
           {error && (
             <div className="bg-destructive/10 text-destructive text-sm p-3 rounded-md flex items-start gap-2">
               <AlertCircle className="h-4 w-4 mt-0.5 shrink-0" />
               <span>{error}</span>
             </div>
           )}
        </div>
      </div>
    </div>
  );
}
