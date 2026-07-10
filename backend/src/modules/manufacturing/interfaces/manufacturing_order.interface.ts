export interface ManufacturingOrder {
  id: number;
  product_id: number;
  status: 'in_production' | 'pending' | 'quality_control' | 'completed';
  target_quantity: number;
  good_quantity: number;
  reject_quantity: number;
  qa_quantity: number;
  start_date: Date | null;
  end_date: Date | null;
  created_at: Date;
  updated_at: Date;
}
