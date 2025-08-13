{ lib
, fetchFromGitHub
, dotnetCorePackages
, buildDotnetModule
, zlib
, RawFileReader
}:

buildDotnetModule rec {
  pname = "ThermoRawFileParser";
  version = "1.4.5-dotnetcore";

  src = fetchFromGitHub {
    owner = "compomics";
    repo = "ThermoRawFileParser";
    rev = "6ee904c6d03d06b6812b41537f555e725cd384c9"; # dotnetcore branch
    hash = "sha256-ACHdTL/9eNwzx/wpblxCjVRLv0esTEo7iXiVmVFPbN0=";
  };

  nugetDeps = ./nuget-deps.nix;
  projectReferences = [ RawFileReader ];

  projectFile = "ThermoRawFileParser.csproj";
  executables = [ "ThermoRawFileParser" ];

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  # Damn thing loads libz at run time!
  runtimeDeps = [
    zlib
  ];

  # WTF?  The dynamic loader in .NET tries to load this library
  # without a file extension!
  postFixup = ''
    ln --relative --symbolic \
     "$out/lib/ThermoRawFileParser/libMonoPosixHelper.so" \
     "$out/lib/ThermoRawFileParser/libMonoPosixHelper"
  '';

  meta = {
    description = "Thermo RAW file parser";
    longDescription = ''
      Wrapper around the .net (C#) ThermoFisher ThermoRawFileReader
      library for running on Linux with mono (works on Windows
      too). It takes a thermo RAW file as input and outputs a metadata
      file and the spectra in 3 possible formats.
    '';
    homepage = "https://github.com/compomics/ThermoRawFileParser";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };

}
