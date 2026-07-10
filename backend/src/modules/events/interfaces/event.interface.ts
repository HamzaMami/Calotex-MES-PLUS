export interface Event {
  id: number;
  title: string;
  type: 'technical' | 'quality' | 'export';
  event_date: Date;
  created_at: Date;
  updated_at: Date;
}
