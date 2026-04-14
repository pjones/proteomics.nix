{
  lib,
  stdenv,
  fetchFromGitHub,

  # Dependencies:
  cmake,
  python3,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opentims";
  version = "v1.2.0b2";

  src = fetchFromGitHub {
    owner = "michalsta";
    repo = "opentims";
    rev = finalAttrs.version;
    hash = "sha256-RfwV0FA/9f4jiq7CfWEbeS890dpxsvlhd0lHvQYFFAM=";
  };

  cmakeBuildTargets = [
    "opentims_cpp"
    "opentims_py"
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
  ];

  cmakeFlags = [
    # We want the C++ lib!
    (lib.cmakeBool "OPENTIMS_BUILD_CPP_LIB" true)

    # Doesn't hurt to have the Python module too.
    (lib.cmakeBool "OPENTIMS_BUILD_PYTHON" true)

    # Don't try to load libraries at runtime!
    (lib.cmakeBool "OPENTIMS_LINK_SQLITE_STATICALLY" true)
  ];

  postInstall = ''
    mkdir "$out/lib" "$out/include"
    cp -a libopentims_cpp.a "$out/lib"
    mv "$out/opentimspy/opentims++" "$out/include/opentims++"
  '';
})
