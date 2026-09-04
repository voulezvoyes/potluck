-- Potluck V1 beta
-- Run this once in Supabase SQL Editor on a fresh project.
-- Designed for browser clients using authenticated users + RLS.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Member',
  handle text,
  interface_language text not null default 'en' check (interface_language in ('en','ko')),
  created_at timestamptz not null default now()
);

create table if not exists public.spaces (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 80),
  owner_id uuid not null references public.profiles(id) on delete restrict,
  invite_code text not null unique default encode(gen_random_bytes(6),'hex'),
  created_at timestamptz not null default now()
);

create table if not exists public.space_members (
  space_id uuid not null references public.spaces(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','member')),
  joined_at timestamptz not null default now(),
  primary key (space_id,user_id)
);

create table if not exists public.entries (
  id uuid primary key default gen_random_uuid(),
  space_id uuid not null references public.spaces(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  type text not null check (type in ('Made','Learned','Thought','Stuck')),
  body text not null check (char_length(body) between 1 and 5000),
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create table if not exists public.replies (
  id uuid primary key default gen_random_uuid(),
  entry_id uuid not null references public.entries(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 3000),
  created_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete cascade,
  space_id uuid not null references public.spaces(id) on delete cascade,
  entry_id uuid references public.entries(id) on delete cascade,
  type text not null check (type in ('reply')),
  created_at timestamptz not null default now(),
  read_at timestamptz
);

create index if not exists idx_space_members_user on public.space_members(user_id);
create index if not exists idx_entries_space_created on public.entries(space_id,created_at desc);
create index if not exists idx_entries_author_created on public.entries(author_id,created_at desc);
create index if not exists idx_replies_entry_created on public.replies(entry_id,created_at);
create index if not exists idx_notifications_user_unread on public.notifications(user_id,read_at,created_at desc);

-- Auth profile creation
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles(id,display_name)
  values (new.id, coalesce(nullif(split_part(new.email,'@',1),''),'Member'))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Membership helper. SECURITY DEFINER avoids policy recursion.
create or replace function public.is_space_member(p_space_id uuid, p_user_id uuid default auth.uid())
returns boolean
language sql
stable
security definer set search_path = public
as $$
  select exists(
    select 1 from public.space_members
    where space_id=p_space_id and user_id=p_user_id
  );
$$;

create or replace function public.shares_space_with(p_other_user uuid, p_user_id uuid default auth.uid())
returns boolean
language sql
stable
security definer set search_path = public
as $$
  select exists(
    select 1
    from public.space_members a
    join public.space_members b on a.space_id=b.space_id
    where a.user_id=p_user_id and b.user_id=p_other_user
  );
$$;

-- Create/join/leave functions
create or replace function public.create_space(p_name text)
returns uuid
language plpgsql
security definer set search_path=public
as $$
declare v_id uuid;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  insert into public.spaces(name,owner_id) values (trim(p_name),auth.uid()) returning id into v_id;
  insert into public.space_members(space_id,user_id,role) values (v_id,auth.uid(),'owner');
  return v_id;
end;
$$;

create or replace function public.join_space_by_code(p_code text)
returns uuid
language plpgsql
security definer set search_path=public
as $$
declare v_id uuid;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select id into v_id from public.spaces where lower(invite_code)=lower(trim(p_code));
  if v_id is null then raise exception 'Invalid invite code'; end if;
  insert into public.space_members(space_id,user_id,role) values (v_id,auth.uid(),'member')
  on conflict do nothing;
  return v_id;
end;
$$;

create or replace function public.leave_space(p_space_id uuid)
returns void
language plpgsql
security definer set search_path=public
as $$
declare v_owner uuid;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select owner_id into v_owner from public.spaces where id=p_space_id;
  if v_owner=auth.uid() then raise exception 'Owner cannot leave without transferring or deleting the space'; end if;
  delete from public.space_members where space_id=p_space_id and user_id=auth.uid();
end;
$$;

-- Reply notifications
create or replace function public.notify_entry_author_on_reply()
returns trigger
language plpgsql
security definer set search_path=public
as $$
declare v_author uuid; v_space uuid;
begin
  select author_id,space_id into v_author,v_space from public.entries where id=new.entry_id;
  if v_author is not null and v_author<>new.author_id then
    insert into public.notifications(user_id,actor_id,space_id,entry_id,type)
    values(v_author,new.author_id,v_space,new.entry_id,'reply');
  end if;
  return new;
end;
$$;

drop trigger if exists on_reply_notify on public.replies;
create trigger on_reply_notify
after insert on public.replies
for each row execute procedure public.notify_entry_author_on_reply();

-- RLS
alter table public.profiles enable row level security;
alter table public.spaces enable row level security;
alter table public.space_members enable row level security;
alter table public.entries enable row level security;
alter table public.replies enable row level security;
alter table public.notifications enable row level security;

-- Least privilege grants
revoke all on table public.profiles,public.spaces,public.space_members,public.entries,public.replies,public.notifications from anon,authenticated;
grant select,insert,update on public.profiles to authenticated;
grant select,update on public.spaces to authenticated;
grant select,delete on public.space_members to authenticated;
grant select,insert,update,delete on public.entries to authenticated;
grant select,insert,delete on public.replies to authenticated;
grant select,update,delete on public.notifications to authenticated;

grant execute on function public.create_space(text) to authenticated;
grant execute on function public.join_space_by_code(text) to authenticated;
grant execute on function public.leave_space(uuid) to authenticated;
grant execute on function public.is_space_member(uuid,uuid) to authenticated;
grant execute on function public.shares_space_with(uuid,uuid) to authenticated;

-- Profiles: self, or people sharing at least one space
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles for select to authenticated
using (id=auth.uid() or public.shares_space_with(id));

drop policy if exists profiles_insert_self on public.profiles;
create policy profiles_insert_self on public.profiles for insert to authenticated
with check (id=auth.uid());

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self on public.profiles for update to authenticated
using (id=auth.uid()) with check (id=auth.uid());

-- Spaces: members can read; only owner can update
drop policy if exists spaces_select_member on public.spaces;
create policy spaces_select_member on public.spaces for select to authenticated
using (public.is_space_member(id));

drop policy if exists spaces_update_owner on public.spaces;
create policy spaces_update_owner on public.spaces for update to authenticated
using (owner_id=auth.uid()) with check (owner_id=auth.uid());

-- Memberships: members of same space can read; users can delete only their own membership
drop policy if exists members_select_member on public.space_members;
create policy members_select_member on public.space_members for select to authenticated
using (public.is_space_member(space_id));

drop policy if exists members_delete_self on public.space_members;
create policy members_delete_self on public.space_members for delete to authenticated
using (user_id=auth.uid());

-- Entries
drop policy if exists entries_select_member on public.entries;
create policy entries_select_member on public.entries for select to authenticated
using (public.is_space_member(space_id));

drop policy if exists entries_insert_self_member on public.entries;
create policy entries_insert_self_member on public.entries for insert to authenticated
with check (author_id=auth.uid() and public.is_space_member(space_id));

drop policy if exists entries_update_own on public.entries;
create policy entries_update_own on public.entries for update to authenticated
using (author_id=auth.uid()) with check (author_id=auth.uid() and public.is_space_member(space_id));

drop policy if exists entries_delete_own on public.entries;
create policy entries_delete_own on public.entries for delete to authenticated
using (author_id=auth.uid());

-- Replies: visible/insertable only when the reply's entry is in a joined space
drop policy if exists replies_select_member on public.replies;
create policy replies_select_member on public.replies for select to authenticated
using (exists(select 1 from public.entries e where e.id=entry_id and public.is_space_member(e.space_id)));

drop policy if exists replies_insert_self_member on public.replies;
create policy replies_insert_self_member on public.replies for insert to authenticated
with check (author_id=auth.uid() and exists(select 1 from public.entries e where e.id=entry_id and public.is_space_member(e.space_id)));

drop policy if exists replies_delete_own on public.replies;
create policy replies_delete_own on public.replies for delete to authenticated
using (author_id=auth.uid());

-- Notifications: recipient only
drop policy if exists notifications_select_self on public.notifications;
create policy notifications_select_self on public.notifications for select to authenticated
using (user_id=auth.uid());

drop policy if exists notifications_update_self on public.notifications;
create policy notifications_update_self on public.notifications for update to authenticated
using (user_id=auth.uid()) with check (user_id=auth.uid());

drop policy if exists notifications_delete_self on public.notifications;
create policy notifications_delete_self on public.notifications for delete to authenticated
using (user_id=auth.uid());

-- Do not grant direct insert on spaces/members/notifications.
-- Creation/joining/notifications happen only through trusted functions/triggers.
