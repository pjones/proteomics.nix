{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unzip,
  yq,
}:

stdenvNoCC.mkDerivation {
  pname = "RawFileReader";
  version = "8.3.7";

  src = fetchFromGitHub {
    owner = "thermofisherlsms";
    repo = "RawFileReader";
    rev = "80963674b5c10e58236da63023ad6fa0264bbb00";
    hash = "sha256-blaq75pR+Z4uabY+2WPVI5dKrG8KfChfe25v8klXtU8=";
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

    base="$out/share/nuget"
    dest="$base/packages"
    published="$base/published"

    mkdir -p "$dest" "$published"
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
      cp "$file" "$published/$(basename "$file" | tr '[A-Z]' '[a-z]')"
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
