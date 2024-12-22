{
  description = "fum's flake templates (with direnv)";

  outputs = { ... }: {
    templates = {
      rust = {
        path = ./rust;
        description = "sample env with toolchain + formatting, run `cargo init`";
      };

      typst = {
        path = ./typst;
        description = "sample env + tinymist";
      };
    };
  };
}