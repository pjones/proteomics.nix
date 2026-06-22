{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  dotnetCorePackages,
  rawfilereader,
}:

let
  dotnetPkg = (
    with dotnetCorePackages;
    combinePackages [
      dotnet_8.sdk
      dotnet_8.aspnetcore
    ]
  );
in

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
  ];

  buildInputs = [
    dotnetPkg
  ];

  env = {
    DOTNET_ROOT = "${dotnetPkg}/share/dotnet";
    DOTNET_HOST_PATH = "${dotnetPkg}/share/dotnet/dotnet";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE = "1";
  };

  cmakeFlags = [
    (lib.cmakeFeature "OPENMS_THERMO_BRIDGE_VENDOR_DIR" "${rawfilereader}/share/nuget/published")
    (lib.cmakeBool "OPENMS_THERMO_BRIDGE_ENABLE_VENDOR_DOWNLOAD" false)
    (lib.cmakeBool "DOPENMS_THERMO_BRIDGE_DOWNLOAD_TEST_DATA" false)
    (lib.cmakeBool "OPENMS_THERMO_BRIDGE_DOWNLOAD_PREBUILT_MANAGED" false)
  ];
})
