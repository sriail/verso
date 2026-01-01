#!/bin/bash
# Build script for Verso WASM

set -e

echo "Building Verso for WASM..."

# Check if wasm-pack is installed
if ! command -v wasm-pack &> /dev/null; then
    echo "Error: wasm-pack is not installed."
    echo "Install it with: cargo install wasm-pack"
    exit 1
fi

# Check if wasm32-unknown-unknown target is installed
if ! rustup target list | grep -q "wasm32-unknown-unknown (installed)"; then
    echo "Installing wasm32-unknown-unknown target..."
    rustup target add wasm32-unknown-unknown
fi

# Build the WASM package
echo "Building WASM package..."
wasm-pack build --target web --out-dir wasm/pkg --features wasm

# Check if wasm-opt is available for optimization
if command -v wasm-opt &> /dev/null; then
    echo "Optimizing WASM binary..."
    wasm-opt -O3 -o wasm/pkg/versoview_bg_opt.wasm wasm/pkg/versoview_bg.wasm
    mv wasm/pkg/versoview_bg_opt.wasm wasm/pkg/versoview_bg.wasm
else
    echo "Warning: wasm-opt not found. Skipping optimization."
    echo "Install binaryen for optimized builds: https://github.com/WebAssembly/binaryen"
fi

echo "Build complete! Output in wasm/pkg/"
echo ""
echo "To test locally, run a local web server:"
echo "  cd wasm && python3 -m http.server 8000"
echo "Then open http://localhost:8000 in your browser"
