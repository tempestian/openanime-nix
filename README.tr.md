# openanime-nix

[OpenAnime Masaüstü](https://github.com/OpenAnime/desktop-ts) ([openani.me](https://openani.me)) uygulamasını resmi Debian (`.deb`) paketlerinden doğrudan paketleyen, `autoPatchelfHook` ile NixOS ortamına anında uyarlayan ve kaynak koddan derleme gerektirmeyen Nix Flake deposu.

---

[English README](README.md)

---

## Özellikler

- **Hızlı İkili (Binary) Kurulum:** Ağır Node.js, Electron veya yerel derleme araç zinciri gerektirmez; paket saniyeler içinde kurulur.
- **Wayland ve Ozone Desteği:** Wayland ortamında çalıştırıldığında gerekli pencere ve Ozone bayraklarını otomatik olarak devralır.
- **Haftalık Otomatik Güncelleme:** GitHub Actions botu her pazar günü yeni bir resmi sürüm yayımlanıp yayımlanmadığını denetler, Nix ortamında derlemeyi doğrular, `source.nix` dosyasını günceller ve değişiklikleri commitler.

## Kullanım

### Doğrudan Flake ile Çalıştırma:

Sisteme kurmadan doğrudan çalıştırmak için:

```bash
nix run github:tempestian/openanime-nix
```

---

### Flake Yapılandırmanıza Ekleme (`flake.nix`):

`inputs` bloğuna `openanime` girdisini ekleyin:

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
    # inputs veya openanime girdisini modüllere aktarın
    nixosConfigurations.makine-adiniz = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./configuration.nix ];
    };
  };
}
```

---

### NixOS Yapılandırmasına Ekleme (`configuration.nix`):

**Yöntem 1: Doğrudan `inputs` Üzerinden**
```nix
{ pkgs, inputs, ... }:

{
  environment.systemPackages = [
    inputs.openanime.packages.${pkgs.system}.default
  ];
}
```

**Yöntem 2: Overlay ile (`with pkgs;` Kullanımı)**
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

### Home Manager Yapılandırmasına Ekleme (`home.nix` veya `packages.nix`):

**Yöntem 1: Doğrudan `inputs` Üzerinden**
```nix
{ pkgs, inputs, ... }:

{
  home.packages = [
    inputs.openanime.packages.${pkgs.system}.default
  ];
}
```

**Yöntem 2: Overlay ile (`with pkgs;` Kullanımı)**
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
