{
buildGoModule,
bzip2,
cbconvert,
fetchFromGitHub,
gtk3,
imagemagick,
lib,
libunarr,
mupdf-headless,
nix-update-script,
pkg-config,
stdenv,
testers,
zlib
}:

buildGoModule rec {
  pname = "cbconvert";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "gen2brain";
    repo = "cbconvert";
    rev = "v${version}";
    hash = "sha256-uJJtuhja6h0o+CE8AjRQkSYgyK00s1sg2mYVQ9hEHzg=";
  };

  vendorHash = "sha256-XUPKADNkB+qBlbArMIJJRt+DeFix8BpLhrVgfEHYVRI=";

  proxyVendor = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    # bzip2
    gtk3
    imagemagick
    # libunarr
    mupdf-headless
    # zlib
  ];

  # CGO_ENABLED = 0;

  # ldflags = [
  #   "-s"
  #   "-w"
  #   "-X github.com/crossplane/crossplane/internal/version.version=v${version}"
  # ];

  # subPackages = [ "cmd/cbconvert" "cmd/cbconvert-gui" ];

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion {
      package = cbconvert;
    };
  };

  meta = with lib; {
    description = "A Comic Book converter";
    homepage = "https://github.com/gen2brain/cbconvert";
    changelog = "https://github.com/gen2brain/cbconvert/releases/tag/v${version}";
    license = with licenses; [ gpl3Only ];
    platforms = with platforms; linux ++ darwin ++ windows;
    broken = !stdenv.hostPlatform.isLinux;
    maintainers = with maintainers; [ jwillikers ];
    mainProgram = "cbconvert";
  };
}
