{
  lib,
  fetchFromGitHub,
  python,
  cmake,
  ninja,
}:

python.pkgs.buildPythonPackage rec {
  pname = "pylmcf";
  version = "0.9.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "michalsta";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-bqrf3Dpl/6pRpUdEKwAMyEOCryFaP2Eoms7Zq9AsdY0=";
  };

  build-system = [
    cmake
    ninja
  ]
  ++ (with python.pkgs; [
    nanobind
    scikit-build-core
  ]);

  dependencies = [
    python.pkgs.numpy
  ];

  dontUseCmakeConfigure = true;

  cmakeFlags = [
    (lib.cmakeFeature "nanobind_DIR" "${python.pkgs.nanobind}/${python.sitePackages}/nanobind/cmake")
  ];

  meta = {
    description = "Python bindings for Min Cost Flow algorithm from LEMON graph library";
    homepage = "https://github.com/michalsta/pylmcf";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
}
