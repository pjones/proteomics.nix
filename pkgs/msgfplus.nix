{ lib
, fetchFromGitHub
, jre
, maven
, makeWrapper
}:

maven.buildMavenPackage rec {
  pname = "msgfplus";
  version = "2024.03.26";

  src = fetchFromGitHub {
    owner = "MSGFPlus";
    repo = "msgfplus";
    rev = "refs/tags/v${version}";
    hash = "sha256-Gxr2RmLw91/GKXoY2rLimxHngCS2v590NErRIidwAP8=";
  };

  mvnHash = "sha256-QG7sYtC+G4DrZ2KGfFC3iqMddJe6yoXkM3wwrSiqKXA=";

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/msgfplus
    install -m 0644 target/MSGFPlus.jar $out/share/msgfplus

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
    mainProgram = "none";
    homepage = "https://github.com/MSGFPlus/msgfplus";
    license = "non-profit";
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
}
