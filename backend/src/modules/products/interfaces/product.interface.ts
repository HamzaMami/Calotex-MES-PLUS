export interface Product {
  id: number;
  name: string;
  lead_engineer_id: number | null;
  technical_milestone: string | null;
  validation_status: string | null;
  final_approval: boolean;
  created_at: Date;
  updated_at: Date;
}
