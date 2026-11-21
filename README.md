# openanime-nix

Nix flake packaging [OpenAnime Desktop](https://github.com/OpenAnime/desktop-ts) ([openani.me](https://openani.me)) directly from the official Debian releases (`.deb`), pre-patched with `autoPatchelfHook` for immediate execution on NixOS without source compilation.

## Features

- **Binary packaging:** No heavy Node.js, Electron or native toolchain builds.
- **Wayland & Ozone ready:** Inherits Wayland flags automatically when running on Wayland.
- **Weekly Automated Updates:** A GitHub Action checks for new upstream releases every Sunday, verifies the build with Nix, updates `source.nix`, and commits the changes.

## Usage

### Run directly with Flakes:

```bash
nix run github:tempestian/openanime-nix
```

### In your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    openanime.url = "github:tempestian/openanime-nix";
    openanime.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, openanime, ... }: {
    # In your home-manager or nixos configuration:
    # environment.systemPackages = [ openanime.packages.${system}.default ];
  };
}
```
