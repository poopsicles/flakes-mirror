# flakes

![feature image showing some emojis with the Apple Color Emoji font](feature.png)

fumnanya's personal flake registry of _Stuff I'm Not Legally Allowed to Put on Nixpkgs™_. [^1]

mostly just consists of fonts and flake templates using direnv + nix-direnv:

- programs
  - [switcheroo](./switcheroo.nix): a wrapper for `nixos-rebuild switch`
  - [Mochi](./mochi.nix): a simple spaced-repetition app
- fonts
  - [Apple Color Emoji](fonts/apple-color-emoji.nix)
  - [Helvetica](fonts/helvetica.nix)
  - [Helvetica Neue](fonts/helvetica-neue.nix)
- templates
  - [Rust](templates/rust/)
  - [Typst](templates/typst/)

## usage:

> to make things easier, you can set a [registry](https://nix.dev/manual/nix/2.24/command-ref/new-cli/nix3-registry) and use it in place of the `git+...` url: 
> ```sh
> $ nix registry add fum git+https://codeberg.org/fumnanya/flakes 
> $ nix flake init -t "fum#rust"
> ```

using a template is easy, just `nix flake init -t ...` and `direnv allow`:
```sh
$ mkdir project
$ cd project
$ nix flake init -t "git+https://codeberg.org/fumnanya/flakes#rust"
$ direnv allow
$ cargo init
```

using a package is slightly more involved: first, add the repo to your inputs:
```nix
# in flake.nix

inputs = {
  # add this 👇
  fum.url = "git+https://codeberg.org/fumnanya/flakes";
};
```

if you're using NixOS, add `inputs` to `specialArgs`:
```nix
# in flake.nix

           # bind it here 👇
outputs = { self, ... }@inputs: {
  nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; }; # 👈 add it here
  }
}
```

...then add the packages to your fonts:
```nix
# in configuration.nix

{ inputs, ... }: {
  fonts.packages = with inputs.fum.packages.${pkgs.system}; [
    helvetica
    apple-color-emoji
  ];
}
```

with Home Manager, you need to pass it in with `extraSpecialArgs`:
```nix
# in flake.nix

           # bind it here 👇
outputs = { self, ... }@inputs: {
  nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
    modules = [
      home-manager.nixosModules.home-manager
        {                              # add it here 👇
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
    ];
  }
}
```

and add whatever you need to your packages:

```nix
# in home.nix

{ inputs, ... }: {
  home.packages = with inputs.fum.packages.${pkgs.system}; [
    helvetica
    apple-color-emoji
  ];
}
```

## notes

if you use the Apple Color Emoji font, you probably want to set it up to override others...Nix and Home Manager have options for this:

```nix
# in configuration.nix or home.nix

fonts.fontconfig = {
  enable = true; # excl. to HM
  defaultFonts = {
    emoji = [ "Apple Color Emoji" ];
  };
};

# exclusive to Home Manager...
# ...makes it work better on non-NixOS
targets.genericLinux.enable = true;
```

you can also modify your [fontconfig](https://wiki.archlinux.org/title/Font_configuration#Fontconfig_configuration) to do this instead, an example is [here](https://aur.archlinux.org/cgit/aur.git/tree/75-apple-color-emoji.conf?h=ttf-apple-emoji).

[^1]: see [NixOS/nixpkgs#261100](https://github.com/NixOS/nixpkgs/issues/261100).
