# Potluck — V1 Beta

A private weekly exchange for small friend groups.

## Real beta features

- Supabase email magic-link authentication
- multiple private spaces
- invite-code / invite-link joining
- weekly entries
- Made / Learned / Thought / Stuck
- replies
- Inbox / unread reply notifications
- bilingual EN/KO interface
- Row Level Security

## Architecture

Frontend:
- static HTML/CSS/JS
- Vercel hosting
- Supabase JS v2 loaded from CDN

Backend:
- Supabase Auth
- Postgres
- RLS
- SQL functions for create/join/leave
- trigger-based reply notifications

## Setup

Read `SETUP.md`.

Do not use this beta with real private content until:
1. `supabase-schema.sql` has been run successfully.
2. `config.js` contains only the publishable/public browser key.
3. RLS is enabled and policies exist.

## Product principle

Global:
`Spaces → Inbox → Profile`

Inside a space:
`Our week → Person → Entry → Replies`

The interface avoids feeds, likes, streaks, and activity notifications.


## V1.1 first-use flow

Invite link → email authentication → automatic space join → one-screen onboarding → first entry → weekly space.

This update does not change the Supabase schema.
