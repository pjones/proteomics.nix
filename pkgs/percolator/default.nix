{ stdenv
, lib
, fetchFromGitHub
, cmake
, boost
, eigen
, gtest
}:

let
  # Convert a Percolator version number to release tag name:
  versionToTag = version:
    "rel-" + lib.concatStringsSep "-" (lib.splitString "." version);
in
stdenv.mkDerivation (final: {
  pname = "percolator";
  version = "3.08";

  src = fetchFromGitHub {
    owner = "percolator";
    repo = "percolator";
    rev = "refs/tags/${versionToTag final.version}";
    hash = "sha256-1J2OKNt4AK0de7i5gstrqY8Dn77QXyhjcgAXc9hUwl8=";
  };

  nativeBuildInputs = [
    boost
    cmake
    eigen
    gtest
  ];

  patches = [
    ./deps.patch
  ];

  postInstall = ''
    rm $out/bin/gtest_unit
  '';

  meta = {
    description = "Peptide identification from shotgun proteomics datasets";
    longDescription = ''
      Semi-supervised learning for peptide identification from shotgun
      proteomics datasets.
    '';
    mainProgram = "percolator";
    homepage = "http://percolator.ms/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
})
