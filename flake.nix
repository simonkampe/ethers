{
  description = "";

  inputs = {
    nixpkgs.url      = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachSystem
    [ flake-utils.lib.system.x86_64-linux flake-utils.lib.system.aarch64-linux flake-utils.lib.system.x86_64-windows ] (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs =
          import nixpkgs {
            inherit system overlays;
          };

        rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      in rec
      {
        defaultPackage = packages.ethers;

        packages.ethers = pkgs.rustPlatform.buildRustPackage {
          pname = "ethers";
          version = "0.0.0";
          src = ./.;

          # Build type
          buildType = "release";

          # Build type when running nix check
          checkType = "release";

          # Features
          buildNoDefaultFeatures = false;
          buildFeatures = [];
          checkFeatures = [];

          #PROTOC = "${pkgs.protoc-gen-rust}/bin/protoc-gen-rust";
          RUST_BACKTRACE = 1;
          NIX_BUILD_CORES = 8;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          buildInputs = with pkgs; [
          ];

          nativeBuildInputs = with pkgs; [
            rust
            pkg-config
          ];

          meta = with nixpkgs.lib; {
            description = "";
            longDescription = ''
             '';
            homepage = "";
            platforms = platforms.all;
          };
        };

        devShell = pkgs.mkShell {
          CARGO_BUILD_JOBS=12;
          RUST_BACKTRACE="full";

          nativeBuildInputs = with pkgs; [
            # Extra tools
            rust-analyzer
            clippy
          ] ++ packages.ethers.nativeBuildInputs ++ packages.ethers.buildInputs;
        };
      }
    );
}
