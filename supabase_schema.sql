-- MASTER DOKUMEN CONTROL - Supabase/Postgres starter schema
-- Jalankan bertahap dan aktifkan RLS sebelum production.

create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null,
  location text,
  owner_name text,
  contractor_name text,
  consultant_name text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists document_register (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  document_no text not null,
  document_type text not null,
  title text,
  revision text default '0',
  status text default 'Draft',
  discipline text,
  area text,
  current_holder text,
  submitted_date date,
  approved_date date,
  full_signed_date date,
  remarks text,
  created_by uuid,
  updated_by uuid,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(project_id, document_no, revision)
);

create table if not exists material_approvals (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  document_id uuid references document_register(id) on delete set null,
  ma_no text not null,
  material_name text,
  specification text,
  quantity numeric,
  unit text,
  vendor text,
  criticality text,
  status text,
  shop_drawing_no text,
  ipp_no text,
  created_at timestamptz default now()
);

create table if not exists material_requests (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  document_id uuid references document_register(id) on delete set null,
  mr_no text not null,
  category text,
  status text,
  request_date date,
  expected_date date,
  vendor text,
  po_no text,
  shipping_no text,
  delivered_date date,
  take_out_date date,
  remarks text,
  created_at timestamptz default now()
);

create table if not exists material_request_items (
  id uuid primary key default gen_random_uuid(),
  material_request_id uuid references material_requests(id) on delete cascade,
  item_no int,
  qty numeric,
  mou text,
  description text,
  size_model text,
  estimate_price numeric,
  total_price numeric,
  remarks text
);

create table if not exists drawings (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  document_id uuid references document_register(id) on delete set null,
  drawing_no text not null,
  drawing_type text,
  title text,
  revision text default '0',
  status text,
  discipline text,
  area text,
  approved_date date,
  created_at timestamptz default now()
);

create table if not exists work_permits_ipp (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  document_id uuid references document_register(id) on delete set null,
  ipp_no text not null,
  work_title text,
  area text,
  status text,
  readiness_score numeric,
  drawing_refs text[],
  ma_refs text[],
  basis jsonb default '{}'::jsonb,
  labor jsonb default '{}'::jsonb,
  equipment jsonb default '[]'::jsonb,
  created_at timestamptz default now()
);

create table if not exists transmittals (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  transmittal_no text not null,
  title text,
  status text default 'Draft',
  issued_date date,
  receiver text,
  remarks text,
  created_at timestamptz default now()
);

create table if not exists transmittal_items (
  id uuid primary key default gen_random_uuid(),
  transmittal_id uuid references transmittals(id) on delete cascade,
  document_id uuid references document_register(id) on delete set null,
  document_no text,
  document_type text,
  revision text,
  status text,
  remarks text
);

create table if not exists file_assets (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  document_id uuid references document_register(id) on delete set null,
  file_name text not null,
  mime_type text,
  file_size bigint,
  storage_provider text default 'supabase',
  bucket text,
  storage_path text,
  file_hash text,
  uploaded_by uuid,
  uploaded_at timestamptz default now(),
  status text default 'Available'
);

create table if not exists document_links (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  source_document_id uuid references document_register(id) on delete cascade,
  target_document_id uuid references document_register(id) on delete cascade,
  link_type text not null,
  remarks text,
  created_at timestamptz default now()
);

create table if not exists template_registry (
  id uuid primary key default gen_random_uuid(),
  template_id text unique not null,
  module text not null,
  display_name text not null,
  version text not null,
  file_asset_id uuid references file_assets(id) on delete set null,
  mapping jsonb not null default '{}'::jsonb,
  is_active boolean default false,
  locked boolean default true,
  created_at timestamptz default now()
);

create table if not exists audit_logs (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  actor_id uuid,
  action text not null,
  entity_type text,
  entity_id text,
  before_data jsonb,
  after_data jsonb,
  created_at timestamptz default now()
);
