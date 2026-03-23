# Error Lens for Zed: Implementation Plan

## Goal

Build a Zed editor extension that recreates the **Error Lens** experience from VS Code by rendering diagnostics inline at the end of the affected line, with severity-aware styling and low visual noise.

Desired behavior:

- Show inline diagnostic text on the same line as the offending code
- Color-code diagnostics by severity
  - errors: red
  - warnings: yellow
  - info: blue
  - hints: gray
- Prefix messages with severity-specific icons
- Update in real time as diagnostics change
- Respect the active Zed theme where possible

Nice-to-have behavior:

- Toggle inline messages on/off
- Control opacity
- Limit message length
- Show only the highest-severity diagnostic per line
- Slightly dim or fade lines with errors

---

## Current Status

This project is currently a **scaffold and design document**, not a full implementation.

After reviewing the current Zed extension model and public Rust extension API, the conclusion is:

> A third-party Zed extension cannot currently implement true Error Lens-style inline diagnostics using only the public extension API.

This is because the current extension surface does **not** expose the editor rendering hooks required to place styled virtual text or decorations directly inside the buffer.

---

## What Zed Already Supports Natively

Zed already includes built-in inline diagnostics functionality similar to Error Lens.

Users can enable it in their Zed settings:

```/dev/null/settings.json#L1-8
{
  "diagnostics": {
    "inline": {
      "enabled": true,
      "max_severity": null
    }
  }
}
```

This native feature already provides:

- inline diagnostic display to the right of code
- automatic updates as diagnostics change
- theme-aware styling
- severity filtering

Because of that, the immediate practical recommendation for users is to enable Zed's native inline diagnostics.

---

## Why a Third-Party Extension Is Blocked

To reproduce Error Lens faithfully, an extension would need editor APIs for at least some of the following:

- reading diagnostics for the active buffer as they change
- subscribing to diagnostic update events
- inserting inline virtual text at line ends
- attaching decorations or inlays to buffer positions
- styling inline text by severity
- adding icons or custom inline elements
- dimming or highlighting full lines
- reacting to cursor movement and buffer edits in real time

The current public extension API is focused primarily on:

- language server provisioning and configuration
- slash commands
- debugging integration
- snippets, themes, and languages
- context/documentation helpers

It does **not** currently expose the editor decoration surface needed for Error Lens rendering.

---

## Gap Analysis

## Required for Error Lens

### 1. Inline virtual text / inlays
Needed to show text like:

- `✘ type mismatch`
- `⚠ unused variable`
- `ℹ consider using ...`

Status: **Not publicly available to extensions**

### 2. Buffer decoration API
Needed for:

- per-line styling
- severity-specific message colors
- line dimming or fading
- block/inlay placement at line end

Status: **Not publicly available to extensions**

### 3. Diagnostic subscription hooks
Needed so the extension can re-render immediately when diagnostics change.

Status: **Not publicly available in the extension API in the needed form**

### 4. Theme token access for editor diagnostics rendering
Needed to style output using current theme colors rather than hardcoded colors.

Status: **No suitable editor rendering API exposed for this use case**

---

## Feasible Paths Forward

## Path A: Use Native Zed Inline Diagnostics

This is the best practical path today.

### Pros
- Works now
- Theme-aware
- Maintained by Zed
- No custom extension rendering required

### Cons
- Limited customization compared to VS Code Error Lens
- No custom icons
- No custom message selection logic beyond built-in settings
- No extension-defined line dimming or decoration effects

---

## Path B: Wait for Extension API Expansion

If Zed exposes any of the following in future releases, this project becomes viable:

- inlay creation API
- buffer decoration API
- text-range highlight API
- diagnostic event hooks
- buffer open/change/cursor event hooks
- theme token access for custom editor renderers

At that point this extension can move from documentation to implementation.

---

## Path C: Implement as a Zed Core Patch

