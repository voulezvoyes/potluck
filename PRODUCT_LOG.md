# Potluck — Product Log

## V0.8 — Sep 3, 2026

### Problem observed
The global header leaked space-specific controls onto screens where they had no context, creating an empty pill and unexplained menu. Korean copy read like a literal translation rather than native interface writing. Trace replies looked too much like a blog comment section, and Inbox needed to function as a return path rather than decorative notification UI.

### Decisions
1. **Global vs. contextual navigation**
   - Space switcher, space menu, and `Bring something` appear only inside Week / Person / Trace.
   - Spaces, Inbox, and Profile use the global Potluck header only.

2. **Korean UX writing**
   - Rewrote Korean strings in polite product language.
   - Avoided direct sentence-by-sentence translation from English.
   - User-generated posts remain untranslated.

3. **Replies are secondary**
   - Removed the `Conversation` heading.
   - Replies sit directly below the trace as a small thread.
   - Reply composer is visually smaller so the trace remains the primary object.

4. **Inbox is a return path**
   - Each Inbox row links directly to the relevant Space → Person → Trace.
   - Inbox remains limited to replies/invitations rather than becoming an activity feed.

### Still mock-only
Authentication, persistence, invitations, membership authorization, unread state, and privacy enforcement still require a backend (planned: Supabase).


## V0.9 — Sep 3, 2026

### Navigation repair

Two navigation gaps remained in V0.8:

1. Breadcrumb-style back actions depended on previously rendered screens rather than restoring the destination screen's state.
2. The active space name functioned as a label, so users could not move directly between spaces from inside a space.

### Decisions

- Back actions now explicitly rebuild and navigate to their destination:
  - Trace → Person week
  - Person week → Space week
  - Space week → All spaces
- The active space pill is now a space switcher.
- Switching spaces from the header immediately opens that space's weekly view.
- The switcher also provides a direct return to All spaces.
- The `•••` control remains exclusively for actions on the current space; switching and managing a space stay separate.
- Inbox deep links now restore the full active-space context before opening a trace.

This keeps the primary navigation reversible:
`All spaces ↔ Space ↔ Person ↔ Trace`.
