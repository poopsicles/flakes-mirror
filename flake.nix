{
  description = "fum's various flakes that aren't good enough to upstream to nixpkgs";

  # i want to depend on the system's nixpkgs? not sure if this works
  # inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      # ...instead of flake-utils
      # https://isabelroses.com/blog/im-not-mad-im-disappointed-10

      forAllSystems =
        function:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system: function nixpkgs.legacyPackages.${system}
        );
    in
    {
      packages = forAllSystems (pkgs: rec {
        # fonts, mostly stolen from https://github.com/jeslie0/fonts/blob/main/flake.nix
        # with help from fasterthanlime's nix intro https://fasterthanli.me/series/building-a-rust-service-with-nix/part-9
        # and https://yashgarg.dev/posts/nix-custom-fonts

        apple-color-emoji-bin = pkgs.callPackage ./fonts/apple-color-emoji-bin.nix { };
        helvetica = pkgs.callPackage ./fonts/helvetica.nix { };
        helvetica-neue = pkgs.callPackage ./fonts/helvetica-neue.nix { };

        # programs
        switcheroo = pkgs.callPackage ./switcheroo.nix { };

        # default target to build all packages
        default = pkgs.symlinkJoin {
          name = "all";
          paths = [
            apple-color-emoji-bin
            helvetica
            helvetica-neue
            switcheroo
          ];
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);

      templates = {
        rust = {
          path = ./templates/rust;
          description = "sample rust devenv with toolchain + formatting, run `cargo init`";
        };

        typst = {
          path = ./templates/typst;
          description = "sample typst devenv with tinymist + typstyle";
        };
      };
    };
}