If the goal is exact Error Lens behavior now, the realistic route is to modify Zed itself rather than build a standalone extension.

This would allow:

- direct access to diagnostics
- line-end inline rendering
- severity-aware icons and colors
- theme token integration
- line dimming/highlighting
- cursor-aware filtering
- overflow and truncation logic

### Pros
- Full control
- Can match VS Code Error Lens closely
- Native performance and UX

### Cons
- Not distributable as a normal third-party extension
- Requires contributing to or maintaining a fork of Zed

---

## Proposed Product Shape for This Repository

Until the public API supports the needed editor hooks, this repository should serve as:

1. a **clean extension scaffold**
2. a **research log**
3. a **feature-ready design**
4. a **future implementation target** once the necessary APIs land

This means the project can still provide value by including:

- extension metadata
- a minimal Rust entrypoint
- roadmap documentation
- implementation notes
- compatibility notes
- suggested native Zed settings

---

## Intended Architecture Once APIs Exist

If future Zed APIs make this possible, the extension should be structured roughly as follows.

## Core Components

### 1. Diagnostic Collector
Responsibilities:

- query diagnostics for the active buffer
- normalize severity values
- group diagnostics by line
- choose the highest-severity diagnostic per line
- debounce updates to avoid excessive redraws

Output:

- a buffer-local list of renderable line annotations

### 2. Message Formatter
Responsibilities:

- map severities to icons
- truncate long messages
- sanitize whitespace/newlines
- optionally append source codes or rule names
- enforce configurable maximum length

Example formatting strategy:

- error -> `✘`
- warning -> `▲`
- info -> `ℹ`
- hint -> `⋯`

### 3. Theme Mapper
Responsibilities:

- map diagnostic severity to theme-aware colors
- derive softened/faded variants for low-contrast rendering
- respect user opacity preferences

Fallback palette if theme tokens are unavailable:

- error: `#ff6b6b`
- warning: `#f7b955`
- info: `#61afef`
- hint: `#7f848e`

### 4. Inline Renderer
Responsibilities:

- place message at end of line
- avoid colliding with code or existing UI
- render only one message per line
- support redraw on diagnostics or settings changes

### 5. Optional Line Decorator
Responsibilities:

- slightly dim or tint lines containing diagnostics
- severity-weighted visual emphasis
- remain subtle enough not to reduce readability

---

## Rendering Rules

These rules should guide the eventual implementation.

### Per-line selection
- Gather all diagnostics affecting a line
- Show only the highest-severity item on that line
- If severities tie, prefer the first diagnostic from the server
- Optionally allow future setting for `show_all_on_line`

### Message placement
- Render at the visual end of the line
- Leave a small gap between source text and inline message
- Truncate with ellipsis if it exceeds available width

### Message formatting
Suggested display format:

- Error: `✘ message`
- Warning: `▲ message`
- Info: `ℹ message`
- Hint: `⋯ message`

### Severity priority
Use this ranking:

1. error
2. warning
3. info
4. hint

### Update strategy
- Recompute on diagnostic changes
- Recompute on buffer edits if needed
- Recompute on settings changes
- Recompute on theme changes if exposed

---

## Suggested Settings Schema

If extension settings support is sufficient, these options would be useful:

```/dev/null/error-lens-settings.json#L1-16
{
  "enabled": true,
  "max_severity": null,
  "max_message_length": 120,
  "opacity": 0.9,
  "show_icons": true,
  "show_only_highest_severity_per_line": true,
  "dim_lines_with_errors": false,
  "padding": 2
}
```

### Setting descriptions

- `enabled`: master toggle
- `max_severity`: filter output by severity
- `max_message_length`: truncate long diagnostics
- `opacity`: visual intensity of inline text
- `show_icons`: enable severity icons
- `show_only_highest_severity_per_line`: reduce clutter
- `dim_lines_with_errors`: optional line emphasis
- `padding`: spacing before the inline message

---

