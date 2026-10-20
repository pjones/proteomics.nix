{
  cmake,
  dotnet-sdk,
  fetchFromGitHub,
  lib,
  rawfilereader,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openms-thermo-bridge";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "OpenMS";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-oDbEIklPE5sQKzT8a2clSLDFqnafu000W3nDSgLZqPQ=";
  };

  nativeBuildInputs = [
    cmake
    dotnet-sdk
  ];

  cmakeFlags = [
    (lib.cmakeFeature "OPENMS_THERMO_BRIDGE_VENDOR_DIR" "${rawfilereader}/share/nuget/published")
    (lib.cmakeBool "OPENMS_THERMO_BRIDGE_DOWNLOAD_TEST_DATA" false)
    (lib.cmakeBool "OPENMS_THERMO_BRIDGE_DOWNLOAD_PREBUILT_MANAGED" false)
  ];
})
