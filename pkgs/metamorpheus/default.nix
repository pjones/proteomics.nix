{ lib
, fetchFromGitHub
, dotnetCorePackages
, buildDotnetModule
}:

buildDotnetModule rec {
  pname = "MetaMorpheus";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "smith-chem-wisc";
    repo = "MetaMorpheus";
    rev = "refs/tags/${version}";
    hash = "sha256-o7wY2tSrg5IHRcgCfnJ6QrYh4+lRtFlSN51wy+UytJI=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  selfContainedBuild = true; # Required :(

  executables = [ "CMD" ];
  projectFile = [ "MetaMorpheus/CMD/CMD.csproj" ];
  nugetDeps = ./deps.json;

  # Rename the main program so it recognizable:
  postFixup = ''
    mv $out/bin/CMD $out/bin/MetaMorpheus
  '';

  meta = {
    description = "Free, Open-Source PTM Discovery";
    longDescription = ''
      Proteomics search software with integrated calibration, PTM
      discovery, bottom-up, top-down and LFQ capabilities
    '';
    mainProgram = "MetaMorpheus";
    homepage = "https://github.com/smith-chem-wisc/MetaMorpheus";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
}
