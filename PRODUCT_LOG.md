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


## Sep 3, 2026 — V1.1: first-use UX

Real authentication and persistence exposed a new problem: the creator understood the product model, but a first-time user did not know what action to take or what the four entry types meant.

### Changes
- Invite links now attempt to join the target space automatically after authentication.
- First entry into a space shows one lightweight onboarding screen.
- Made / Learned / Thought / Stuck each receive one-sentence explanations.
- Completely empty weeks show a direct first-entry CTA.
- Onboarding is remembered per user × space in the browser and does not become persistent tutorial chrome.

### Principle
Explain only where uncertainty is highest: joining, first entry, and an empty space.


## Sep 3, 2026 — V1.2: adaptive weekly view

### Problem
The weekly view visually assumed a six-person group. With one or two members, content occupied only a small part of the canvas; on mobile, desktop card widths created narrow text columns and poor readability.

The overview also surfaced only one entry per person, weakening the product's Made / Learned / Thought / Stuck model.

### Decision
Make the weekly overview responsive to group size and content density.

### Changes
- 1 member: wide editorial layout with a constrained reading width.
- 2 members: two-column layout.
- 3+ members: adaptive grid.
- Mobile: always one full-width vertical column.
- Each person preview can surface one entry per populated category.
- Empty categories are hidden in the group overview.
- Personal week pages remain the detailed view.
- Mobile primary capture control keeps an explicit `+ Add` label instead of becoming a symbol-only button.

### Product principle
Potluck is designed primarily for small groups. The interface should look strongest at the moment a group has only one or two active members, not only when all six slots are full.


## Sep 3, 2026 — V1.3: installable web app

### Problem
Potluck is designed for repeated weekly return, but a browser bookmark makes the product feel temporary and forces users to recover the URL.

### Decision
Make Potluck installable as a Progressive Web App before pursuing App Store / Play Store packaging.

### Changes
- Web app manifest
- iOS home-screen metadata and icon
- Android/Chromium install prompt support
- Minimal service worker for app-shell caching
- Install affordance on the Spaces screen
- iPhone-specific instructions for Safari → Share → Add to Home Screen
- Standalone display mode so an installed Potluck opens without normal browser chrome

### Security / data note
The service worker does not cache `config.js`. Authentication and Supabase data remain network-backed. No database schema change is required.

## Sep 3, 2026 — V1.3.1: lowercase wordmark

- Standardized the visible brand wordmark to `potluck`.
- Removed the symbol-style app icon.
- Home-screen icons now use only the lowercase `potluck` wordmark in Pretendard.
- Bundled Pretendard Variable locally so the web wordmark and app icon use the same type family.
