# Potluck — Product Log

## Sep 3, 2026 — V1 Beta backend transition

The frontend prototype had reached a stable navigation model:

`All spaces ↔ Space ↔ Person ↔ Entry`

with global Inbox and Profile.

The next problem was no longer visual: the product could not be used by two real people because every interaction reset on refresh and privacy existed only as interface copy.

### Decision

Move from mock data to a real Supabase-backed beta before adding AI or further visual features.

### Backend scope

V1 Beta implements only what is necessary for two or more friends to actually use Potluck:

- email authentication
- profile
- multiple spaces
- membership
- invite code / invite link
- entries
- replies
- reply notifications
- unread state
- EN/KO UI preference

### Security requirement

Space privacy is enforced in Postgres Row Level Security, not in frontend filtering.

Direct browser clients receive only a publishable/public key. The service-role key is never exposed to the client.

Space creation and invitation joining use restricted server-side database functions rather than direct client inserts into membership tables.

### Deliberate exclusions

AI synthesis remains excluded until real weekly logs exist.

Also excluded:
- likes/reactions
- generic activity feed
- streaks
- public profiles
- follower graph
- push notifications

These exclusions preserve Potluck's original product thesis: a private reciprocal exchange, not another engagement feed.
