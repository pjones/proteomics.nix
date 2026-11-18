# proteomics.nix

<p align="center">
  <a href="https://github.com/pjones/proteomics.nix/actions/workflows/test.yml">
    <img alt="CI" src="https://img.shields.io/github/actions/workflow/status/pjones/proteomics.nix/test.yml?&style=for-the-badge">
  </a>

  <a href="https://github.com/pjones/proteomics.nix/blob/trunk/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/pjones/proteomics.nix?style=for-the-badge&color=blue">
  </a>

  <a href="https://github.com/pjones/proteomics.nix/releases">
    <img alt="Release" src="https://img.shields.io/github/v/release/pjones/proteomics.nix?style=for-the-badge">
  </a>
</p>

A [Nix Flake](https://nixos.org/) (and Podman container) for easy access to proteomics data analysis tools such as [OpenMS](https://openms.de/).

# Using the Podman Container

**NOTE:** If you are using Docker instead of Podman simply replace the word `podman` with `docker` in the following instructions.

1. Pull the container from GitHub:
    
   ```sh
   podman pull ghcr.io/pjones/proteomics.nix:latest
   ```

2. Run one of the tools in the container:
    
   For example, execute the `ProteomicsLFQ` tool from the OpenMS project and request option help (via the `-h` option).
    
   ```sh
   podman run --rm -it -v "$(pwd):/mnt" -w /mnt proteomics.nix ProteomicsLFQ -h
   ```

# Installing Packages via Nix

1. [Install Nix](https://nixos.org/download/#download-nix)

2. Enable the binary cache (optional)
    
   This will reduce the number of packages you have to build from source. Ideally you&rsquo;ll be able to get everything from the cache.
    
   ```sh
   nix \
     --extra-experimental-features nix-command \
     --extra-experimental-features flakes \
     run nixpkgs#cachix use proteomics
   ```

3. Install the desired package:
    
   **NOTE:** Replace `PACKAGE` with the name of the desired package. See below for a list of available packages.
    
   ```sh
   nix \
     --extra-experimental-features nix-command \
     --extra-experimental-features flakes \
     profile install github:pjones/proteomics.nix#PACKAGE
   ```

# Available Packages

- [Comet](https://uwpr.github.io/Comet/) (`comet`)

  **NOTE:** available as `comet.exe`.

- [DIA-NN](https://github.com/vdemichev/DiaNN) (`diann-academia`)

- [diaTracer](https://diatracer.nesvilab.org/)[^1] (`diatracer`)

- [FlashLFQ](https://github.com/smith-chem-wisc/FlashLFQ) (`flashlfq`)

- [MaxQuant](https://maxquant.org/)[^1] (`maxquant`) 

  **NOTE:** available as `MaxQuantCmd`.

- [MetaMorpheus](https://github.com/smith-chem-wisc/MetaMorpheus) (`metamorpheus`)

- [MSFragger](https://msfragger.nesvilab.org/)[^1] (`msfragger`)

- [OpenMS](https://openms.de/) (`openms`)

- [Percolator](http://percolator.ms/) (`percolator`)

- [ProteoWizard](https://www.proteowizard.org/index.html)[^1] (`proteowizard`)

  **NOTE:** Only `msconvert` is currently made available.

- [MS-GF+](https://github.com/MSGFPlus/msgfplus) (`msgfplus`)

- [Sage](https://sage.lazear.org/) (`sage`)

- [RawFileReader](https://github.com/thermofisherlsms/RawFileReader) (`rawfilereader`)

- [ThermoRawFileParser](https://github.com/compomics/ThermoRawFileParser) (`thermorawfp`)

## Footnotes

[^1]: This is a non-free proprietary software package. To use it you must manually download the software from the vendor. Attempting to install the Nix package will provide the necessary instructions.
