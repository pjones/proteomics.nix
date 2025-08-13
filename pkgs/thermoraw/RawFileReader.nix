{ lib
, stdenvNoCC
, fetchFromGitHub
, unzip
, yq
}:

stdenvNoCC.mkDerivation {
  pname = "RawFileReader";
  version = "git";

  src = fetchFromGitHub {
    owner = "thermofisherlsms";
    repo = "RawFileReader";
    rev = "f3c49e4e362b78c2674268082ce5862c0c245ed0";
    hash = "sha256-c3Z3mjPWNG62sDCWbFovdTz9syYTR7sR69WBj0wa5/U=";
  };

  dontBuild = true;

  nativeBuildInputs = [
    unzip
    yq
  ];

  # Mostly adapted from nixpkgs:
  # pkgs/build-support/dotnet/build-dotnet-module/hooks/dotnet-install-hook.sh
  installPhase = ''
    runHook preInstall

    unpacked="$PWD/.nuget-pack/unpacked"
    mkdir -p "$(dirname "$unpacked")"

    dest="$out/share/nuget/packages"
    mkdir -p "$dest"
    set -x

    while IFS= read -r -d "" file; do
      rm -rf "$unpacked"
      unzip -qd "$unpacked" "$file"
      chmod -R +rw "$unpacked"
      echo "{}" > "$unpacked"/.nupkg.metadata
      local id version
      id=$(xq -r '.package.metadata.id|ascii_downcase' "$unpacked"/*.nuspec)
      version=$(xq -r '.package.metadata.version|ascii_downcase' "$unpacked"/*.nuspec)
      mkdir -p "$dest/$id"
      mv "$unpacked" "$dest/$id/$version"
    done < <(find Libs/NetCore/Net8 -type f -name '*.nupkg' -print0)

    runHook postInstall
  '';

  meta = {
    description = "C# library to read Thermo Scientific RAW files";
    longDescription = ''
      RawFilelReader is a group of .Net Assemblies written in C# used
      to read Thermo Scientific RAW files. The assemblies can be used
      to read RAW files on Windows, Linux, and MacOS using C# or other
      languages that can acces a .Net assembly.
    '';
    homepage = "https://github.com/thermofisherlsms/RawFileReader";
    license = "proprietary";
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
}
