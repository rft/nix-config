{ delib, inputs, ... }:
delib.module {
  name = "core";

  nixos.always = { pkgs, ... }: {
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
}
