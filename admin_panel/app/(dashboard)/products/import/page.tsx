"use strict";
"use client";

import { useState } from "react";
import * as XLSX from "xlsx";
import { Upload, FileUp, CheckCircle, AlertCircle, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { AddProduct, Category } from "@/lib/types";
import api from "@/lib/api";

type ImportStatus = "idle" | "parsing" | "validating" | "importing" | "complete";

interface ParsedProduct {
  name: string;
  description: string;
  price: number; // in dollars from excel
  stock: number;
  category: string; // name of category
  sku?: string;
  active?: boolean;
}

interface ValidationResult {
  row: number;
  data: ParsedProduct;
  isValid: boolean;
  errors: string[];
  status: "pending" | "success" | "error";
  message?: string;
}

export default function ImportProductsPage() {
  const [file, setFile] = useState<File | null>(null);
  const [parsedData, setParsedData] = useState<ValidationResult[]>([]);
  const [status, setStatus] = useState<ImportStatus>("idle");
  const [progress, setProgress] = useState(0);
  const [categories, setCategories] = useState<Category[]>([]);
  const [summary, setSummary] = useState({ success: 0, failed: 0 });

  // Fetch categories on mount for mapping
  useState(() => {
    api.get("/categories")
      .then((res) => setCategories(res.data))
      .catch((err) => console.error("Failed to fetch categories", err));
  });

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0];
    if (!selectedFile) return;

    setFile(selectedFile);
    setStatus("parsing");
    
    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const bstr = evt.target?.result;
        const wb = XLSX.read(bstr, { type: "binary" });
        const wsname = wb.SheetNames[0];
        const ws = wb.Sheets[wsname];
        const data = XLSX.utils.sheet_to_json<ParsedProduct>(ws);
        
        validateData(data);
      } catch (error) {
        console.error("Error parsing excel", error);
        setStatus("idle");
        alert("Failed to parse Excel file");
      }
    };
    reader.readAsBinaryString(selectedFile);
  };

  const validateData = (data: ParsedProduct[]) => {
    setStatus("validating");
    const validated: ValidationResult[] = data.map((item, index) => {
      const errors: string[] = [];
      if (!item.name) errors.push("Name is required");
      if (typeof item.price !== "number") errors.push("Price must be a number");
      if (typeof item.stock !== "number") errors.push("Stock must be a number");

      return {
        row: index + 2, // Excel row (1 is header)
        data: item,
        isValid: errors.length === 0,
        errors,
        status: "pending"
      };
    });
    setParsedData(validated);
    setStatus("idle");
  };

  const handleImport = async () => {
    setStatus("importing");
    setProgress(0);
    let successCount = 0;
    let failCount = 0;

    const total = parsedData.filter(d => d.isValid).length;
    let processed = 0;

    const newParsedData = [...parsedData];

    for (let i = 0; i < newParsedData.length; i++) {
      const item = newParsedData[i];
      if (!item.isValid) continue;

      // Map category name to ID
      // Case insensitive match
      const categoryId = categories.find(
        cat => cat.name.toLowerCase() === item.data.category?.toLowerCase() || cat.slug === item.data.category
      )?.id;

      const payload: AddProduct = {
        name: item.data.name,
        description: item.data.description,
        price_cents: Math.round(item.data.price * 100), // convert to cents
        stock: item.data.stock,
        active: item.data.active ?? true,
        sku: item.data.sku,
        category_ids: categoryId ? [categoryId] : [],
      };

      try {
        await api.post("/products", payload);
        item.status = "success";
        successCount++;
      } catch (error: any) {
        console.error(`Row ${item.row} failed`, error);
        item.status = "error";
        item.message = error.response?.data?.message || "Failed to create";
        failCount++;
      }

      processed++;
      setProgress(Math.round((processed / total) * 100));
      // Update UI incrementally ideally, but for now we update state at the end or in chunks if needed
      // React state updates are batched so this might not show every single step without a timeout
    }

    setParsedData(newParsedData);
    setSummary({ success: successCount, failed: failCount });
    setStatus("complete");
  };

  return (
    <div className="p-8 space-y-8 max-w-6xl mx-auto">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Import Products</h1>
          <p className="text-muted-foreground mt-2">
            Upload an Excel or CSV file to bulk create products.
          </p>
        </div>
        <Button variant="outline" onClick={() => window.open('/template.xlsx')}>
          Download Template
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Upload File</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="border-2 border-dashed rounded-lg p-12 flex flex-col items-center justify-center text-center space-y-4 hover:bg-muted/50 transition-colors">
            <div className="p-4 bg-primary/10 rounded-full">
              <Upload className="h-8 w-8 text-primary" />
            </div>
            <div className="space-y-2">
              <p className="font-semibold">Drag and drop your file here</p>
              <p className="text-sm text-muted-foreground">or click to browse locally</p>
            </div>
            <input 
              type="file" 
              className="absolute inset-0 opacity-0 cursor-pointer" 
              accept=".xlsx, .xls, .csv"
              onChange={handleFileUpload}
              disabled={status === "importing"}
            />
          </div>
          {file && (
            <div className="mt-4 flex items-center gap-2 text-sm font-medium">
              <FileUp className="h-4 w-4" />
              {file.name}
              {(status === "parsing" || status === "validating") && <Loader2 className="h-4 w-4 animate-spin ml-2" />}
            </div>
          )}
        </CardContent>
      </Card>

      {parsedData.length > 0 && (
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Preview & Import</CardTitle>
            <div className="flex gap-4 items-center">
              <div className="text-sm text-muted-foreground">
                {parsedData.filter(d => d.isValid).length} valid rows
              </div>
              <Button onClick={handleImport} disabled={status === "importing" || parsedData.filter(d => d.isValid).length === 0}>
                {status === "importing" && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                {status === "importing" ? "Importing..." : "Start Import"}
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            {status === "importing" && (
              <div className="mb-6 space-y-2">
                <div className="flex justify-between text-sm">
                  <span>Progress</span>
                  <span>{progress}%</span>
                </div>
                <div className="h-2 bg-secondary rounded-full overflow-hidden">
                  <div 
                    className="h-full bg-primary transition-all duration-300"
                    style={{ width: `${progress}%` }}
                  />
                </div>
              </div>
            )}

            {status === "complete" && (
              <div className="mb-6 p-4 rounded-lg bg-muted flex items-center gap-4">
                 <div className="flex items-center gap-2 text-green-600">
                   <CheckCircle className="h-5 w-5" />
                   <span className="font-medium">{summary.success} Successful</span>
                 </div>
                 <div className="flex items-center gap-2 text-red-600">
                   <AlertCircle className="h-5 w-5" />
                   <span className="font-medium">{summary.failed} Failed</span>
                 </div>
              </div>
            )}

            <div className="relative overflow-x-auto rounded-md border">
              <table className="w-full text-sm text-left">
                <thead className="text-xs uppercase bg-muted/50 text-muted-foreground">
                  <tr>
                    <th className="px-4 py-3">Row</th>
                    <th className="px-4 py-3">Status</th>
                    <th className="px-4 py-3">Name</th>
                    <th className="px-4 py-3">Price</th>
                    <th className="px-4 py-3">Stock</th>
                    <th className="px-4 py-3">Category</th>
                    <th className="px-4 py-3">Message</th>
                  </tr>
                </thead>
                <tbody>
                  {parsedData.slice(0, 100).map((item, idx) => (
                    <tr key={idx} className="border-b last:border-0 hover:bg-muted/50">
                      <td className="px-4 py-3 font-mono text-muted-foreground">{item.row}</td>
                      <td className="px-4 py-3">
                         {item.status === "success" && <span className="text-green-600 flex items-center gap-1"><CheckCircle className="h-3 w-3"/> Done</span>}
                         {item.status === "error" && <span className="text-red-600 flex items-center gap-1"><AlertCircle className="h-3 w-3"/> Error</span>}
                         {item.status === "pending" && !item.isValid && <span className="text-red-500 text-xs font-medium">Invalid</span>}
                         {item.status === "pending" && item.isValid && <span className="text-muted-foreground text-xs">Ready</span>}
                      </td>
                      <td className="px-4 py-3 font-medium">{item.data.name || "-"}</td>
                      <td className="px-4 py-3">${item.data.price?.toFixed(2)}</td>
                      <td className="px-4 py-3">{item.data.stock}</td>
                      <td className="px-4 py-3">
                        <span className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ${
                           categories.some(c => c.name.toLowerCase() === item.data.category?.toLowerCase()) 
                           ? "bg-blue-500/10 text-blue-500" 
                           : "bg-yellow-500/10 text-yellow-500"
                        }`}>
                          {item.data.category || "None"}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-red-500 max-w-[200px] truncate">
                        {item.errors.length > 0 ? item.errors.join(", ") : item.message}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {parsedData.length > 100 && (
                <div className="p-4 text-center text-muted-foreground text-xs">
                  Showing first 100 of {parsedData.length} rows
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
