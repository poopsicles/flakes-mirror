{
  description = "nix flake for rust";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
            (final: prev: {
              toolchain = final.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
            })
          ];
        };

        treefmtConfig = import ./treefmt.nix;
      in
      {
        formatter = treefmt-nix.lib.mkWrapper pkgs treefmtConfig;
        checks.formatting = (treefmt-nix.lib.evalModule pkgs treefmtConfig).config.build.check self;

        devShells.default = pkgs.mkShell rec {
          packages = with pkgs; [
            toolchain
            rust-analyzer
            # openssl
            # pkg-config
            # cargo-nextest
          ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [      
            # libxkbcommon
            # xorg.libxcb
            # wayland
            # vulkan-loader
          ];

          env = {
            RUST_SRC_PATH = "${pkgs.toolchain}/lib/rustlib/src/rust/library";
            LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath packages}:$LD_LIBRARY_PATH";
          };
        };
      }
    );
}
