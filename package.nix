{
  lib,
  stdenv,
  fetchurl,
  binutils-unwrapped,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemd,
  libx11,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxtst,
  libxcb,
}:

let
  source = import ./source.nix;
in
stdenv.mkDerivation rec {
  pname = "openanime";
  inherit (source) version hash;

  src = fetchurl {
    url = "https://github.com/OpenAnime/desktop-ts/releases/download/v${version}/openanime_${version}_amd64.deb";
    inherit hash;
  };

  nativeBuildInputs = [
    binutils-unwrapped
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libnotify
    libxkbcommon
    nspr
    nss
    pango
    systemd
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxcb
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    runHook preUnpack
    mkdir -p source
    ar p "$src" data.tar.xz | tar -xJ -C source --no-same-owner --no-same-permissions 2>/dev/null || \
    ar p "$src" data.tar.gz | tar -xz -C source --no-same-owner --no-same-permissions 2>/dev/null || \
    ar p "$src" data.tar.zst | tar --zstd -xf - -C source --no-same-owner --no-same-permissions
    cd source
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/openanime $out/bin $out/share/applications $out/share/pixmaps

    cp -r usr/lib/openanime/* $out/lib/openanime/

    if [ -f usr/share/pixmaps/openanime.png ]; then
      cp usr/share/pixmaps/openanime.png $out/share/pixmaps/
    fi

    if [ -f usr/share/applications/openanime.desktop ]; then
      cp usr/share/applications/openanime.desktop $out/share/applications/
    fi

    # The executable can be either openanime or Openanime
    EXECUTABLE="$out/lib/openanime/openanime"
    if [ ! -f "$EXECUTABLE" ] && [ -f "$out/lib/openanime/Openanime" ]; then
      EXECUTABLE="$out/lib/openanime/Openanime"
    fi

    makeWrapper "$EXECUTABLE" $out/bin/openanime \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd ]}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAnime desktop application (openani.me)";
    homepage = "https://openani.me";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "openanime";
  };
}
