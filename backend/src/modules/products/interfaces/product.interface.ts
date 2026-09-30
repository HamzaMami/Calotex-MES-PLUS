export interface Product {
  id: number;
  product_code: string;
  name: string;
  assembly_pdf: string | null;
  product_photo: string | null;
  client_name: string;
  category: string;
  lead_engineer_id: number | null;
  technical_milestone: string | null;
  validation_status: string | null;
  final_approval: boolean;
  created_at: Date;
  updated_at: Date;
}
