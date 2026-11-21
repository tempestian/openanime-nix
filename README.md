# openanime-nix

Nix flake packaging [OpenAnime Desktop](https://github.com/OpenAnime/desktop-ts) ([openani.me](https://openani.me)) directly from official Debian (`.deb`) releases, pre-patched for NixOS without source compilation.

---

[Türkçe README için tıklayın](README.tr.md)

---

## Features

- **Instant binary install:** No heavy Node.js or Electron compilation.
- **Wayland ready:** Pre-configured with Ozone & Wayland flags.
- **Weekly updates:** Automated GitHub Action checks for new upstream releases every Sunday.

## Usage

### Run without installing:

```bash
nix run github:tempestian/openanime-nix
```

---

### In your `flake.nix`:

Add to `inputs` and apply the overlay:

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
    nixosConfigurations.myhostname = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.overlays = [ openanime.overlays.default ];
        }
        ./configuration.nix
      ];
    };
  };
}
```

Now you can simply use `openanime` anywhere in your system or Home Manager packages:

```nix
environment.systemPackages = with pkgs; [
  openanime
];
```
or in Home Manager:
```nix
home.packages = with pkgs; [
  openanime
];
```
