{
  stdenv,
  lib,
  fetchFromGitHub,
  expat,
  zlib,
}:

let
  expatStatic = expat.overrideAttrs (orig: {
    configureFlags = orig.configureFlags ++ [
      "--enable-static"
    ];
  });
in
stdenv.mkDerivation rec {
  pname = "comet";
  version = "2026.03.0";

  src = fetchFromGitHub {
    owner = "UWPR";
    repo = "Comet";
    rev = "refs/tags/v${version}";
    hash = "sha256-OZMHTWPvOr/OH8wkjDGTW8m6pwG1oYGc7wk4FVIiVPk=";
  };

  patches = [
    # Don't build expat or zlib, use the ones in nixpkgs:
    ../patches/comet-makefiles.patch
  ];

  postPatch = ''
    # Don't force static pthreads and other libs:
    sed -i -e 's/ -static / /' Makefile
  '';

  # Use existing versions of nixpkgs libraries:
  #
  # NOTE: See note above in in `patches`.
  preBuild = ''
    pushd MSToolkit
    mkdir -p obj
    rm -rf extern
    ln -nfs ${expatStatic}/lib/libexpat.a obj/
    ln -nfs ${expatStatic.dev}/include/expat_config.h include/extern/
    ln -nfs ${expatStatic.dev}/include/*.h include/
    ln -nfs ${zlib.static}/lib/libz.a obj/
    ln -nfs ${zlib.dev}/include/*.h include/
    popd
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m0755 comet.exe $out/bin

    runHook postInstall
  '';

  meta = {
    description = "Tandem mass spectrometry (MS/MS) sequence database search tool.";
    longDescription = ''
      Comet is an open source tandem mass spectrometry (MS/MS)
      sequence database search tool released under the Apache 2.0
      license.
    '';
    mainProgram = "comet.exe";
    homepage = "https://uwpr.github.io/Comet/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.all;
  };
}
