export interface InventoryItem {
  id: number;
  item_name: string;
  sku: string | null;
  quantity: number;
  unit: string;
  location: string | null;
  last_restocked: Date | null;
  created_at: Date;
  updated_at: Date;
}
