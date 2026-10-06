{
  fetchurl,
  jre,
  lib,
  makeWrapper,
  stdenv,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "msgfplus";
  version = "2024.03.26";

  src = fetchurl {
    url = "https://github.com/MSGFPlus/msgfplus/releases/download/v2024.03.26/MSGFPlus_v20240326.zip";
    hash = "sha256-AbrLTnQHf4TCBvb5HrpnopQz0H1kn0OLATp3IXsL+qw=";
  };

  sourceRoot = ".";
  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/msgfplus
    cp -ar Docs $out/share/docs
    cp -a MSGFPlus* MzidToTsvConverter *.md *.txt $out/share/msgfplus

    makeWrapper \
      ${jre}/bin/java \
      $out/bin/msgfplus \
      --add-flags "-jar $out/share/msgfplus/MSGFPlus.jar"

    runHook postInstall
  '';

  meta = {
    description = "Peptide identification by scoring MS/MS spectra";
    longDescription = ''
      MS-GF+ (aka MSGF+ or MSGFPlus) performs peptide identification
      by scoring MS/MS spectra against peptides derived from a protein
      sequence database.
    '';
    mainProgram = "msgfplus";
    homepage = "https://github.com/MSGFPlus/msgfplus";
    license = "non-profit";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
})
