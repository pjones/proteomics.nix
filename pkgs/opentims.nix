{
  lib,
  stdenv,
  fetchFromGitHub,

  # Dependencies:
  cmake,
  python3,
  sqlite,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opentims";
  version = "33b72834b7b8bee5e8a91b4dd669c94a8c14aa41";

  src = fetchFromGitHub {
    owner = "michalsta";
    repo = "opentims";
    rev = finalAttrs.version;
    hash = "sha256-o5jLwFGdxu3brO3ez/g3ucWRRmAnDRikn52/aY88o2M=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    (python3.withPackages (
      py-pkgs: with py-pkgs; [
        pybind11
      ]
    ))

    sqlite
    zstd
  ];

  cmakeFlags = [
    # We want the C++ lib!
    (lib.cmakeBool "OPENTIMS_BUILD_CPP_LIB" true)

    # Doesn't hurt to have the Python module too.
    (lib.cmakeBool "OPENTIMS_BUILD_PYTHON" true)

    # Don't try to load libraries at runtime!
    (lib.cmakeBool "OPENTIMS_LINK_SQLITE_STATICALLY" true)
  ];
})
