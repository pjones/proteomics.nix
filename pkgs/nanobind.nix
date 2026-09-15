{
  lib,
  python3Packages,
  fetchPypi,
}:

let
  version = "3.0.1";
  hash = "sha256-9/Coicj7gN6qy5XpGNiOBRSIUKMtK47aKERikbK/fDU=";
in
python3Packages.nanobind.overrideAttrs (prevAttrs: {
  inherit version;

  src = fetchPypi {
    inherit (prevAttrs) pname;
    inherit version hash;
  };
})
