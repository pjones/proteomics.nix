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
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
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

          diatracer = pkgs.callPackage pkgs/diatracer.nix {
            msfragger = self.packages.${system}.msfragger;
          };

          flashlfq = pkgs.callPackage pkgs/flashlfq { };

          maxquant = pkgs.callPackage pkgs/maxquant.nix { };

          metamorpheus = pkgs.callPackage pkgs/metamorpheus { };

          msfragger = pkgs.callPackage pkgs/msfragger.nix { };

          msgfplus = pkgs.callPackage pkgs/msgfplus.nix { };

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

          pyopenms = self.packages.${system}.openms.pyopenms;

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

          # Docker container will all tools installed:
          container = pkgs.dockerTools.buildLayeredImage {
            name = "proteomics.nix";
            tag = "latest";

            contents = [
              pkgs.bashInteractive
              pkgs.coreutils
            ]
            ++ (with self.packages.${system}; [
              comet
              diann-academia
              flashlfq
              metamorpheus
              msgfplus
              openms
              percolator
              python3
              rawfilereader
              thermorawfp
            ]);
          };
        }
      );

      ##########################################################################
      # Build and check all packages that we have the source for:
      checks = each (
        pkgs: system: pkgs.lib.filterAttrs (_: pkg: !(pkg.passthru.manual or false)) self.packages.${system}
      );

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
            buildInputs = [ pkgs.clang-tools ];
          };

          # Similar to the above development environment for OpenMS,
          # except debugging flags are set and optimizations are
          # disabled.
          openms-debug = self.devShells.${system}.openms.overrideAttrs (_: {
            name = "openms-debug-dev";
            cmakeBuildType = "Debug";
          });

          # The default development environment is for OpenMS:
          default = self.devShells.${system}.openms;
        }
      );
    };
}
