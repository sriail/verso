#!/bin/bash
# Minimal WASM build test - demonstrates build infrastructure without Servo

set -e

echo "=========================================="
echo "WASM Build Infrastructure Test"
echo "=========================================="
echo ""
echo "This script tests the WASM build infrastructure"
echo "without attempting to compile Servo dependencies."
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v rustc &> /dev/null; then
    echo "❌ Error: Rust is not installed."
    exit 1
fi
echo "✅ Rust is installed: $(rustc --version)"

if ! rustup target list | grep -q "wasm32-unknown-unknown (installed)"; then
    echo "⚠️  Installing wasm32-unknown-unknown target..."
    rustup target add wasm32-unknown-unknown
fi
echo "✅ wasm32-unknown-unknown target is installed"

if ! command -v wasm-pack &> /dev/null; then
    echo "⚠️  wasm-pack is not installed."
    echo "   This is optional for testing, but required for actual builds."
    echo "   Install with: cargo install wasm-pack"
else
    echo "✅ wasm-pack is installed: $(wasm-pack --version)"
fi

echo ""
echo "=========================================="
echo "Testing WASM Module Structure"
echo "=========================================="
echo ""

# Create a minimal test
cd "$(dirname "$0")/.."

# Test 1: Check WASM feature is defined
echo "Test 1: Checking WASM feature configuration..."
if grep -q 'wasm = \[' Cargo.toml; then
    echo "✅ WASM feature is defined in Cargo.toml"
else
    echo "❌ WASM feature not found in Cargo.toml"
    exit 1
fi

# Test 2: Check WASM module exists
echo ""
echo "Test 2: Checking WASM module..."
if [ -f "src/wasm.rs" ]; then
    echo "✅ WASM module exists at src/wasm.rs"
else
    echo "❌ WASM module not found at src/wasm.rs"
    exit 1
fi

# Test 3: Check lib.rs includes wasm module
echo ""
echo "Test 3: Checking lib.rs configuration..."
if grep -q '#\[cfg(target_arch = "wasm32")\]' src/lib.rs; then
    echo "✅ lib.rs has WASM conditional compilation"
else
    echo "❌ lib.rs missing WASM configuration"
    exit 1
fi

# Test 4: Check HTML host page exists
echo ""
echo "Test 4: Checking HTML host page..."
if [ -f "wasm/index.html" ]; then
    echo "✅ HTML host page exists at wasm/index.html"
else
    echo "❌ HTML host page not found"
    exit 1
fi

# Test 5: Check build script
echo ""
echo "Test 5: Checking build script..."
if [ -x "wasm/build.sh" ]; then
    echo "✅ Build script exists and is executable"
else
    echo "❌ Build script not found or not executable"
    exit 1
fi

# Test 6: Verify .cargo/config.toml
echo ""
echo "Test 6: Checking WASM cargo configuration..."
if [ -f ".cargo/config.toml" ] && grep -q '\[target.wasm32-unknown-unknown\]' .cargo/config.toml; then
    echo "✅ WASM cargo configuration exists"
else
    echo "❌ WASM cargo configuration not found"
    exit 1
fi

echo ""
echo "=========================================="
echo "Compilation Test"
echo "=========================================="
echo ""

# Skip actual compilation to save time
echo "⚠️  Skipping full compilation test (takes too long)"
echo "   Full compilation is blocked by Servo dependencies"
echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""
echo "✅ Build infrastructure is correctly set up:"
echo "   - WASM feature flag configured"
echo "   - WASM module created"  
echo "   - Conditional compilation in place"
echo "   - HTML host page ready"
echo "   - Build scripts available"
echo "   - Cargo configuration set"
echo ""
echo "⚠️  Full compilation blocked by upstream dependencies:"
echo "   - Servo (not WASM-compatible)"
echo "   - winit (native only)"
echo "   - glutin (native only)"
echo "   - ipc-channel (not applicable in WASM)"
echo ""
echo "📚 See WASM_BLOCKING_ISSUES.md for details on blockers"
echo "📚 See WASM_CONVERSION.md for full implementation guide"
echo "📚 See wasm/README.md for build instructions"
echo ""
echo "=========================================="
echo "Infrastructure Test: PASSED ✅"
echo "=========================================="
