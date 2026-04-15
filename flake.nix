{
  description = "Proteomics + Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      each =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          let
            pkgs = import nixpkgs { inherit system; };
          in
          f pkgs system
        );

    in
    {
      ##########################################################################
      packages = each (
        pkgs: system: {
          default = self.packages.${system}.openms;

          comet = pkgs.callPackage pkgs/comet.nix { };

          diann-academia = pkgs.callPackage pkgs/diann-academia.nix { };

          flashlfq = pkgs.callPackage pkgs/flashlfq { };

          metamorpheus = pkgs.callPackage pkgs/metamorpheus { };

          # Could not transfer artifact
          # uk.ac.ebi.jmzidml:jmzidentml:pom:1.2.11 from/to
          # nexus-ebi-release-repo
          # (https://www.ebi.ac.uk/Tools/maven/repos/content/groups/ebi-repo/):
          # status code: 401, reason phrase: Unauthorized (401)
          #
          # msgfplus = pkgs.callPackage pkgs/msgfplus.nix { };

          openms = pkgs.callPackage pkgs/openms {
            inherit (pkgs.kdePackages) wrapQtAppsHook qtbase qtsvg;
            python3 = self.packages.${system}.python3;
            openmp = pkgs.llvmPackages.openmp;
          };

          percolator = pkgs.callPackage pkgs/percolator {
            boost = pkgs.boost186;
          };

          pyautowrap = pkgs.callPackage pkgs/pyautowrap.nix {
            python3Packages = self.packages.${system}.python3.pkgs;
          };

          pyopenms-viz = pkgs.callPackage pkgs/pyopenms-viz.nix {
            python3Packages = self.packages.${system}.python3.pkgs;
          };

          pyopenms = self.packages.${system}.openms.pyopenms;

          python3 = pkgs.python3.override {
            packageOverrides = final: prev: {
              autowrap = self.packages.${system}.pyautowrap;
              pyopenms = self.packages.${system}.openms.pyopenms;
              pyopenms-viz = self.packages.${system}.pyopenms-viz;
            };
          };

          rawfilereader = pkgs.callPackage pkgs/thermoraw/RawFileReader.nix { };

          thermorawfp = pkgs.callPackage pkgs/thermoraw/ThermoRawFileParser.nix {
            RawFileReader = self.packages.${system}.rawfilereader;
          };
        }
      );

      ##########################################################################
      # Build and check everything:
      checks = each (pkgs: system: self.packages.${system});
    };
}
