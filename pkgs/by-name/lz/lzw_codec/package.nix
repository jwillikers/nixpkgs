{
  stdenv,
  lib,
  fetchFromGitHub,
  lzw_codec,
  unstableGitUpdater,
  testers,
}:
stdenv.mkDerivation {
  pname = "lzw_codec";
  version = "0-unstable-2018-03-07";

  src = fetchFromGitHub {
    owner = "pts";
    repo = "lzw_codec";
    rev = "54be8e96e64bf56525996b1c41b424b827728a00";
    hash = "sha256-gYu6gda13gpCv4/V8jEYSOI5OjR9psGBqUkpYE2JGLc=";
  };

  makeFlags = [ "lzw_codec" ];

  installPhase = ''
    runHook preInstall
    install -Dm0755 --target-directory=$out/bin lzw_codec
    runHook postInstall
  '';

  passthru = {
    tests.version = testers.testVersion {
      package = lzw_codec;
      version = "0.11";
    };
    updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "LZW compressor and decompressor in C";
    homepage = "https://github.com/pts/lzw_codec";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ jwillikers ];
    mainProgram = "lzw_codec";
  };
}
