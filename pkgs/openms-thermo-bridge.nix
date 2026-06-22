{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  dotnetCorePackages,
  rawfilereader,
}:

let
  nugetDeps = map dotnetCorePackages.fetchNupkg (
    lib.importJSON ./thermoraw/ThermoRawFileParser-deps.json
  );
in

stdenv.mkDerivation (finalAttrs: {
  pname = "openms-thermo-bridge";
  version = "1.0.0-p1";

  src = fetchFromGitHub {
    owner = "OpenMS";
    repo = finalAttrs.pname;
    #rev = "v${finalAttrs.version}";
    rev = "20fa60d92c9398d0c6a570b3d02286bed9ff63dc";
    hash = "sha256-Eqsuh3zUlLFPiEbnrGjDluDIL6ak7OMIjDgBLmH68Po=";
  };

  nativeBuildInputs = [
    dotnetCorePackages.dotnet_8.sdk
    cmake
  ];

  buildInputs = nugetDeps;

  cmakeFlags = [
    (lib.cmakeFeature "OPENMS_THERMO_BRIDGE_VENDOR_DIR" "${rawfilereader}/share/nuget/published")
    (lib.cmakeBool "OPENMS_THERMO_BRIDGE_ENABLE_VENDOR_DOWNLOAD" false)
    (lib.cmakeBool "OPENMS_THERMO_BRIDGE_DOWNLOAD_PREBUILT_MANAGED" false)
    (lib.cmakeBool "OPENMS_THERMO_BRIDGE_NUGET_OFFLINE" true)
  ];
})
