{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "psims";
  version = "1.4.0";
  pyproject = true;

  src = fetchPypi {
    pname = finalAttrs.pname;
    version = finalAttrs.version;
    hash = "sha256-rHcwxQeGTrFBh3pwDdeeX8evx9owmYd4uRxQ4Pn16Oc=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    lxml
    six
    sqlalchemy
    numpy
  ];

  meta = {
    description = "Writers and controlled vocabulary manager for PSI-MS's mzML and mzIdentML standards";
    homepage = "https://github.com/mobiusklein/psims";
    license = lib.licenses.apl20;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
})
