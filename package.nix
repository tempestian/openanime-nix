{
  lib,
  stdenv,
  fetchurl,
  binutils-unwrapped,
  autoPatchelfHook,
  makeWrapper,
  asar,
  python3,
  imagemagick,
  alsa-lib,
  at-spi2-atk,
  cacert,
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
    asar
    python3
    imagemagick
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

    # Disable nativeTheme.on updated event pop-up on Linux desktop portals / Wayland startup
    if [ -f "$out/lib/openanime/resources/app.asar" ]; then
      asar extract "$out/lib/openanime/resources/app.asar" asar-extracted
      if [ -f asar-extracted/src/window.js ]; then
        python3 -c "
import re
with open('asar-extracted/src/window.js', 'rb') as f:
    content = f.read()
pattern = rb'nativeTheme(\[\s*[\x27\"]on[\x27\"]\s*\]|\.on)\s*\('
match = re.search(pattern, content)
if match:
    content = content[:match.start()] + b'(()=>{})(' + content[match.end():]
    with open('asar-extracted/src/window.js', 'wb') as f:
        f.write(content)
"
        asar pack asar-extracted "$out/lib/openanime/resources/app.asar"
      fi
      rm -rf asar-extracted
    fi

    # Install icons into hicolor icon theme hierarchy for Wayland & Desktop Environments
    ICON_SRC=""
    if [ -f usr/share/pixmaps/openanime.png ]; then
      ICON_SRC="usr/share/pixmaps/openanime.png"
      cp "$ICON_SRC" $out/share/pixmaps/openanime.png
    fi

    if [ -n "$ICON_SRC" ]; then
      for size in 16 24 32 48 64 128 256 512 1024; do
        mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
        magick "$ICON_SRC" -resize "''${size}x''${size}" "$out/share/icons/hicolor/''${size}x''${size}/apps/openanime.png"
      done
    fi

    # Install and configure desktop entry
    if [ -f usr/share/applications/openanime.desktop ]; then
      cp usr/share/applications/openanime.desktop $out/share/applications/
      if ! grep -q "StartupWMClass" "$out/share/applications/openanime.desktop"; then
        echo "StartupWMClass=openanime" >> "$out/share/applications/openanime.desktop"
      fi
    fi

    # The executable can be either openanime or Openanime
    EXECUTABLE="$out/lib/openanime/openanime"
    if [ ! -f "$EXECUTABLE" ] && [ -f "$out/lib/openanime/Openanime" ]; then
      EXECUTABLE="$out/lib/openanime/Openanime"
    fi

    makeWrapper "$EXECUTABLE" $out/bin/openanime \
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd ]}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --disable-features=Vulkan}}"

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
