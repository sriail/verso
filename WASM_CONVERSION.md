# WASM Conversion Guide for Verso

This document provides an overview of the WASM conversion effort for the Verso web browser.

## ⚠️ Important Notice

**This is a proof-of-concept implementation.** Full WASM support for Verso requires significant upstream changes to Servo and other dependencies. This initial work establishes the foundation and build infrastructure.

## What Has Been Implemented

### Phase 1: Environment Setup ✅

1. **WASM Build Configuration**
   - Added `.cargo/config.toml` with WASM-specific settings
   - Configured max memory allocation (4GB) for WASM target
   - Set up conditional compilation flags

2. **Dependencies**
   - Added `wasm-bindgen` for Rust ↔ JavaScript interop
   - Added `web-sys` for DOM and Web API access
   - Added `js-sys` for JavaScript standard library
   - Added `wasm-bindgen-futures` for async operations
   - Added `wasm-logger` for browser console logging
   - Added `console_error_panic_hook` for better error messages

3. **Cargo.toml Updates**
   - Added `[lib]` section with `cdylib` crate type for WASM
   - Added `wasm` feature flag
   - Configured WASM-specific dependencies with conditional compilation
   - Updated package metadata

4. **Source Code Structure**
   - Created `src/wasm.rs` module with WASM entry point
   - Added conditional compilation for WASM target
   - Implemented basic `VersoBrowser` API:
     - `new(canvas_id)` - Constructor
     - `initialize()` - Async initialization
     - `navigate(url)` - Navigation
     - `go_back()`, `go_forward()` - History navigation
     - `reload()`, `stop()` - Page control

5. **HTML Host Page**
   - Created `wasm/index.html` with:
     - Modern browser UI (toolbar, address bar, navigation buttons)
     - Canvas element for rendering
     - Loading indicator
     - Error message display
     - Responsive styling
   - JavaScript loader for WASM module
   - Event handlers for user interactions

6. **Build Infrastructure**
   - Created `wasm/build.sh` script
   - Automated build process with wasm-pack
   - Optional optimization with wasm-opt
   - Documentation in `wasm/README.md`

## Build Instructions

### Prerequisites

```bash
# Install Rust (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add WASM target
rustup target add wasm32-unknown-unknown

# Install wasm-pack
cargo install wasm-pack

# (Optional) Install binaryen for optimization
# macOS: brew install binaryen
# Ubuntu: sudo apt-get install binaryen
```

### Building

```bash
# Using the build script (recommended)
./wasm/build.sh

# Or manually
wasm-pack build --target web --out-dir wasm/pkg --features wasm
```

### Testing Locally

```bash
cd wasm
python3 -m http.server 8000
# Open http://localhost:8000 in your browser
```

## Architecture

```
┌──────────────────────────────────────────────────┐
│              Browser (Chrome/Firefox/Safari)      │
│                                                   │
│  ┌─────────────────────────────────────────────┐ │
│  │          index.html (Host Page)             │ │
│  │  ┌───────────────────────────────────────┐  │ │
│  │  │  Toolbar (Back/Forward/Reload/URL)    │  │ │
│  │  └───────────────────────────────────────┘  │ │
│  │  ┌───────────────────────────────────────┐  │ │
│  │  │  Canvas (Rendering Surface)           │  │ │
│  │  └───────────────────────────────────────┘  │ │
│  └─────────────────┬───────────────────────────┘ │
│                    │ JavaScript Bridge            │
│  ┌─────────────────▼───────────────────────────┐ │
│  │        WASM Module (versoview.wasm)         │ │
│  │  ┌─────────────────────────────────────┐   │ │
│  │  │  VersoBrowser API                   │   │ │
│  │  │  • initialize()                     │   │ │
│  │  │  • navigate(url)                    │   │ │
│  │  │  • go_back() / go_forward()         │   │ │
│  │  │  • reload() / stop()                │   │ │
│  │  └─────────────────────────────────────┘   │ │
│  │                                             │ │
│  │  [Future: Servo Integration]                │ │
│  │  • WebRender (WebGL/WebGPU backend)         │ │
│  │  • Layout Engine                            │ │
│  │  • Script Engine (SpiderMonkey)             │ │
│  │  • Networking (Fetch API)                   │ │
│  └─────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────┘
```

