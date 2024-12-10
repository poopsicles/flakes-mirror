# flakes

templates using direnv + nix-direnv

- [rust](rust/):

  ```sh
  $ mkdir proj
  $ nix flake -t "git+https://codeberg.org/fumnanya/flakes#rust"
  $ direnv allow
  $ cargo init
  ```

  you can set a registry: `nix registry add personal git+https://codeberg.org/fumnanya/flakes && nix flake -t personal#rust`.