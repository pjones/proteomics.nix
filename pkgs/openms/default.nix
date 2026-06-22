{
  # Package helpers:
  lib,
  stdenv,
  wrapQtAppsHook,
  writableTmpDirAsHomeHook,
  fixDarwinDylibNames,

  # Source and version from the flake:
  src,
  version,

  # Dependencies:
  arrow-cpp,
  boost,
  bzip2,
  cmake,
  coinmp,
  curl,
  darwin,
  dockerTools,
  doxygen,
  eigen,
  glpk,
  graphviz,
  kissfft,
  libsvm,
  libzip,
  openmp,
  opentims,
  python3,
  qtbase,
  qtsvg,
  ruby,
  xercesc,
  xz,
  yaml-cpp,
  zlib,
  zstd,

  # Flags:
  enablePython ? true,
}:

let
  # Build-time Python dependencies:
  pythonAndPackages = python3.withPackages (
    py-pkgs: with py-pkgs; [
      build
      cython
      nanobind
      numpy
      pandas
      pip
      py-build-cmake
      pytest
      setuptools
      wheel
    ]
  );

  # The actual derivation:
  package = stdenv.mkDerivation {
    inherit src version;
    pname = "OpenMS";

    doCheck = true;
    checkTarget = "test";
    enableParallelBuilding = true;

    nativeBuildInputs = [
      cmake
      doxygen
      wrapQtAppsHook
    ]
    ++ lib.optionals stdenv.isDarwin [
      fixDarwinDylibNames
      darwin.sigtool
      ruby
    ];

    nativeCheckInputs = [
      # File_test checks for a home directory :(
      writableTmpDirAsHomeHook
    ];

    cmakeFlags = [
      # Builds don't have access to the network:
      (lib.cmakeBool "ENABLE_UPDATE_CHECK" false)

      # Boost in nixpkgs doesn't have static libs:
      (lib.cmakeBool "BOOST_USE_STATIC" false)

      # Git objects not available at build time:
      (lib.cmakeBool "GIT_TRACKING" false)

      # Build with Parquet support:
      (lib.cmakeBool "WITH_PARQUET" true)

      # Do we want Python?
      (lib.cmakeBool "PYOPENMS" enablePython)

      # Python dependencies are already available in the build
      # environment we don't need uv:
      (lib.cmakeBool "WITH_UV" false)

      # openms-thermo-bridge doesn't currently build in this repo
      (lib.cmakeBool "WITH_THERMO_RAW" false)

      # Header-only dependencies:
      (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_PYLMCF" "${python3.pkgs.pylmcf.src}")
      (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_WNET" "${python3.pkgs.wnet.src}")
      (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_WNETALIGN" "${python3.pkgs.wnetalign.src}")
    ];

    # Needed to export TOPP XML from the built executable files:
    QT_PLUGIN_PATH = "${qtbase}/lib/qt-6/plugins";
    QT_QPA_PLATFORM = "offscreen";

    buildInputs = [
      arrow-cpp
      boost
      bzip2
      coinmp
      curl
      eigen
      glpk
      graphviz
      kissfft
      libsvm
      libzip
      openmp
      opentims
      qtbase
      qtsvg
      xercesc
      xz
      yaml-cpp
      zlib
      zstd
    ]
    ++ lib.optional enablePython pythonAndPackages;

    patches = [
      ../../patches/openms-nuxl-tests.path
      ../../patches/openms-tims-zstd.patch
      ../../patches/pyopenms-codesign-qt.patch
    ];

    postPatch = ''
      # Get rid of unnecessary uses of `which`:
      find . -type f -name '*.rb' -exec \
        sed -i -E \
          -e 's/`which codesign/`echo echo/g' \
          -e 's/`which /`echo /g' '{}' ';'

      # Let Nix fix the RPATHs:
      (
        echo '#!${ruby}/bin/ruby'
        echo 'puts("Skip RPATH fixup")'
      ) >cmake/MacOSX/fix_dependencies.rb
    '';

    postBuild = lib.optionalString enablePython ''
      export CMAKE_PREFIX_PATH=$(pwd)

      python -m build ../src/pyOpenMS \
        --wheel --outdir=wheels \
        --skip-dependency-check --no-isolation
    '';

    # Install the Python module files as well, that way Nix can fix
    # the library paths and we don't have to mess with wheel files.
    postInstall = lib.optionalString enablePython ''
      # Remove the wrong pyopenms directory:
      rm -rf "$out/pyopenms"

      python -m pip install \
        --prefix="$out" \
        --no-index \
        --no-warn-script-location \
        --no-build-isolation \
        --no-cache \
        --no-deps \
        wheels/*.whl
    '';

    # CMake tries to make a portable Python package so we have to undo
    # that by updating library paths so they point into the Nix store.
    preFixup = lib.optionalString enablePython ''
      ${lib.optionalString stdenv.hostPlatform.isDarwin ''
        while IFS= read -r -d "" file; do
          echo "Updating @rpath entries in $file"

          for lib in "libOpenMS.dylib" "libOpenSwathAlgo.dylib"; do
            install_name_tool -change "@rpath/$lib" "$out/lib/$lib" "$file"
          done
        done < <(find "$out/${python3.pkgs.python.sitePackages}" \
          -type f '(' -name '*.so' -o -name '*.dylib' ')' -print0)
      ''}
    '';

    passthru = {
      # A docker container that only includes OpenMS:
      dockerimg = import ./dockerimg.nix {
        inherit dockerTools;
        openms = package;
      };
    };

    meta = {
      description = "Open-source software for LC-MS data management and analyses";
      longDescription = ''
        OpenMS is an open-source software C++ library for LC-MS data
        management and analyses. It offers an infrastructure for rapid
        development of mass spectrometry related software. OpenMS is
        free software available under the three clause BSD license and
        runs under Windows, macOS, and Linux.
      '';
      homepage = "https://openms.de/";
      license = lib.licenses.bsd3;
      maintainers = with lib.maintainers; [ pjones ];
      platforms = lib.platforms.all;
    };
  };
in
package
