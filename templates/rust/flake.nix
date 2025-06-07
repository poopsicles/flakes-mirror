{
  description = "sample rust devenv with toolchain + formatting, run `cargo init`";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      treefmt-nix,
      ...
    }:
    let
      # cribbed from https://isabelroses.com/blog/nix-shells-8#how-about-using-my-overlay
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system:
          let
            overlays = [
              (import rust-overlay)
              (final: prev: {
                toolchain = final.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
              })
            ];
            pkgs = import nixpkgs { inherit system overlays; };
          in
          function pkgs
        );

      treefmtConfig = forAllSystems (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      formatter = forAllSystems (pkgs: treefmtConfig.${pkgs.system}.config.build.wrapper);
      checks = forAllSystems (pkgs: {
        formatting = treefmtConfig.${pkgs.system}.config.build.check self;
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell rec {

          packages =
            with pkgs;
            [
              toolchain
              rust-analyzer
              # openssl
              # pkg-config
              # cargo-nextest
            ]
            ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              # libxkbcommon
              # xorg.libxcb
              # wayland
              # vulkan-loader
            ];

          env = {
            RUST_SRC_PATH = "${pkgs.toolchain}/lib/rustlib/src/rust/library";
            LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath packages}:$LD_LIBRARY_PATH";
          };
        };
      });
    };
}
