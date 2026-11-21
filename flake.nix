{
  description = "Nix flake for OpenAnime desktop application (openani.me)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages = rec {
          openanime = pkgs.callPackage ./package.nix { };
          default = openanime;
        };

        apps = rec {
          openanime = flake-utils.lib.mkApp {
            drv = self.packages.${system}.openanime;
            name = "openanime";
          };
          default = openanime;
        };
      }
    ) // {
      overlays.default = final: prev: {
        openanime = final.callPackage ./package.nix { };
      };
    };
}
