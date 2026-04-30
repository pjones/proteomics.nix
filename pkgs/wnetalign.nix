{
  lib,
  fetchFromGitHub,
  python,
  cmake,
  ninja,
}:

python.pkgs.buildPythonPackage rec {
  pname = "wnetalign";
  version = "0.9.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "michalsta";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-/4RR6dQQcO9aNQH6BeIE20QH5GLIhQXsJlFZ3VfX0Es=";
  };

  build-system = [
    cmake
    ninja
  ]
  ++ (with python.pkgs; [
    nanobind
    pylmcf
    scikit-build-core
    wnet
  ]);

  dontUseCmakeConfigure = true;

  cmakeFlags = [
    (lib.cmakeFeature "nanobind_DIR" "${python.pkgs.nanobind}/${python.sitePackages}/nanobind/cmake")
  ];

  meta = {
    description = "Spectral alignment using based on Truncated Wasserstein Metric";
    homepage = "https://github.com/michalsta/wnetalign";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
}
