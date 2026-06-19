-- ============================================================
--  Tatvy — anonymní počítání použití
--  Spusť jednou v Supabase → SQL Editor (projekt myybuesoourgpbouwwst)
-- ============================================================

-- 1) Tabulka záznamů o otevření (žádná osobní data)
create table if not exists public.tatvy_navstevy (
  id         bigint generated always as identity primary key,
  device_id  text not null,                         -- náhodné ID z localStorage
  mode       text not null default 'browser',       -- 'standalone' (z plochy) | 'browser'
  ts         timestamptz not null default now()
);

create index if not exists tatvy_navstevy_ts_idx on public.tatvy_navstevy (ts);
create index if not exists tatvy_navstevy_device_idx on public.tatvy_navstevy (device_id);

-- 2) RLS: anonym smí JEN zapisovat, nesmí číst
alter table public.tatvy_navstevy enable row level security;

drop policy if exists "anon insert" on public.tatvy_navstevy;
create policy "anon insert"
  on public.tatvy_navstevy
  for insert
  to anon
  with check (true);

-- 3) Agregační funkce — vrátí všechna čísla jako JSON
create or replace function public.tatvy_stats()
returns json
language sql
security definer
set search_path = public
as $$
  select json_build_object(
    'unikatni',        (select count(distinct device_id) from tatvy_navstevy),
    'instalovani',     (select count(distinct device_id) from tatvy_navstevy where mode = 'standalone'),
    'otevreni_celkem', (select count(*) from tatvy_navstevy),
    'otevreni_dnes',   (select count(*) from tatvy_navstevy where ts >= date_trunc('day', now())),
    'aktivni_7d',      (select count(distinct device_id) from tatvy_navstevy where ts >= now() - interval '7 days'),
    'aktivni_30d',     (select count(distinct device_id) from tatvy_navstevy where ts >= now() - interval '30 days'),
    'denne',           (select coalesce(json_agg(row_to_json(d) order by d.den), '[]'::json) from (
                          select date_trunc('day', ts)::date as den, count(*) as pocet
                          from tatvy_navstevy
                          where ts >= now() - interval '14 days'
                          group by 1
                       ) d)
  );
$$;

-- 4) Funkci smí volat jen server (servisní klíč), ne anonym
revoke execute on function public.tatvy_stats() from public, anon, authenticated;
grant  execute on function public.tatvy_stats() to service_role;
