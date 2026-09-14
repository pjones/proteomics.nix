{
  stdenv,
  lib,
  requireFile,
  makeWrapper,
  unzip,
  jre,
  msfragger,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "diatracer";
  version = "2.2.1";
  passthru.manual = true;

  src = requireFile rec {
    name = "diatracer-${finalAttrs.version}.zip";
    sha256 = "12hb2zss18gpr9n92563bx8l8f54kldmbvldxkr8y7adcxw6x9hv";

    message = ''
      In order to use diaTracer you must manually download the application from:

      https://msfragger-upgrader.nesvilab.org/diatracer/

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

    mkdir -p "$out/bin" "$out/share/diatracer"
    install --mode=0644 diaTracer-${finalAttrs.version}.jar "$out/share/diatracer/"
    install --mode=0644 LICENSE-ACADEMIC.pdf "$out/share/diatracer/"
    ln -s ${msfragger}/share/msfragger/ext "$out/share/diatracer/ext"

    makeWrapper \
      ${jre}/bin/java \
      $out/bin/diaTracer \
      --add-flags "-jar $out/share/diatracer/diaTracer-${finalAttrs.version}.jar"

    runHook postInstall
  '';

  meta = {
    description = "A diaPASEF spectrum-centric analysis tool";
    homepage = "https://diatracer.nesvilab.org/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.platforms.all;
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ pjones ];
  };
})
