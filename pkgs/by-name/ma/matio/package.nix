{
  fetchurl,
  hdf5,
  lib,
  matio,
  nix-update-script,
  pkgconf,
  stdenv,
  testers,
  validatePkgConfig,
}:
stdenv.mkDerivation rec {
  pname = "matio";
  version = "1.5.27";
  src = fetchurl {
    url = "mirror://sourceforge/matio/matio-${version}.tar.gz";
    sha256 = "sha256-CmqgCxjEUStjqNJ5BrB5yMbtQdSyhE96SuWY4Y0i07M=";
  };

  configureFlags = [ "ac_cv_va_copy=1" ];

  nativeBuildInputs = [
    pkgconf
    validatePkgConfig
  ];

  buildInputs = [ hdf5 ];

  passthru = {
    tests = {
      pkg-config = testers.hasPkgConfigModules {
        package = matio;
        versionCheck = true;
      };
      version = testers.testVersion {
        package = matio;
      };
    };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "C library for reading and writing Matlab MAT files";
    homepage = "http://matio.sourceforge.net/";
    license = with lib.licenses; [ bsd2 ];
    maintainers = with lib.maintainers; [ jwillikers ];
    mainProgram = "matdump";
    platforms = lib.platforms.all;
    pkgConfigModules = [ "matio" ];
  };
}
