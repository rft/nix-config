{ delib, inputs, pkgs, ... }:
delib.module {
  name = "core";

  nixos.always = {
    home-manager.backupFileExtension = "backup";

    environment.systemPackages = with pkgs; [
      atuin
      bandwhich
      bat
      binsider
      bottom
      bpftrace
      claude-code
      codex
      copilot-cli
      cpuid
      csvlens
      difftastic
      distrobox
      dua
      ethtool
      fd
      ffmpeg_7-full
      fzf
      gemini-cli
      gh
      git
      hexyl
      inputs.nixcats-nvim.packages.${pkgs.stdenv.hostPlatform.system}.default
      iproute2
      jq
      lazygit
      msr-tools
      nicstat
      numactl
      oxker
      pandoc
      pass
      picat
      podman
      podman-tui
      procps
      procs
      rclone
      rink
      ripgrep
      rr
      rsync
      syncthing
      sysstat
      tcpdump
      tealdeer
      tio
      tokei
      trippy
      util-linux
      visidata
      watchexec
      wget
      yazi
      yq
      yt-dlp
      zellij
      zoxide
    ];

    virtualisation = {
      podman.enable = true;
      containers.registries.search = [ "docker.io" ];
    };

    users.defaultUserShell = "/run/current-system/sw/bin/xonsh";

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  darwin.always = {
    home-manager.backupFileExtension = "backup";

    environment.systemPackages = with pkgs; [
      atuin
      bandwhich
      bat
      binsider
      bottom
      claude-code
      codex
      copilot-cli
      csvlens
      difftastic
      dua
      fd
      ffmpeg_7-full
      fzf
      gemini-cli
      gh
      git
      hexyl
      inputs.nixcats-nvim.packages.${pkgs.stdenv.hostPlatform.system}.default
      jq
      lazygit
      oxker
      pandoc
      pass
      picat
      procs
      rclone
      rink
      ripgrep
      rsync
      syncthing
      tealdeer
      tio
      tokei
      trippy
      visidata
      watchexec
      wget
      yazi
      yq
      yt-dlp
      zellij
      zoxide
    ];

    nix.gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };
}
