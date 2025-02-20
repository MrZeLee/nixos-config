{pkgs, ...}: {
  home.packages = with pkgs; [
    ani-cli
    ani-skip

    #dependencies
    syncplay
    gnugrep
    gnused
    curl
    mpv
    aria2
    yt-dlp
    ffmpeg_6-full
    fzf
    ani-skip
    gnupatch #iina - installed with homebrew
  ];
}
