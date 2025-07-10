{ lib
, fetchFromGitHub
, dotnetCorePackages
, buildDotnetModule
}:

buildDotnetModule rec {
  pname = "FlashLFQ";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "smith-chem-wisc";
    repo = "FlashLFQ";
    rev = "refs/tags/${version}";
    hash = "sha256-g0bXWVKnhZvuhW3RAhAYAeecyhGrfB0+6FD16200akI=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  executables = [ "CMD" ];
  projectFile = [ "CMD/CMD.csproj" ];
  nugetDeps = ./deps.json;

  # Rename the main program so it recognizable:
  postFixup = ''
    mv $out/bin/CMD $out/bin/FlashLFQ
  '';

  meta = {
    description = "Quantification algorithm for proteomics";
    longDescription = ''
      FlashLFQ is an ultrafast label-free quantification algorithm
      for mass-spectrometry proteomics.
    '';
    mainProgram = "FlashLFQ";
    homepage = "https://github.com/smith-chem-wisc/FlashLFQ";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
}
