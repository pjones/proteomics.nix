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
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "jpfeuffer";
    repo = "openms-thermo-bridge";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uTj4BeSQSnG0pyWIERYW+IRgEnIBN30eCJpXbpsZaVM=";
  };

  nativeBuildInputs = [
    cmake
  ];

  postPatch = ''
    mkdir -p vendor/thermo-feed
    cp ${rawfilereader}/share/nuget/packages/*.nupkg vendor/thermo-feed
  '';

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
    (lib.cmakeBool "OPENMS_THERMO_BRIDGE_ENABLE_VENDOR_DOWNLOAD" false)
    (lib.cmakeBool "DOPENMS_THERMO_BRIDGE_DOWNLOAD_TEST_DATA" false)
  ];
})
