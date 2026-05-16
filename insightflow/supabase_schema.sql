-- ═══════════════════════════════════════════════════════════════
--  InsightFlow — Supabase Database Schema
--  Run this in your Supabase SQL Editor (Dashboard → SQL Editor)
-- ═══════════════════════════════════════════════════════════════

-- 1. Enable UUID extension
create extension if not exists "uuid-ossp";

-- 2. Insight Results table
create table if not exists public.insight_results (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid references auth.users(id) on delete cascade,
  raw_input     text not null,
  summary       text,
  insight       text,
  insight_type  text,
  impact_analysis text,
  severity      text check (severity in ('Low','Medium','High','Critical')),
  key_facts     jsonb default '[]'::jsonb,
  actions       jsonb default '[]'::jsonb,
  simulation    jsonb default '{}'::jsonb,
  agent_trace   jsonb default '[]'::jsonb,
  timestamp     timestamptz default now(),
  created_at    timestamptz default now()
);

-- 3. Row Level Security — users can only see & edit their own rows
alter table public.insight_results enable row level security;

create policy "Users can view own insights"
  on public.insight_results for select
  using (auth.uid() = user_id);

create policy "Users can insert own insights"
  on public.insight_results for insert
  with check (auth.uid() = user_id);

create policy "Users can update own insights"
  on public.insight_results for update
  using (auth.uid() = user_id);

create policy "Users can delete own insights"
  on public.insight_results for delete
  using (auth.uid() = user_id);

-- 4. Index for fast user queries
create index if not exists idx_insight_results_user_id
  on public.insight_results(user_id);

create index if not exists idx_insight_results_timestamp
  on public.insight_results(timestamp desc);

-- 5. Anonymous users can also insert (for demo without auth)
create policy "Anon insert allowed"
  on public.insight_results for insert
  to anon
  with check (user_id is null);

create policy "Anon select allowed"
  on public.insight_results for select
  to anon
  using (user_id is null);
