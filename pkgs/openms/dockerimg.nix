{ dockerTools
, openms
}:

dockerTools.buildLayeredImage {
  name = "openms";
  contents = [ openms ];
}
