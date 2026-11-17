-- =====================================================================
-- Mkkly Nails : base de données des créneaux et rendez-vous
-- À coller en entier dans Supabase > SQL Editor > New query > Run.
--
-- AVANT DE LANCER : remplace TON_EMAIL_ICI (ligne ~20) par l'e-mail
-- avec lequel tu te connecteras à ton espace pro.
-- =====================================================================

create extension if not exists pgcrypto;

-- ---------- Qui est l'admin (toi) ----------
create or replace function public.est_admin()
returns boolean
language sql stable
as $$
  select coalesce(lower(auth.jwt() ->> 'email'), '') = lower('TON_EMAIL_ICI');
$$;

-- ---------- Tables ----------
create table if not exists public.slots (
  id           uuid primary key default gen_random_uuid(),
  starts_at    timestamptz not null unique,
  duration_min int not null default 120 check (duration_min between 15 and 480),
  created_at   timestamptz not null default now()
);

create table if not exists public.bookings (
  id          uuid primary key default gen_random_uuid(),
  slot_id     uuid not null references public.slots(id) on delete cascade,
  first_name  text not null check (char_length(first_name) between 1 and 40),
  contact     text check (char_length(contact) <= 80),
  service     text not null check (char_length(service) <= 160),
  total       int  not null default 0 check (total between 0 and 1000),
  devis       boolean not null default false,
  message     text check (char_length(message) <= 500),
  status      text not null default 'reserve' check (status in ('reserve','confirme','annule')),
  created_at  timestamptz not null default now()
);

-- Un seul rendez-vous actif par créneau (empêche les doubles réservations)
create unique index if not exists un_rdv_par_creneau
  on public.bookings(slot_id) where status <> 'annule';

alter table public.slots    enable row level security;
alter table public.bookings enable row level security;

-- ---------- Fonctions publiques (les clientes ne voient que l'essentiel) ----------
-- Créneaux libres et à venir : date et durée uniquement, jamais le nom des clientes.
create or replace function public.creneaux_libres()
returns table (id uuid, starts_at timestamptz, duration_min int)
language sql stable security definer
set search_path = public
as $$
  select s.id, s.starts_at, s.duration_min
  from slots s
  where s.starts_at > now()
    and not exists (select 1 from bookings b where b.slot_id = s.id and b.status <> 'annule')
  order by s.starts_at
  limit 300;
$$;

create or replace function public.creneau_ouvert(sid uuid)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (select 1 from slots where id = sid and starts_at > now());
$$;

revoke all on function public.creneaux_libres() from public;
revoke all on function public.creneau_ouvert(uuid) from public;
grant execute on function public.creneaux_libres() to anon, authenticated;
grant execute on function public.creneau_ouvert(uuid) to anon, authenticated;

-- ---------- Règles d'accès ----------
-- Créneaux : seule toi les vois en entier, les ajoutes et les supprimes.
drop policy if exists "slots admin" on public.slots;
create policy "slots admin" on public.slots
  for all to authenticated
  using (public.est_admin()) with check (public.est_admin());

-- Réservations : n'importe qui peut réserver un créneau futur,
-- mais seule toi peux lire, modifier ou supprimer les rendez-vous.
drop policy if exists "reserver" on public.bookings;
create policy "reserver" on public.bookings
  for insert to anon, authenticated
  with check (status = 'reserve' and public.creneau_ouvert(slot_id));

drop policy if exists "bookings lecture admin" on public.bookings;
create policy "bookings lecture admin" on public.bookings
  for select to authenticated using (public.est_admin());

drop policy if exists "bookings modif admin" on public.bookings;
create policy "bookings modif admin" on public.bookings
  for update to authenticated using (public.est_admin()) with check (public.est_admin());

drop policy if exists "bookings suppr admin" on public.bookings;
create policy "bookings suppr admin" on public.bookings
  for delete to authenticated using (public.est_admin());

-- ---------- Photos des poses ----------
insert into storage.buckets (id, name, public)
values ('poses', 'poses', true)
on conflict (id) do update set public = true;

drop policy if exists "poses lecture" on storage.objects;
create policy "poses lecture" on storage.objects
  for select using (bucket_id = 'poses');

drop policy if exists "poses ajout admin" on storage.objects;
create policy "poses ajout admin" on storage.objects
  for insert to authenticated with check (bucket_id = 'poses' and public.est_admin());

drop policy if exists "poses suppr admin" on storage.objects;
create policy "poses suppr admin" on storage.objects
  for delete to authenticated using (bucket_id = 'poses' and public.est_admin());
