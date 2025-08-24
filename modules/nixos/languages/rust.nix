{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Rust toolchain
    rustc
    cargo
    rustfmt
    clippy
    
    # Alternative: rustup for managing multiple toolchains
    # rustup
    
    # Development tools
    rust-analyzer # Language server
    cargo-edit # Add/remove dependencies
    cargo-watch # Auto-rebuild on changes
    cargo-audit # Security audits
    cargo-outdated # Check for outdated dependencies
    cargo-release # Release automation
    cargo-expand # Expand macros
    cargo-flamegraph # Performance profiling
    cargo-cross # Cross-compilation
    cargo-nextest # Better test runner
    cargo-machete # Find unused dependencies
    
    # Build tools
    sccache # Shared compilation cache
    mold # Fast linker
    
    # WASM development
    wasm-pack
    wasmtime
    
    # Debugging
    gdb
    lldb
  ];
  
  # Rust environment variables
  environment.variables = {
    RUST_BACKTRACE = "1";
    RUSTFLAGS = "-C link-arg=-fuse-ld=mold"; # Use mold linker for faster builds
  };
}