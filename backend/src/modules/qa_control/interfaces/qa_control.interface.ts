export interface QaControl {
  id: number;
  product_code: string;
  year: number;
  calendar_week_kw: number;
  first_control_id: string;
  last_control_id: string;
  first_serial_number: string;
  last_serial_number: string;
  created_by: number | null;
  created_at: Date;
}

export interface QaWeeklyProduct {
  product_code: string;
  order_number: string | null;
  quantity: number;
  controls: QaControl[];
}
