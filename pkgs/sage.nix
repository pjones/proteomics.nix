{
  lib,
  fetchFromGitHub,
  rustPlatform,

}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sage";
  version = "0.15.0-beta.2";

  src = fetchFromGitHub {
    owner = "lazear";
    repo = "sage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-StYPljz4emB5UuwICHyUhFNCjN3AWXaCXwu1/dHN5nA=";
  };

  cargoHash = "sha256-RU5iPBUO/FszKI4TLvMJz4oeNPDubj2MHCjNtPK14ok=";

  meta = {
    description = "Proteomics search & quantification";
    longDescription = ''
      Sage is, at it's core, a proteomics database search engine - a
      tool that transforms raw mass spectra from proteomics
      experiments into peptide identifications via database searching
      & spectral matching.
    '';
    homepage = "https://sage.lazear.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
})
