{
  description = "Proteomics + Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      each = f:
        nixpkgs.lib.genAttrs supportedSystems (system:
          let pkgs = import nixpkgs { inherit system; };
          in f pkgs);

    in
    {
      ##########################################################################
      packages = each (pkgs: {
        default = self.packages.${pkgs.system}.openms;

        diann-academia = pkgs.callPackage pkgs/diann-academia.nix { };

        flashlfq = pkgs.callPackage pkgs/flashlfq { };

        metamorpheus = pkgs.callPackage pkgs/metamorpheus { };

        openms = pkgs.callPackage pkgs/openms {
          inherit (pkgs.kdePackages) wrapQtAppsHook qtbase qtsvg;
          python3 = self.packages.${pkgs.system}.python3;
          openmp = pkgs.llvmPackages_12.openmp;
        };

        pyautowrap = pkgs.callPackage pkgs/pyautowrap.nix {
          python3Packages = self.packages.${pkgs.system}.python3.pkgs;
        };

        python3 = pkgs.python3.override {
          packageOverrides = final: prev: {
            cython_openms = prev.cython;
            autowrap = self.packages.${pkgs.system}.pyautowrap;
            pyopenms = self.packages.${pkgs.system}.pyopenms;
          };
        };

        rawfilereader = pkgs.callPackage pkgs/thermoraw/RawFileReader.nix { };

        thermorawfp = pkgs.callPackage pkgs/thermoraw/ThermoRawFileParser.nix {
          RawFileReader = self.packages.${pkgs.system}.rawfilereader;
        };
      });
    };
}