## What's NOT Implemented (Future Work)

### Critical Blockers

1. **Servo WASM Support** - Servo is not currently WASM-compatible
   - Compositor needs WebGL/WebGPU backend
   - IPC layer incompatible with WASM
   - Platform-specific code needs abstraction

2. **SpiderMonkey WASM** - JavaScript engine needs separate WASM build
   - Requires Emscripten compilation
   - Complex C++ codebase
   - FFI bindings need updating

3. **Native Dependencies**
   - `winit` - Window management (native only)
   - `glutin` - OpenGL context (native only)  
   - Many Servo sub-crates not WASM-compatible

### Phases 2-9 (From Original Plan)

These phases are **not implemented** and require significant effort:

- **Phase 2**: Dependency Replacement (windowing, file system, networking, threading, graphics)
- **Phase 3**: SpiderMonkey WASM compilation
- **Phase 4**: Full Verso WASM compilation
- **Phase 5**: Virtualization bridge layer
- **Phase 6**: HTTP/HTTPS routing system  
- **Phase 7**: Enhanced HTML host page features
- **Phase 8**: Integration & testing
- **Phase 9**: Deployment

## Current Limitations

### Compilation Status

- ✅ WASM build infrastructure set up
- ✅ Basic module compiles with `--features wasm`
- ❌ Full compilation fails due to:
  - Servo dependencies (not WASM-compatible)
  - Native window management (winit)
  - Platform-specific code paths
  - IPC channels (not applicable in WASM)

### Functionality Status

- ✅ WASM module initialization
- ✅ JavaScript API structure
- ✅ HTML/CSS UI framework
- ❌ No actual browser functionality
- ❌ No page rendering
- ❌ No JavaScript execution
- ❌ No networking
- ❌ No file system

## Next Steps (If Continuing This Work)

### Immediate Priorities

1. **Conditional Compilation Refactoring**
   - Add `#[cfg(not(target_arch = "wasm32"))]` guards around native code
   - Create abstraction layer for platform-specific operations
   - Split modules into native/wasm implementations

2. **Minimal Rendering PoC**
   - Implement canvas-based rendering without full Servo
   - Create simple HTML parser
   - Basic CSS styling
   - Prove the concept works end-to-end

3. **Upstream Contributions**
   - Work with Servo team on WASM support
   - Identify and fix WASM blockers in Servo
   - Contribute platform abstraction layers

### Long-term Goals

1. **Full Servo WASM Port** (months of work)
   - WebRender WASM backend
   - Platform abstraction layer
   - Web-compatible IPC alternative

2. **SpiderMonkey WASM Build** (months of work)
   - Emscripten build configuration
   - FFI bindings update
   - Integration with Servo

3. **Complete Implementation** (year+ of work)
   - All phases from original plan
   - Production-ready browser
   - Performance optimization
   - Cross-browser testing

## Testing

Currently, the WASM module can be built but is not functional:

```bash
# This will compile the WASM module (with many warnings)
./wasm/build.sh

# This will start the server
cd wasm && python3 -m http.server 8000

# Opening in browser will show UI but no functionality
```

## Contributing

This is an experimental feature requiring:
- Deep Rust knowledge
- WASM/web platform expertise  
- Understanding of browser internals
- Patience for long-term project

Before starting work, please:
1. Open an issue to discuss
2. Check if Servo has made progress on WASM support
3. Coordinate with maintainers

## Resources

- [Rust WASM Book](https://rustwasm.github.io/book/)
- [wasm-bindgen Guide](https://rustwasm.github.io/docs/wasm-bindgen/)
- [web-sys Documentation](https://rustwasm.github.io/wasm-bindgen/web-sys/index.html)
- [Servo Project](https://servo.org/)
- [WebAssembly Spec](https://webassembly.org/)

## Conclusion

This implementation provides:
- ✅ Build infrastructure for WASM
- ✅ Basic API structure
- ✅ UI framework
- ✅ Foundation for future work

It does **not** provide:
- ❌ Working browser functionality
- ❌ Page rendering
- ❌ JavaScript execution
- ❌ Any practical use cases yet

Full WASM support requires extensive upstream work in Servo and is a multi-month to multi-year effort.

## License

Apache-2.0 OR MIT (same as Verso)
