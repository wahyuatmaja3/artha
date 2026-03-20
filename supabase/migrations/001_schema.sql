-- artha_supabase_schema.sql

create table wallets (
  id uuid primary key,
  user_id uuid,
  name text,
  balance numeric,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  deleted_at timestamptz
);

create table categories (
  id uuid primary key,
  user_id uuid,
  name text,
  type text, -- 'income' | 'expense'
  icon text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  deleted_at timestamptz
);

create table transactions (
  id uuid primary key,
  user_id uuid,
  wallet_id uuid references wallets(id),
  category_id uuid references categories(id),
  amount numeric,
  note text,
  transaction_date date,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  deleted_at timestamptz,
  sync_status text default 'synced'
);

create table budgets (
  id uuid primary key,
  user_id uuid,
  category_id uuid references categories(id),
  month text, -- 'YYYY-MM'
  limit_amount numeric,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  deleted_at timestamptz
);
