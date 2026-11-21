# openanime-nix

[OpenAnime Masaüstü](https://github.com/OpenAnime/desktop-ts) ([openani.me](https://openani.me)) uygulamasını resmi Debian (`.deb`) paketlerinden doğrudan paketleyen, kaynak koddan derleme gerektirmeyen Nix Flake deposu.

---

[English README](README.md)

---

## Özellikler

- **Hızlı kurulum:** Saatler süren Node.js/Electron derlemesi gerekmez; binary paket saniyeler içinde kurulur.
- **Wayland uyumlu:** Wayland ve Ozone bayrakları önceden ayarlanmıştır.
- **Haftalık güncelleme:** GitHub Actions botu her pazar günü yeni sürüm kontrolü yapar.

## Kullanım

### Kurmadan doğrudan çalıştırma:

```bash
nix run github:tempestian/openanime-nix
```

---

### `flake.nix` dosyanıza ekleme:

`inputs` kısmına ekleyip overlay'i tanımlayın:

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
    nixosConfigurations.makine-adiniz = nixpkgs.lib.nixosSystem {
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

Artık sisteminizde veya Home Manager yapılandırmanızda paketi doğrudan `openanime` olarak kullanabilirsiniz:

```nix
environment.systemPackages = with pkgs; [
  openanime
];
```
veya Home Manager için:
```nix
home.packages = with pkgs; [
  openanime
];
```
