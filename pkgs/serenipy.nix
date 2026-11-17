{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "serenipy";
  version = "0.4.0";
  pyproject = true;

  src = fetchPypi {
    pname = finalAttrs.pname;
    version = finalAttrs.version;
    hash = "sha256-alov9NMa3euTf47QM3upP9C15PCq94wz2e9ldKMCbGQ=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pandas
  ];

  meta = {
    description = "Python library for parsing IP2 proteomics file formats (MS2, SQT, DTASelect-filter, Census)";
    homepage = "https://github.com/pgarrett-scripps/serenipy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
})
