export interface ExportPlan {
  id: number;
  calendar_week_kw: number;
  year: number;
  order_number: string | null;
  product_code: string;
  quantity: number;
  destination: string;
  status: 'pending' | 'in_production' | 'completed';
  created_by: number | null;
  created_at: Date;
  updated_at: Date;
}

export interface ExportPlanInput {
  calendar_week_kw: number;
  year: number;
  order_number?: string | null;
  product_code: string;
  quantity: number;
  destination: string;
  status?: 'pending' | 'in_production' | 'completed';
}

export interface ExportPlanAudit {
  id: number;
  export_plan_id: number | null;
  action: string;
  changed_by: number | null;
  old_values: Record<string, unknown> | null;
  new_values: Record<string, unknown> | null;
  created_at: Date;
}
