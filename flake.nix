{
  description = "OpenMS Package and Development Environment";

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

      # Function to generate a set based on supported systems:
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Attribute set of nixpkgs for each system:
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
        });
    in
    {
      ##########################################################################
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};

          python3 = pkgs.python3.override {
            packageOverrides = final: prev: {
              autowrap = self.packages.${system}.pyautowrap;
              pyopenms = self.packages.${system}.pyopenms;
            };
          };
        in
        {
          inherit python3;
          default = self.packages.${system}.openms;

          buildenv = pkgs.callPackage pkgs/buildenv.nix {
            openms = self.packages.${system}.openms;
          };

          diann-academia = pkgs.callPackage pkgs/diann-academia.nix { };

          dockerimg = pkgs.callPackage pkgs/dockerimg.nix {
            openms = self.packages.${system}.openms;
          };

          flashlfq = pkgs.callPackage pkgs/flashlfq { };

          openms = pkgs.callPackage pkgs/openms.nix {
            inherit python3;
            inherit (pkgs.kdePackages) wrapQtAppsHook qtbase qtsvg;
            openmp = pkgs.llvmPackages_12.openmp;
          };

          pyautowrap = pkgs.callPackage pkgs/pyautowrap.nix { };

          pyopenms = pkgs.callPackage pkgs/pyopenms.nix {
            openms = self.packages.${system}.openms.override (_: {
              enablePython = true;
            });
          };

          rawfilereader = pkgs.callPackage pkgs/thermoraw/RawFileReader.nix { };

          thermorawfp = pkgs.callPackage pkgs/thermoraw/ThermoRawFileParser.nix {
            RawFileReader = self.packages.${system}.rawfilereader;
          };
        });

      ##########################################################################
      apps = forAllSystems (system: {
        thermorawfp = {
          type = "app";
          program = "${self.packages.${system}.thermorawfp}/bin/ThermoRawFileParser";
        };
      });

      ##########################################################################
      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = self.devShells.${system}.openms;

          # For writing scripts with pyOpenMS:
          pyopenms = pkgs.mkShell {
            buildInputs = [
              (self.packages.${system}.python3.withPackages (pypkgs: with pypkgs; [
                black
                pyopenms
              ]))
            ];
          };

          # For working on the OpenMS code:
          openms = pkgs.mkShell {
            dontFixCmake = 1;

            cmakeFlags =
              self.packages.${system}.openms.cmakeFlags ++ [
                # Ask CMake to create extra files for clangd:
                "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
                "-DCMAKE_BUILD_TYPE=Debug"
              ];

            QT_PLUGIN_PATH = "${pkgs.kdePackages.qtwayland}/lib/qt-6/plugins/";
            inputsFrom = builtins.attrValues self.packages.${system};
            buildInputs = [ pkgs.clang-tools ];
          };

          # For working on quantms:
          quantms = pkgs.mkShell {
            buildInputs = [
              pkgs.nextflow
              pkgs.apptainer
            ];
          };
        });
    };
}
