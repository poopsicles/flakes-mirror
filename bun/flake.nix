
{
  description = "nix flake for bun";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    # treefmt-nix = {
    #   url = "github:numtide/treefmt-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    {
      # self,
      nixpkgs,
      flake-utils,
      # treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # treefmtConfig = import ./treefmt.nix;
      in
      {
        # formatter = treefmt-nix.lib.mkWrapper pkgs treefmtConfig;
        # checks.formatting = (treefmt-nix.lib.evalModule pkgs treefmtConfig).config.build.check self;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bun
          ];
        };
      }
    );
}
