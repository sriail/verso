# Verso WASM Build

This directory contains the WebAssembly build configuration and host page for Verso.

## Overview

This is an **experimental** WASM port of Verso. Due to the complexity of Verso's dependencies (particularly Servo), this is a minimal proof-of-concept implementation that demonstrates:

1. WASM module initialization
2. Basic browser UI in HTML/CSS/JavaScript
3. Canvas-based rendering interface
4. Navigation API structure

## Current Status

⚠️ **Alpha/Proof-of-Concept** - This WASM build is not functional as a full browser yet.

### What Works
- WASM module compilation (with feature flag)
- Basic UI structure and controls
- JavaScript bridge setup

### What Doesn't Work Yet
- Actual page rendering (requires Servo WASM support)
- JavaScript execution (requires SpiderMonkey WASM port)
- Networking (needs fetch API integration)
- File system (needs virtual FS implementation)
- Most browser functionality

## Building

### Prerequisites

1. **Rust toolchain** (stable)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **WASM target**
   ```bash
   rustup target add wasm32-unknown-unknown
   ```

3. **wasm-pack**
   ```bash
   cargo install wasm-pack
   ```

4. **wasm-bindgen-cli** (optional, for manual builds)
   ```bash
   cargo install wasm-bindgen-cli
   ```

5. **binaryen** (optional, for optimization)
   - macOS: `brew install binaryen`
   - Ubuntu: `sudo apt-get install binaryen`
   - Windows: Download from https://github.com/WebAssembly/binaryen/releases

### Build Commands

**Using the build script (recommended):**
```bash
./wasm/build.sh
```

**Manual build:**
```bash
wasm-pack build --target web --out-dir wasm/pkg --features wasm
```

**With optimization:**
```bash
wasm-pack build --target web --out-dir wasm/pkg --features wasm
wasm-opt -O3 -o wasm/pkg/versoview_bg_opt.wasm wasm/pkg/versoview_bg.wasm
mv wasm/pkg/versoview_bg_opt.wasm wasm/pkg/versoview_bg.wasm
```

## Running Locally

After building, start a local web server:

```bash
cd wasm
python3 -m http.server 8000
```

Then open http://localhost:8000 in a modern web browser (Chrome, Firefox, or Safari).

## Architecture

```
┌─────────────────────────────────────┐
│         index.html                  │
│  (Browser UI + JavaScript Loader)   │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      WASM Module (versoview)        │
│  ┌─────────────────────────────┐   │
│  │   VersoBrowser API          │   │
│  │  - initialize()             │   │
│  │  - navigate(url)            │   │
│  │  - go_back/forward()        │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   Future: Servo Integration │   │
│  │  - WebRender (canvas)       │   │
│  │  - Layout Engine            │   │
│  │  - Script Engine            │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

## Known Limitations

### Critical Blockers
1. **Servo** - Not currently WASM-compatible
   - Requires significant refactoring of compositor
   - WebRender needs WASM WebGL/WebGPU backend
   - IPC layer needs web-compatible implementation

2. **SpiderMonkey** - JavaScript engine requires WASM port
   - Complex C++ codebase
   - Needs Emscripten build pipeline
   - FFI bindings need updating

3. **Native Dependencies**
   - `winit` - Window management (native only)
   - `glutin` - OpenGL context (native only)
   - `ipc-channel` - Process IPC (not applicable in WASM)

### Future Work Required

To make this functional, the following major work is needed:

1. **Phase 1: Servo WASM Support**
   - Port Servo's compositor to WebGL/WebGPU
   - Replace native windowing with canvas
   - Implement web-compatible resource loader

2. **Phase 2: JavaScript Engine**
   - Build SpiderMonkey with Emscripten
   - Create WASM FFI bindings
   - Integrate with Servo's script layer

3. **Phase 3: Platform Abstraction**
   - Virtual file system (IndexedDB backed)
   - Fetch-based networking
   - Web Workers for threading
   - Event system translation

4. **Phase 4: Full Integration**
   - End-to-end testing
   - Performance optimization
   - Security hardening
   - Cross-browser compatibility

## Development Notes

### Adding Features

When adding WASM-specific features, use conditional compilation:

```rust
#[cfg(target_arch = "wasm32")]
use web_sys::*;

#[cfg(not(target_arch = "wasm32"))]
use winit::*;
```

### Debugging

WASM debugging in browsers:
- Chrome: DevTools → Sources → WASM modules
- Firefox: DevTools → Debugger → WASM
- Enable source maps for better debugging

### Performance

WASM performance considerations:
- Minimize JS ↔ WASM boundary crossings
- Use `SharedArrayBuffer` for large data transfers
- Optimize hot paths with `wasm-opt`
- Profile with browser DevTools

## Contributing

This is an experimental feature. Contributions are welcome, but please understand:

1. This requires deep knowledge of both Rust and WASM
2. Progress depends on upstream Servo WASM support
3. This is a long-term effort, not a quick fix

Before starting major work, please open an issue to discuss.

## Resources

- [wasm-bindgen Guide](https://rustwasm.github.io/docs/wasm-bindgen/)
- [web-sys Documentation](https://rustwasm.github.io/wasm-bindgen/web-sys/index.html)
- [Servo Project](https://servo.org/)
- [WebAssembly Documentation](https://webassembly.org/)
- [Rust WASM Book](https://rustwasm.github.io/book/)

## License

Same as Verso: Apache-2.0 OR MIT
