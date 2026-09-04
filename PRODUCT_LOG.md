# Product Log

## Sep 3, 2026 — Spatial overview prototype

### Current product hypothesis
A private shared space for small friend groups to keep a trace of what they are making, learning, thinking about, and getting stuck on over time.

### Home job
Answer “What has everyone been up to this week?” without requiring a click.

### Layout decision
Test a member-first grid. On mobile, six members appear as a 3×2 spatial set (3 rows × 2 columns); desktop expands to 2×3 (2 rows × 3 columns).

This is not justified by aesthetics alone. Each member receives comparable spatial presence so posting frequency does not determine visibility.

### Progressive disclosure
Group overview → Person × Week → Trace → Conversation.

The person view uses a four-part matrix (Made / Learned / Thought / Stuck). This adds a layer, but each layer has a distinct job:
- Group: scan everyone.
- Person × Week: understand one person’s week without reading a feed.
- Trace: read context and reply.

If testing shows users repeatedly need two taps just to read what they care about, collapse the person matrix and trace detail into one layer.

### Open questions
- Is a 3×2 mobile overview readable with real content?
- Are four categories useful or overly rigid?
- Do people want to browse by person, or by trace?
- Does the matrix make a week easier to understand than a chronological list?
- Is commenting frequent enough to justify a dedicated trace-detail layer?


## Sep 3, 2026 — Prototype rendering fix

The first V0.2 file rendered the static shell but not the member cards because a JavaScript string in the mock dataset contained an unescaped apostrophe. The browser therefore stopped parsing the script before `renderHome()` ran.

V0.3 fixes the dataset serialization and restores the six-person realistic demo state. No product decision changed; this was an implementation bug.

## Sep 3, 2026 — V0.4

Renamed the working product from **Between** to **Potluck**. The metaphor frames the social model as reciprocal small-group sharing: each person brings heterogeneous pieces of their week into a shared space without requiring equal volume or polish.

The deployed V0.3 read too strongly as an editorial archive. V0.4 uses **Pretendard** for interface and log content and reserves **ChosunIlbo Myungjo** for the weekly headline. Rounded-card framing is reduced in favor of dividers and whitespace, with a lighter neutral palette and one restrained accent.

The 3×2 group overview and person-level information architecture remain unchanged so the next test isolates visual-language changes rather than changing structure at the same time.

Still unvalidated: whether the overview creates curiosity, whether the person layer earns its navigation step, and whether “Bring something” is clear without overextending the Potluck metaphor.


## Sep 3, 2026 — V0.5: from concept screen to app shell

### Home density
V0.4 exposed multiple entries per member and effectively summarized each person before they were opened. This increased scanning cost and weakened the role of the person-level view.

**Decision:** surface one representative trace per member plus lightweight category hints.

Updated hierarchy:
- Group = glimpse
- Person × Week = understand
- Trace = discuss

### Visual hierarchy
The large “What has everyone been up to?” headline visually overpowered the Potluck brand and made the home screen read like an editorial landing page.

**Decision:** replace it with a smaller “Our week” heading and preserve the serif treatment only as a restrained editorial cue.

### Alignment
Different entry lengths caused Made / Learned / Thought sections to misalign across member cards. Rather than forcing equal row heights or truncating multiple entries, V0.5 removes multiple category rows from the home view entirely.

### Spatial layout
Desktop content is constrained to a narrower centered shell with stronger side padding. The member grid keeps equal spatial presence but removes most vertical borders, using whitespace and a single row divider instead.

### App shell
The concept requires one user to participate in multiple private groups, but V0.4 only represented one group.

V0.5 adds mock:
- space switcher
- multiple spaces
- profile settings
- group settings
- member list
- invite affordance

No backend behavior is implied yet.

### Typography and rhythm
Pretendard remains the primary interface and reading typeface. ChosunIlbo Myungjo is limited to top-level editorial headings. Detail, capture, comments, and settings now share a more consistent line-height and spacing system.

### Open questions
- Is one representative trace enough to create curiosity?
- Should the featured trace be newest, manually selected, or system-selected?
- Does the person matrix earn its extra navigation step?
- Do users treat different spaces as meaningfully different contexts?
