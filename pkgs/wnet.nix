{
  lib,
  fetchFromGitHub,
  python,
  cmake,
  ninja,
}:

python.pkgs.buildPythonPackage rec {
  pname = "wnet";
  version = "0.9.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "michalsta";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-VjvlYx+q6fbibos8TaUPfaVeg/KUbcXshML80EsIx98=";
  };

  build-system = [
    cmake
    ninja
  ]
  ++ (with python.pkgs; [
    nanobind
    pylmcf
    scikit-build-core
  ]);

  dontUseCmakeConfigure = true;

  cmakeFlags = [
    (lib.cmakeFeature "nanobind_DIR" "${python.pkgs.nanobind}/${python.sitePackages}/nanobind/cmake")
  ];

  meta = {
    description = "Python module for calculating Wasserstein distance between distributions using network flow algorithm";
    homepage = "https://github.com/michalsta/wnet";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
}
