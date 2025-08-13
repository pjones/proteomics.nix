{ lib
, python3Packages
, fetchPypi
}:

let
  version = "0.22.11";
  hash = "sha256-tGy+HysmV2mDzYWQaBpJ626M5vKCp69q/s5RsjruYrc=";
in
python3Packages.buildPythonPackage rec {
  inherit version;
  pname = "autowrap";
  format = "pyproject";
  src = fetchPypi { inherit pname version hash; };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    cython
  ];

  meta = {
    description = "Generates Python Extension modules from Cythons PXD files";
    mainProgram = "autowrap";
    homepage = "https://github.com/OpenMS/autowrap/tree/master";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
}
