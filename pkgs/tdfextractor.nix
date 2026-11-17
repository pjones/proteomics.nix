{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "tdfextractor";
  version = "0.4.2";
  pyproject = true;

  src = fetchPypi {
    pname = finalAttrs.pname;
    version = finalAttrs.version;
    hash = "sha256-VTmyOTfsv0zSOShv2f1cURD4SeWkbJTXtJbapF6PN9o=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    numba
    numpy
    pandas
    psims
    serenipy
    tdfpy
    tqdm
  ];

  meta = {
    description = "Extract MS2, MGF, and mzML files from Bruker timsTOF .d folders";
    homepage = "https://github.com/tacular-omics/tdfextractor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
})
