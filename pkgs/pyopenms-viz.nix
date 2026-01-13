{
  lib,
  python3Packages,
  fetchPypi,
}:

let
  version = "1.0.0";
  hash = "sha256-Q8Q8NPcb7wOTK0mCSLa+c1vzBUR69TatS+tj1imQrZc=";
in
python3Packages.buildPythonPackage rec {
  inherit version;
  pname = "pyopenms_viz";
  format = "pyproject";
  src = fetchPypi { inherit pname version hash; };

  build-system = with python3Packages; [
    flit-core
    setuptools
  ];

  dependencies = with python3Packages; [
    pandas
  ];

  meta = {
    description = "The Python Pandas-Based Mass Spectrometry Visualization Library";
    homepage = "https://pypi.org/project/pyopenms-viz/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
}
