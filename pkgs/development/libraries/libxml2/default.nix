{ stdenv
, lib
, fetchurl
, git
, zlib
, pkg-config
, autoreconfHook
, libintl
, python3
, meson
, ninja
, gettext
, ncurses
, findXMLCatalogs
, libiconv
# Python limits cross-compilation to an allowlist of host OSes.
# https://github.com/python/cpython/blob/dfad678d7024ab86d265d84ed45999e031a03691/configure.ac#L534-L562
, pythonSupport ? enableShared &&
    (stdenv.hostPlatform == stdenv.buildPlatform || stdenv.hostPlatform.isCygwin || stdenv.hostPlatform.isLinux || stdenv.hostPlatform.isWasi)
, icuSupport ? false
, icu
, enableShared ? !stdenv.hostPlatform.isMinGW && !stdenv.hostPlatform.isStatic
, gnome
, testers
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "libxml2";
  version = "2.13.3";

  outputs = [ "bin" "dev" "out" "doc" "man" ]
    ++ lib.optional pythonSupport "py";
  outputMan = "bin";

  src = fetchurl {
    url = "mirror://gnome/sources/libxml2/${lib.versions.majorMinor version}/libxml2-${version}.tar.xz";
    hash = "sha256-CAXXwYDPCcqtcWZsekWKdPBBVhpTKQJFTaUEfYOUgTg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    git
    meson
    ninja
    pkg-config
  ]
  ++ lib.optionals pythonSupport [ python3 ];

  buildInputs = [
    gettext
    ncurses
    libintl
  ];

  propagatedBuildInputs = [
    zlib
    findXMLCatalogs
  ] ++ lib.optionals stdenv.isDarwin [
    libiconv
  ] ++ lib.optionals icuSupport [
    icu
  ];

  enableParallelBuilding = true;

  mesonFlags = [
    "--python.platlibdir=${placeholder "py"}/${python3.sitePackages}"
    "--python.purelibdir=${placeholder "py"}/${python3.sitePackages}"
    "--mandir=${placeholder "man"}"
    (lib.mesonEnable "icu" icuSupport)
    (lib.mesonEnable "lzma" false)
    (lib.mesonBool "python" pythonSupport)
  ];

  doCheck =
    (stdenv.hostPlatform == stdenv.buildPlatform) &&
    stdenv.hostPlatform.libc != "musl";

  preConfigure = lib.optionalString (lib.versionAtLeast stdenv.hostPlatform.darwinMinVersion "11") ''
    MACOSX_DEPLOYMENT_TARGET=10.16
  '';

  passthru = {
    inherit version;
    pythonSupport = pythonSupport;

    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "none";
    };
    tests = {
      pkg-config = testers.hasPkgConfigModules {
        package = finalAttrs.finalPackage;
      };
    };
  };

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/GNOME/libxml2";
    description = "XML parsing library for C";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ eelco jtojnar ];
    pkgConfigModules = [ "libxml-2.0" ];
  };
})
