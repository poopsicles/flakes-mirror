{
  lix-diff,
  nix-output-monitor,
  writeShellApplication,
}:

(writeShellApplication {
  name = "switcheroo"; # fancy script for `nixos-rebuild switch`
  runtimeInputs = [
    lix-diff
    nix-output-monitor
  ];

  # we don't need set -euo pipefail cos nix does it for us
  # (if we had it, then cleaning up after `nix flake update` failing would be easier)
  text = ''
    if [[ $(uname) = "Linux" ]]; then
      DATA_DIR="/etc/nixos" 
      BUILD="nixos-rebuild build --log-format internal-json -v |& nom --json"
      SWITCH="pkexec nixos-rebuild switch --log-format internal-json -v |& nom --json"
      NOTIFY="notify-send yo 'got a minute?'"
    elif [[ $(uname) = "Darwin" ]]; then
      DATA_DIR="/etc/nix-darwin"
      BUILD="darwin-rebuild build -L |& nom"
      SWITCH="sudo darwin-rebuild switch -L |& nom"
      NOTIFY="osascript -e 'display notification \"got a minute?\" with title \"yo\"'"
    else
      echo "unknown system detected...exiting"
      exit 1
    fi;

    cleanup() {
      echo cleaning up...
      cd "$DATA_DIR"
      if [[ -e result ]]; then rm result; fi
      if [[ -e flake.lock.old ]]; then rm flake.lock.old; fi
    }

    # shellcheck disable=SC2317 # we set this from a trap and shellcheck can't tell it's used
    revert() {
      echo reverting lockfile...
      cd "$DATA_DIR"
      if [[ -e flake.lock.old ]]; then mv flake.lock.old flake.lock; fi
      exit 1
    }

    if [[ $# = 1 && ( "$1" = "-f" || "$1" = "--fast" ) ]]; then # -f/--fast skips updating the lockfiles
      echo "skipping lockfile update..."
      eval "$SWITCH"
      exit 0
    fi;

    cd "$DATA_DIR"
    cp flake.lock flake.lock.old
    trap revert INT TERM
    nix flake update

    cd "$(mktemp -d)"
    eval "$BUILD"
    lix diff /run/current-system result
    printf "\n"

    eval "$NOTIFY"
    read -r -p "switch? [y/N] " response
    if [[ "$response" = "y" ]]; then eval "$SWITCH"; fi

    cleanup
    exit 0
  '';
})
