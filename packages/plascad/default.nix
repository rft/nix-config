{
  lib,
  inputs,
  namespace,
  pkgs,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  fontconfig,
  freetype,
  libGL,
  libxkbcommon,
  wayland,
  xorg,
  vulkan-loader,
  makeWrapper,
  ...
}:

rustPlatform.buildRustPackage rec {
  pname = "plascad";
  version = "0.7.7";

  src = fetchFromGitHub {
    owner = "David-OConnor";
    repo = "plascad";
    rev = "${version}";
    hash = "sha256-BqIpH6O0bULr90YjNRwF5Javb8c2vFkSljlFlUfubWE=";
  };

  cargoHash = "sha256-hR8iFGjElo7Wl0BTGmVDzthRb9z9t8jl3jIjAZk/xIs=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    fontconfig
    freetype
    libGL
    libxkbcommon
    wayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    vulkan-loader
  ];

  postInstall = ''
    wrapProgram $out/bin/plascad \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL libxkbcommon wayland xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr vulkan-loader ]}"
  '';

  meta = with lib; {
    description = "Design software for plasmid (vector) and primer creation and validation. Edit plasmids, perform PCR-based cloning, digest and ligate DNA fragments, and display details about expressed proteins. Integrates with online resources like NCBI and PDB.";
    homepage = "https://github.com/David-OConnor/plascad";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
