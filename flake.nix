{
  description = "fum's flake templates (with direnv)";

  outputs = { self, ... }: {
    templates = {
      rust = {
        path = ./rust;
        description = "sample rust project with toolchain + formatting";
      };
    };
  };
}