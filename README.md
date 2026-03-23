# Error Lens for Zed

A Zed editor extension inspired by the VS Code **Error Lens** experience — currently a scaffold and research base.

## Current Status

This extension is a **minimal scaffold**. No options or settings are implemented yet.

The public Zed extension API does not currently expose the editor decoration or inlay hooks needed to fully recreate VS Code-style Error Lens behavior from a third-party extension.

## What Is Inside the Extension

| File | Purpose |
|------|---------|
| `extension.toml` | Zed extension manifest (id, name, version, description) |
| `Cargo.toml` | Rust crate configuration for WebAssembly output |
| `src/lib.rs` | Minimal extension entry point — registers the extension with Zed |

### `src/lib.rs`

The entry point registers the extension. No logic, no settings, no options are wired up yet.

### `extension.toml`

```toml
id = "error-lens-zed"
name = "Error Lens"
version = "0.1.0"
schema_version = 1
authors = ["Error Lens Contributors"]
description = "VS Code-style inline diagnostic hints for the Zed editor."
repository = "https://github.com/example/error-lens-zed"
```

> There is no settings schema in the extension yet. Any options listed elsewhere are planned for a future release and are **not active**.

## Development

### Prerequisites

- Rust installed via `rustup`
- Zed installed
- WebAssembly target used by Zed extensions

```sh
rustup target add wasm32-wasip2
```

### Build

```sh
cargo build --release --target wasm32-wasip2
```

### Install Locally in Zed

1. Open Zed
2. Open the Extensions page
3. Choose **Install Dev Extension**
4. Select this project directory

## Roadmap

### Phase 1 — Scaffold *(current)*
- [x] Create extension scaffold
- [x] Document current API constraints
- [ ] Confirm behavior against the latest Zed extension API

### Phase 2 — Settings *(blocked on Zed API)*
- [ ] Add extension settings schema once editor-side rendering APIs become available
- [ ] `enabled` — master on/off toggle
- [ ] `max_severity` — filter by severity level
- [ ] `max_message_length` — truncate long messages
- [ ] `show_icons` — enable/disable severity icons
- [ ] `show_only_highest_severity_per_line` — reduce visual clutter

### Phase 3 — Full Rendering *(future)*
- [ ] Inline line-end diagnostic text
- [ ] Severity-aware colors
- [ ] Real-time updates on diagnostic changes

### Phase 4 — Publish
- [ ] Publish extension once required APIs exist

## Notes

- See `docs/implementation-plan.md` for a full technical breakdown of the API gap and architecture plan.
- Until rendering APIs are public