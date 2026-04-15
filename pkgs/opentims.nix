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
  version = "v1.2.0b3";

  src = fetchFromGitHub {
    owner = "michalsta";
    repo = "opentims";
    rev = finalAttrs.version;
    hash = "sha256-JmNIuQYa+Gd30HKy4QdKIPzb/t/PfLKl/1eDN2MKSpI=";
  };

  patches = [
    ../patches/opentims.patch
  ];

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
