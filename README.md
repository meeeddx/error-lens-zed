# Error Lens for Zed

A starter project for a Zed extension inspired by the VS Code **Error Lens** experience.

## Goal

The intended experience is:

- Show diagnostics inline at the end of the affected line
- Color-code messages by severity
- Prefix messages with severity icons
- Update in real time as diagnostics change
- Respect Zed theme colors where possible

## Current status

This repository is currently a **scaffold and research base**, not a full implementation.

### Why

At the time this project was generated, Zed already includes built-in inline diagnostics, and the public extension API does not appear to expose the editor decoration/inlay hooks needed for a third-party extension to fully recreate VS Code-style Error Lens behavior.

That means features like these are likely **not implementable in a standalone extension yet**:

- custom inline virtual text rendering in the editor buffer
- custom per-severity inline icons and styling
- line dimming or full-line diagnostic highlighting
- direct subscription to editor diagnostic rendering events for custom UI

## What Zed already supports natively

Zed has built-in inline diagnostics that can be enabled in your user settings:

```json
{
  "diagnostics": {
    "inline": {
      "enabled": true,
      "max_severity": null
    }
  }
}
```

This gives you a native, theme-aware inline diagnostic experience without requiring an extension.

## Purpose of this repository

This project exists to provide:

- a clean Zed extension skeleton in Rust
- a place to track implementation work
- documentation of current API limitations
- a foundation for future development if Zed exposes decoration/inlay APIs to extensions

## Project structure

- `extension.toml` — Zed extension manifest
- `Cargo.toml` — Rust crate configuration for WebAssembly output
- `src/lib.rs` — minimal extension entry point
- `docs/implementation-plan.md` — roadmap and technical notes

## Development

### Prerequisites

- Rust installed via `rustup`
- Zed installed
- WebAssembly target used by Zed extensions

Example setup:

```sh
rustup target add wasm32-wasip2
```

### Install locally in Zed

1. Open Zed
2. Open the Extensions page
3. Choose **Install Dev Extension**
4. Select this project directory

## Roadmap

### Phase 1
- [x] Create extension scaffold
- [x] Document current API constraints
- [ ] Confirm behavior against the latest Zed extension API

### Phase 2
- [ ] Add extension settings/schema if editor-side rendering APIs become available
- [ ] Implement severity filtering and truncation options
- [ ] Render only the highest-severity diagnostic per line
- [ ] Add theme-aware color mapping
- [ ] Explore line fading/dimming support if exposed by Zed

### Phase 3
- [ ] Publish extension once the required APIs exist

## Notes

If your real goal is simply to get Error Lens behavior in Zed today, the best option is to use Zed’s built-in inline diagnostics.

If your goal is to build a publishable extension with custom rendering behavior, this repository is the starting point, but the missing editor APIs are the current blocker.

## License

Add a license before publishing.