{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  sox,
  flac,
  lame,
  wrapGAppsHook,
  ffmpeg,
  vorbis-tools,
  pulseaudio,
  nodejs,
  yt-dlp,
  qt5,
  opusTools,
  gst_all_1,
  enableSonos ? true,
}:
let
  packages = [
    vorbis-tools
    sox
    flac
    lame
    opusTools
    gst_all_1.gstreamer
    nodejs
    ffmpeg
    yt-dlp
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ pulseaudio ];

in
python3Packages.buildPythonApplication {
  pname = "mkchromecast-unstable";
  version = "2025-06-01";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "muammar";
    repo = "mkchromecast";
    rev = "6e583366ae23b56a33c1ad4ca164e04d64174538";
    sha256 = "sha256-CtmOkQAqUNn7+59mWEfAsgtWmGcXD3eE9j2t3sLnXms=";
  };

  buildInputs = lib.optional stdenv.hostPlatform.isLinux qt5.qtwayland;
  propagatedBuildInputs =
    with python3Packages;
    (
      [
        pychromecast
        psutil
        mutagen
        flask
        netifaces
        requests
        pyqt5
      ]
      ++ lib.optionals enableSonos [ soco ]
    );

  postPatch = ''
    substituteInPlace setup.py \
      --replace 'platform.system() == "Darwin"' 'False' \
      --replace 'platform.system() == "Linux"' 'True'
  '';

  nativeBuildInputs = [ wrapGAppsHook ];

  # Relies on an old version (0.7.7) of PyChromecast unavailable in Nixpkgs.
  # Is also I/O bound and impure, testing an actual device, so we disable.
  doCheck = false;

  dontWrapGApps = true;
  dontWrapQtApps = true;

  makeWrapperArgs = [
    # "${gappsWrapperArgs[@]}"
    "--prefix PATH : ${lib.makeBinPath packages}"
  ];

  postInstall = ''
    substituteInPlace $out/${python3Packages.python.sitePackages}/mkchromecast/video.py \
      --replace '/usr/share/mkchromecast/nodejs/' '${placeholder "out"}/share/mkchromecast/nodejs/'
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    install -Dm 755 -t $out/bin bin/audiodevice
    substituteInPlace $out/${python3Packages.python.sitePackages}/mkchromecast/audio_devices.py \
      --replace './bin/audiodevice' '${placeholder "out"}/bin/audiodevice'
  '';

  meta = with lib; {
    homepage = "https://mkchromecast.com/";
    description = "Cast macOS and Linux Audio/Video to your Google Cast and Sonos Devices";
    license = licenses.mit;
    maintainers = with maintainers; [ shou ];
    mainProgram = "mkchromecast";
  };
}
