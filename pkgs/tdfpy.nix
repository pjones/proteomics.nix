{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "tdfpy";
  version = "4.1.1";
  pyproject = true;

  src = fetchPypi {
    pname = finalAttrs.pname;
    version = finalAttrs.version;
    hash = "sha256-46xrQ/DpM7+dDoOPmHNOCdrAtx9ZK3cPvp1o/BAuSEo=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    numba
    numpy
    pandas
  ];

  meta = {
    description = "Python package for parsing Bruker timsTOF data with centroiding and noise filtering.";
    homepage = "https://github.com/tacular-omics/tdfpy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
})
