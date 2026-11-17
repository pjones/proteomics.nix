{
  stdenv,
  lib,
  requireFile,
  autoPatchelfHook,
  makeWrapper,
  libz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "proteowizard";
  version = "4.0.26320-3abef39";
  passthru.manual = true;

  src = requireFile rec {
    name = "ProteoWizard-linux-x64-${finalAttrs.version}.tar.gz";
    sha256 = "1hd8nkv7dfm96wld0fxy10wjg30min3qd508bwy6zqnqx376ndky";

    message = ''
      In order to use ProteoWizard you must manually download the application from:

      https://www.proteowizard.org/download.html

      And then add the file to the Nix store:

      nix-prefetch-url file://\$PWD/${name}
    '';
  };

  sourceRoot = ".";
  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libz
    stdenv.cc.cc.lib
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libhdf5.so.103"
    "liblttng-ust.so.0"
  ];

  dontAutoPatchelf = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/pwiz"
    cp -ar . "$out/share/pwiz"

    mkdir -p "$out/bin"

    makeWrapper \
      "$out/share/pwiz/msconvert" \
      "$out/bin/msconvert" \
      --set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 1

    runHook postInstall
  '';

  postFixup = ''
    autoPatchelf "$out/share/pwiz"
  '';

  meta = {
    description = "Proteomics analysis made simple";
    homepage = "https://www.proteowizard.org";
    mainProgram = "msconvert";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ pjones ];
  };
})
