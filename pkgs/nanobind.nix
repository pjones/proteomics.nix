{
  fetchPypi,
  python3Packages,
}:

let
  version = "3.1.0";
  hash = "sha256-ZmHj3BQ014eBzPeRNELZA2Has5XDQk7622O7tt3qfqM=";
in
python3Packages.nanobind.overrideAttrs (prevAttrs: {
  inherit version;

  src = fetchPypi {
    inherit (prevAttrs) pname;
    inherit version hash;
  };
})
