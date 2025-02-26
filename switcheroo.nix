{
  writeShellApplication,
  nvd,
  nix-output-monitor,
}:

(writeShellApplication {
  name = "switcheroo"; # fancy script for `nixos-rebuild switch`
  runtimeInputs = [
    nvd
    nix-output-monitor
  ];

  # we don't need set -euo pipefail cos nix does it for us
  # (if we had it, then cleaning up after `nix flake update` failing would be easier)
  text = ''
    cleanup() {
      echo cleaning up...
      cd /etc/nixos
      if [[ -e flake.lock.old ]]; then rm flake.lock.old; fi
    }

    # shellcheck disable=SC2317 # we set this from a trap and shellcheck can't tell it's used
    revert() {
      echo reverting lockfile...
      cd /etc/nixos
      if [[ -e flake.lock.old ]]; then mv flake.lock.old flake.lock; fi
      exit 1
    }

    if [[ $# = 1 && ( $1 = "-f" || $1 = "--fast" ) ]]; then # -f/--fast skips updating the lockfiles
      echo "skipping lockfile update..."
      pkexec nixos-rebuild switch --log-format internal-json -v |& nom --json
      exit 0
    fi;

    cd /etc/nixos
    cp flake.lock flake.lock.old
    trap revert INT TERM;
    nix flake update

    cd "$(mktemp -d)"
    nixos-rebuild build --log-format internal-json -v |& nom --json
    nvd diff /run/current-system result
    printf "\n"

    notify-send yo 'got a minute?'
    read -r -p "switch? [y/N] " response
    if [[ $response = "y" ]]; then pkexec nixos-rebuild switch; fi

    cleanup
    exit 0
  '';
})
