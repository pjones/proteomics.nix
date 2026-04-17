{
  pythonPackages,
  openms,
}:

pythonPackages.buildPythonPackage {
  pname = "pyopenms";
  version = openms.version;
  format = "other";

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/${pythonPackages.python.sitePackages}/"

    ln -s "${openms}/${pythonPackages.python.sitePackages}/pyopenms" \
      "$out/${pythonPackages.python.sitePackages}/"

    runHook postInstall
  '';

  dependencies = with pythonPackages; [
    matplotlib
    numpy
    pandas
  ];

  pythonImportsCheck = [ "pyopenms" ];
}
