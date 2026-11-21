# openanime-nix

Nix flake packaging [OpenAnime Desktop](https://github.com/OpenAnime/desktop-ts) ([openani.me](https://openani.me)) directly from the official Debian releases (`.deb`), pre-patched with `autoPatchelfHook` for immediate execution on NixOS without source compilation.

---

[Türkçe README için tıklayın](README.tr.md)

---

## Features

- **Binary packaging:** No heavy Node.js, Electron or native toolchain builds.
- **Wayland & Ozone ready:** Inherits Wayland flags automatically when running on Wayland.
- **Weekly Automated Updates:** A GitHub Action checks for new upstream releases every Sunday, verifies the build with Nix, updates `source.nix`, and commits the changes.

## Usage

### Run directly with Flakes:

```bash
nix run github:tempestian/openanime-nix
```

---

### In your Flake (`flake.nix`):

Add `openanime` to your `inputs`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    openanime = {
      url = "github:tempestian/openanime-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, openanime, ... }@inputs: {
    # Pass inputs or openanime to your configuration
    nixosConfigurations.myhostname = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./configuration.nix ];
    };
  };
}
```

---

### Adding to NixOS (`configuration.nix`):

**Option 1: Directly via `inputs`**
```nix
{ pkgs, inputs, ... }:

{
  environment.systemPackages = [
    inputs.openanime.packages.${pkgs.system}.default
  ];
}
```

**Option 2: Using the Overlay**
```nix
{ pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    inputs.openanime.overlays.default
  ];

  environment.systemPackages = with pkgs; [
    openanime
  ];
}
```

---

### Adding to Home Manager (`home.nix` or `packages.nix`):

**Option 1: Directly via `inputs`**
```nix
{ pkgs, inputs, ... }:

{
  home.packages = [
    inputs.openanime.packages.${pkgs.system}.default
  ];
}
```

**Option 2: Using the Overlay**
```nix
{ pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    inputs.openanime.overlays.default
  ];

  home.packages = with pkgs; [
    openanime
  ];
}
```
