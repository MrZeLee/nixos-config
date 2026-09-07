{
  lib,
  stdenv,
  fetchzip,
  copyDesktopItems,
  makeDesktopItem,
  bash,
  steam-run,
}:

stdenv.mkDerivation rec {
  pname = "optcg-sim";
  version = "1.43a";

  # Upstream only publishes to Google Drive; the file id changes with every
  # release, so bumping the version means re-copying the link from
  # https://optcgsim.com.
  src = fetchzip {
    url = "https://drive.usercontent.google.com/download?id=1y4B_4Njq4xNHY02fda8kqxb7CDd7YvZ2&export=download&confirm=t";
    hash = "sha256-IDBAKASRSBscK9Vexg+DPDwzt7BcXZS1ht+BazooL3U=";
    extension = "zip";
    stripRoot = true;
  };

  nativeBuildInputs = [ copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = "optcg-sim";
      desktopName = "OPTCG Sim";
      exec = "optcg-sim";
      icon = "optcg-sim";
      categories = [ "Game" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    install -d $out/opt/OPTCGSim
    cp -a ./* $out/opt/OPTCGSim/
    chmod +x $out/opt/OPTCGSim/OPTCGSim.x86_64

    install -d $out/libexec
    substitute ${./optcg-sim-run.in} $out/libexec/optcg-sim-run \
      --subst-var-by bash ${bash} \
      --subst-var-by steamrun ${steam-run}/bin/steam-run \
      --subst-var-by version ${version} \
      --subst-var-by out $out
    chmod +x $out/libexec/optcg-sim-run

    install -d $out/bin
    ln -s $out/libexec/optcg-sim-run $out/bin/optcg-sim

    install -Dm644 OPTCGSim_Data/Resources/UnityPlayer.png \
      $out/share/icons/hicolor/256x256/apps/optcg-sim.png

    runHook postInstall
  '';

  meta = {
    description = "One Piece TCG Simulator";
    homepage = "https://optcgsim.com";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    mainProgram = "optcg-sim";
  };
}
