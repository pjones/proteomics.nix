{ stdenv
, lib
, fetchFromGitHub
, expat
, zlib
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
  version = "2025.02.0";

  src = fetchFromGitHub {
    owner = "UWPR";
    repo = "Comet";
    rev = "refs/tags/v${version}";
    hash = "sha256-Opx+jHzciKUZsuApPsl67rieVjVGysjt0B+msZkZ+I8=";
  };

  postPatch = ''
    # Don't force static pthreads and other libs:
    sed -i -e 's/ -static / /' Makefile

    # Don't use the files in extern:
    sed -i -E \
      -e 's|EXPAT_DST\s+:=.*|EXPAT_DST = /dev/null|' \
      -e 's|EXPAT_SRC\s+:=.*|EXPAT_SRC = ${expatStatic.dev}|' \
      -e 's|ZLIB_DST\s+:=.*|ZLIB_DST = /dev/null|' \
      MSToolkit/Makefile
  '';

  # Use existing versions of nixpkgs libraries:
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
