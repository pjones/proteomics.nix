{
  lib,
  rawfilereader,
  stdenv,
  fetchFromGitHub,
  cmake,
  dotnetCorePackages,
  buildDotnetModule,
}:

buildDotnetModule (finalAttrs: {
  pname = "openms-thermo-bridge";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "OpenMS";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-oDbEIklPE5sQKzT8a2clSLDFqnafu000W3nDSgLZqPQ=";
  };

  nugetDeps = ../thermoraw/ThermoRawFileParser-deps.json;
  projectReferences = [ rawfilereader ];
  projectFile = "../ThermoWrapperManaged.csproj";

  nativeBuildInputs = [
    stdenv.cc
    cmake
  ];

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  cmakeFlags = [
    (lib.cmakeFeature "OPENMS_THERMO_BRIDGE_VENDOR_DIR" "${rawfilereader}/share/nuget/published")
    (lib.cmakeBool "OPENMS_THERMO_BRIDGE_DOWNLOAD_TEST_DATA" false)
    (lib.cmakeBool "OPENMS_THERMO_BRIDGE_DOWNLOAD_PREBUILT_MANAGED" false)
  ];
})
