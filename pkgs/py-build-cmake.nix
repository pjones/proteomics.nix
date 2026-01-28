{
  lib,
  python3Packages,
  fetchPypi,
}:

let
  version = "0.5.0";
  hash = "sha256-hfBMwooFGtr7gQDTblDxpvEi6lWfI3EG/cA27KpEljs=";
in
python3Packages.buildPythonPackage rec {
  inherit version;
  pname = "py_build_cmake";
  pyproject = true;
  src = fetchPypi { inherit pname version hash; };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    distlib
    click
    lark
    pyproject-metadata
  ];

  meta = {
    description = "Build backend for creating Python packages";
    longDescription = ''
      A modern, PEP 517 compliant build backend for creating Python
      packages with extensions built using CMake.
    '';
    homepage = "https://github.com/tttapa/py-build-cmake";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
}
