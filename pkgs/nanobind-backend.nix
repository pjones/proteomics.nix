{
  lib,
  python3Packages,
  fetchFromGitHub,
  cmake,
  ninja,
  robin-map,
}:

let
  version = "1.0.0";
  hash = "sha256-1Uym1aiQPKWl6kmZvVhKPNKTlpJ2lwDgwhy1idTzuc0=";
in
python3Packages.buildPythonPackage rec {
  inherit version;
  pname = "nanobind_backend";
  pyproject = true;

  src = fetchFromGitHub {
    inherit hash;
    owner = "wjakob";
    repo = "nanobind";
    rev = "v${python3Packages.nanobind.version}";
  };

  sourceRoot = "${src.name}/nanobind-backend";
  dontUseCmakeConfigure = true;

  build-system = [
    cmake
    ninja
  ]
  ++ (with python3Packages; [
    #nanobind
    pylmcf
    scikit-build-core
  ]);

  dependencies = [
    robin-map
  ];

  meta = {
    description = "Compiled nanobind backend for extensions built in split mode";
    homepage = "https://github.com/wjakob/nanobind";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
}
