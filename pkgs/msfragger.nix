{
  stdenv,
  lib,
  requireFile,
  makeWrapper,
  unzip,
  jre,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "msfragger";
  version = "4.4.1";
  passthru.manual = true;

  src = requireFile rec {
    name = "MSFragger-4.4.1.zip";
    sha256 = "0jk46xjzfvr8r8rwg3qf5hldqhn15qmg9df441x32a8gq4j809nm";

    message = ''
      In order to use MSFragger you must manually download the application from:

      https://msfragger-upgrader.nesvilab.org/upgrader/

      And then add the file to the Nix store:

      nix-prefetch-url file://\$PWD/${name}
    '';
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share/msfragger"
    install --mode=0644 MSFragger-${finalAttrs.version}.jar "$out/share/msfragger/"
    install --mode=0644 LICENSE-ACADEMIC.pdf "$out/share/msfragger/"
    cp -ra ext "$out/share/msfragger/"

    makeWrapper \
      ${jre}/bin/java \
      $out/bin/MSFragger \
      --add-flags "-jar $out/share/msfragger/MSFragger-${finalAttrs.version}.jar"

    runHook postInstall
  '';

  meta = {
    description = "Peptide identification for mass spectrometry–based proteomics";
    homepage = "https://msfragger.nesvilab.org/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.platforms.all;
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ pjones ];
  };
})
