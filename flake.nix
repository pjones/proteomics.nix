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
            boost = pkgs.boost189;
            python3 = self.packages.${system}.python3;
            openmp = pkgs.llvmPackages.openmp;
          };

          percolator = pkgs.callPackage pkgs/percolator {
            boost = pkgs.boost186;
          };

          py-build-cmake = pkgs.callPackage pkgs/py-build-cmake.nix {
            python3Packages = self.packages.${system}.python3.pkgs;
          };

          pyopenms-viz = pkgs.callPackage pkgs/pyopenms-viz.nix {
            python3Packages = self.packages.${system}.python3.pkgs;
          };

          python3 = pkgs.python3.override {
            packageOverrides = final: prev: {
              py-build-cmake = self.packages.${system}.py-build-cmake;
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

      ##########################################################################
      # Shell environments for hacking on these projects:
      devShells = each (
        pkgs: system:
        let
          inherit (pkgs) lib;
          gccVer = lib.concatStringsSep "." (lib.take 3 (lib.splitVersion pkgs.libgcc.version));
        in
        {
          # A development environment for OpenMS:
          openms = pkgs.mkShell {
            name = "openms-dev";

            dontFixCmake = true;
            dontStrip = true;
            hardeningDisable = [ "fortify" ];
            cmakeBuildType = "RelWithDebInfo";

            cmakeFlags = self.packages.${system}.openms.cmakeFlags ++ [
              (lib.cmakeBool "CMAKE_EXPORT_COMPILE_COMMANDS" true)
            ];

            QT_PLUGIN_PATH = self.packages.${system}.openms.QT_PLUGIN_PATH;
            PYTHON_LIBSTDCXX = "${pkgs.libgcc.lib}/share/gcc-${gccVer}/python";
            inputsFrom = [ self.packages.${system}.openms ];

            buildInputs = [
              pkgs.clang-tools
              pkgs.ruff # For formatting and linting Python code.
            ];
          };

          # Similar to the above development environment for OpenMS,
          # except debugging flags are set and optimizations are
          # disabled.
          openms-debug = self.devShells.${system}.openms.overrideAttrs (_: {
            name = "openms-debug-dev";
            cmakeBuildType = "Debug";
          });

          # For testing pyOpenMS:
          pyopenms = pkgs.mkShell {
            name = "pyopenms";

            buildInputs = [
              (self.packages.${system}.python3.withPackages (
                pypkgs: with pypkgs; [
                  pyopenms
                ]
              ))
            ];
          };

          # The default development environment is for OpenMS:
          default = self.devShells.${system}.openms;
        }
      );
    };
}
