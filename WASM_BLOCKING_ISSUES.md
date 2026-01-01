# WASM Compilation Blocking Issues

This document tracks the known blocking issues for WASM compilation of Verso.

## Status: ❌ BLOCKED

Full WASM compilation is currently blocked by several critical dependencies that are not WASM-compatible.

## Critical Blockers

### 1. Servo Dependencies (MAJOR BLOCKER)

All Servo git dependencies are not WASM-compatible:

```toml
# From Cargo.toml - ALL of these are native-only:
background_hang_monitor = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
base = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
canvas = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
compositing_traits = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
constellation = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
devtools = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
embedder_traits = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
fonts = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
layout_thread_2020 = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
media = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
net = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
script = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
webgpu = { git = "https://github.com/servo/servo.git", rev = "5e2d42e" }
# ... and many more
```

**Issue**: These crates contain:
- Platform-specific code (Windows/Linux/macOS)
- IPC channels (not applicable in WASM)
- Thread management (incompatible with Web Workers)
- File system access (std::fs)
- Native OpenGL context management

**Solution Required**: 
- Upstream work in Servo to add WASM support
- Platform abstraction layer in each crate
- Alternative IPC mechanism for WASM
- WebGL/WebGPU backend for compositor
- Virtual file system implementation

**Estimated Effort**: 6+ months of full-time work across Servo team

### 2. Winit (Window Management)

```toml
winit = { version = "0.30", features = ["rwh_06"] }
```

**Issue**: Winit is for native window management and doesn't work in WASM browser environment.

**Used In**:
- `src/main.rs` - Event loop
- `src/window.rs` - Window creation and management
- `src/verso.rs` - Main application

**Solution Required**:
- Create web-sys abstraction layer
- Replace window management with canvas operations
- Rewrite event handling for DOM events

**Estimated Effort**: 2-3 weeks

### 3. Glutin (OpenGL Context)

```toml
glutin = "0.32.0"
glutin-winit = "0.5.0"
```

**Issue**: OpenGL context management for native platforms only.

**Solution Required**:
- Replace with WebGL context from web-sys
- Modify compositor to use WebGL/WebGPU
- Update all GL calls to web-compatible versions

**Estimated Effort**: 2-4 weeks

### 4. IPC Channel

```toml
ipc-channel = "0.19"
```

**Issue**: Inter-process communication not applicable in WASM (single process).

**Used In**:
- Communication between embedder and Servo
- Message passing between components

**Solution Required**:
- Create message-passing abstraction
- Replace with direct function calls or Web Workers
- Restructure architecture for single-process model

**Estimated Effort**: 3-4 weeks

### 5. Platform-Specific Dependencies

```toml
# macOS/Windows
muda = "0.15"
objc2 = "0.5"
objc2-foundation = { version = "0.2.2" }
objc2-app-kit = { version = "0.2" }

# All platforms
notify-rust = "4.11.5"
arboard = "3.4.0"  # Clipboard
```

**Issue**: These are native-only and need web-sys equivalents.

**Solution Required**:
- Conditional compilation to exclude on WASM
- Web API equivalents (Web Notifications API, Clipboard API)
- Feature detection and graceful degradation

**Estimated Effort**: 1-2 weeks

### 6. File System Access

**Issue**: Uso of `std::fs` throughout codebase, especially in:
- `src/storage.rs`
- `src/bookmark.rs`
- `src/download.rs`
- Configuration loading

**Solution Required**:
- Virtual file system abstraction
- IndexedDB backend for persistence
- In-memory fallback for temporary files

**Estimated Effort**: 2-3 weeks

### 7. Networking

```toml
reqwest = { version = "0.12", features = ["json", "blocking"] }
```

**Issue**: Native HTTP client, blocking operations not allowed in WASM.

**Solution Required**:
- Replace with web-sys fetch API
- Make all operations async
- Handle CORS restrictions

**Estimated Effort**: 1-2 weeks

## Secondary Issues

### WebRender

```toml
webrender = { git = "https://github.com/servo/webrender" }
```

**Issue**: May not be fully WASM-compatible, needs WebGL/WebGPU backend.

**Solution Required**: Verify and potentially patch WebRender for WASM.

### SpiderMonkey (JavaScript Engine)

Not directly a dependency in Cargo.toml, but required by Servo's script crate.

**Issue**: SpiderMonkey is C++ and needs separate WASM compilation with Emscripten.

**Solution Required**:
- Build SpiderMonkey with Emscripten
- Create WASM FFI bindings
- Integrate with Servo's script system

**Estimated Effort**: 2-3 months

## Compilation Strategy

Given these blockers, here's a phased approach:

### Phase 1: Foundation (DONE ✅)
- WASM build configuration
- Basic WASM module structure
- HTML host page
- Build scripts

### Phase 2: Conditional Compilation (Next Step)
- Add `#[cfg(not(target_arch = "wasm32"))]` guards
- Create platform abstraction layer
- Split native and WASM implementations

### Phase 3: Minimal Browser (Without Servo)
- Simple HTML parser (not using Servo)
- Basic CSS (not using Servo)
- Canvas rendering
- Prove the concept works

### Phase 4: Incremental Servo Integration
- Port one Servo component at a time
- Start with simpler components
- Work with Servo team on upstream changes

### Phase 5: Full Integration
- All Servo components WASM-compatible
- SpiderMonkey integration
- Full feature parity

## Quick Test

To see compilation errors yourself:

```bash
# This will fail with many errors:
cargo check --target wasm32-unknown-unknown --features wasm --lib

# Expected errors:
# - winit not available for wasm32-unknown-unknown
# - glutin not available for wasm32-unknown-unknown  
# - Various Servo crates failing to compile
# - IPC channel issues
# - Platform-specific code errors
```

## Realistic Assessment

**Can this be done?** Yes, technically.

**Should this be done?** Only if:
- Upstream Servo is willing to accept WASM support
- Sufficient resources (6+ months of development time)
- Real use case for browser-in-browser
- Team with Rust + WASM + browser internals expertise

**Current status**: Proof-of-concept infrastructure only.

**Next realistic step**: Focus on Servo WASM support upstream, then revisit.

## Alternative Approaches

### Option 1: Minimal Custom Browser (Recommended for PoC)
- Don't use Servo
- Build minimal HTML/CSS renderer from scratch
- Use existing WASM HTML parsers (html5ever)
- Simple layout engine
- Prove browser-in-browser concept
- **Estimated effort**: 2-3 months

### Option 2: Wait for Servo WASM
- Monitor Servo project for WASM support
- Contribute to Servo WASM effort
- Revisit when Servo is WASM-ready
- **Estimated effort**: Wait 1-2 years + 2-3 months integration

### Option 3: Use Different Engine
- Investigate other WASM-compatible layout engines
- Consider servo-independent approach
- Rewrite using web-platform-compatible architecture
- **Estimated effort**: 3-6 months

## Conclusion

Full WASM compilation is **blocked** by critical upstream dependencies.

The infrastructure created in Phase 1 provides:
- ✅ Build system
- ✅ API structure  
- ✅ Host page
- ✅ Documentation

But cannot provide working browser without:
- ❌ Servo WASM support
- ❌ Platform abstraction layer
- ❌ Significant architectural changes

**Recommendation**: This should be considered a **research prototype** showing what infrastructure would be needed, not a production-ready solution.
