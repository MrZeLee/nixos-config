{
  lib,
  python3,
  fetchFromGitHub,
  gobject-introspection,
  wrapGAppsHook3,
  killall,
}:

# Using this version so I can use scretch with swww

python3.pkgs.buildPythonApplication rec {
  pname = "waypaper";
  version = "2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "MrZeLee";
    repo = "waypaper";
    rev = "main";
    hash = "sha256-LeZg8/YRzqpZiWR8YsI32WL7e3X6ennwAjZSXJdrX9M=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  build-system = [python3.pkgs.setuptools];

  dependencies = [
    python3.pkgs.imageio
    python3.pkgs.imageio-ffmpeg
    python3.pkgs.screeninfo
    python3.pkgs.pygobject3
    python3.pkgs.platformdirs
    python3.pkgs.importlib-metadata
    python3.pkgs.pillow
  ];

  propagatedBuildInputs = [killall];

  # has no tests
  doCheck = false;

  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    changelog = "https://github.com/anufrievroman/waypaper/releases/tag/${version}";
    description = "GUI wallpaper setter for Wayland-based window managers";
    mainProgram = "waypaper";
    longDescription = ''
      GUI wallpaper setter for Wayland-based window managers that works as a frontend for popular backends like swaybg and swww.

      If wallpaper does not change, make sure that swaybg or swww is installed.
    '';
    homepage = "https://github.com/anufrievroman/waypaper";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [totalchaos];
    platforms = platforms.linux;
  };
}