## Recommended MVP Once APIs Land

The first viable version should be intentionally small.

### MVP scope
- inline line-end diagnostic text
- severity-aware colors
- severity icons
- one diagnostic per line
- real-time updates
- max message length setting
- enabled/disabled setting

### Excluded from MVP
- line dimming
- multiple diagnostics per line
- cursor-aware behavior
- wrapped virtual lines
- source display
- per-language overrides

This keeps the first release focused and lowers implementation risk.

---

## Phase Plan

## Phase 0 — Current scaffold
Status: **Do now**

Deliverables:

- `extension.toml`
- `Cargo.toml`
- `src/lib.rs`
- this implementation document
- README with current limitations and native fallback

Outcome:

- repository is ready
- constraints are documented
- future work has a concrete target

---

## Phase 1 — API watch / validation
Status: **Blocked on Zed**

Deliverables:

- track Zed release notes and extension API changes
- verify whether inlay/decorations APIs become public
- validate whether diagnostics are exposed to extensions

Exit criteria:

- public APIs exist for inline decorations and diagnostic updates

---

## Phase 2 — Basic rendering MVP
Status: **Future**

Deliverables:

- diagnostic collector
- per-line severity selection
- message formatter
- inline rendering
- theme-aware severity colors
- settings for enable/disable and max length

Exit criteria:

- inline diagnostics appear in editor reliably
- updates happen automatically when diagnostics change

---

## Phase 3 — UX polish
Status: **Future**

Deliverables:

- opacity control
- overflow truncation improvements
- optional source names
- smarter spacing and padding
- better icon set
- test coverage for formatting and grouping logic

Exit criteria:

- extension feels polished and low-noise

---

## Phase 4 — Advanced visual emphasis
Status: **Future / optional**

Deliverables:

- subtle line dimming or tinting
- cursor-aware display modes
- more advanced filtering options
- per-language configuration

Exit criteria:

- extension provides distinct value beyond native Zed behavior

---

## Risks

### 1. API may remain insufficient
The main risk is that Zed may continue to keep these editor rendering APIs internal.

Impact:
- project remains a scaffold only

Mitigation:
- keep repository lightweight
- document native Zed fallback clearly

### 2. Native Zed feature may close the value gap
If Zed continues improving built-in inline diagnostics, a third-party extension may no longer be worth maintaining.

Impact:
- reduced differentiation

Mitigation:
- focus on features native Zed does not expose yet, such as richer icons, per-line logic, and alternative display policies

### 3. Rendering complexity
Even if APIs become available, inline rendering can create layout edge cases:

- soft wrap interactions
- clipped text
- overlap with code or inlay hints
- theme contrast issues

Mitigation:
- ship narrow MVP first
- prefer truncation over wrapping in early versions

---

## Definition of Done

This project should be considered successfully implemented only when all of the following are true:

- diagnostics render inline at line end
- diagnostics update automatically as LSP state changes
- severity colors are visually distinct and theme-compatible
- only one message per line is shown by default
- messages can be toggled off
- long messages are truncated cleanly
- behavior is stable across common languages and themes

---

## Near-Term Repository Plan

In the short term, this repository should contain:

- a minimal Zed extension scaffold
- documentation of the API limitation
- an explanation of native Zed inline diagnostics
- a future-facing roadmap

It should **not** pretend to provide working Error Lens rendering until the public API makes that possible.

---

## Conclusion

The idea is sound, desirable, and aligned with a real editor UX need.

However, under the current public Zed extension API, this project is **blocked from full implementation** as a third-party extension.

For now:

- use Zed's native inline diagnostics for practical Error Lens behavior
- keep this repository as a prepared scaffold and roadmap
- implement the full feature only if Zed exposes editor decoration/inlay APIs or if the work moves into Zed core

Until then, this project should remain explicit about its status:

> planned, researched, scaffolded — but not yet technically possible as a standalone Zed extension.