{ delib, pkgs, ... }:
let
  username = "astro";
  homeDir = "/Users/${username}";
in
delib.host {
  name = "pineapple";
  type = "darwin";
  system = "aarch64-darwin";

  home = {
    home.stateVersion = "24.05";

    # Let bristlecone in (it fetches models into ~/Models). Kept here rather
    # than in constants.sshKeys so the server's key reaches this host only.
    # `text` is a lines option, so this appends to core.ssh's shared keys.
    home.file.".ssh/authorized_keys".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDoWgwgUW/gjYvlxz6tEz3hs4DFO1+nMeUbbQiTG8yR0 nano@bristlecone
    '';
  };

  darwin = {
    homebrew.casks = [ "google-chrome" ];

    environment.systemPackages = [
      pkgs.llama-cpp
      pkgs.colima
      pkgs.docker-client
    ];

    # Vision model for Karakeep's AI tagging (bristlecone reaches it over
    # NetBird). Qwen3.6-35B-A3B Q4_K_M + its Q8_0 mmproj from
    # ggml-org/Qwen3.6-35B-A3B-GGUF, downloaded by hand into ~/Models. One
    # model serves both text and image tagging.
    launchd.user.agents.llama-server = {
      serviceConfig = {
        Label = "com.llama-cpp.server";
        ProgramArguments = [
          "${pkgs.llama-cpp}/bin/llama-server"
          "--host"
          "0.0.0.0"
          "--port"
          "8080"
          "--model"
          "${homeDir}/Models/karakeep.gguf"
          "--mmproj"
          "${homeDir}/Models/karakeep-mmproj.gguf"
          # Stable name for Karakeep's INFERENCE_*_MODEL settings.
          "--alias"
          "karakeep"
          # Chat template from the GGUF; needed for json_schema output.
          "--jinja"
          # Qwen3.6 thinks by default; tagging doesn't need it and the
          # thinking tokens only slow each job down.
          "--reasoning"
          "off"
          # Qwen's recommended sampling for non-thinking mode.
          "--temp"
          "0.7"
          "--top-p"
          "0.8"
          "--top-k"
          "20"
          "--presence-penalty"
          "1.5"
          "--n-gpu-layers"
          "999"
          # Karakeep runs one inference job at a time, so keep a single slot
          # rather than splitting the context across parallel ones.
          "--parallel"
          "1"
          "--ctx-size"
          "16384"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${homeDir}/Library/Logs/llama-server.log";
        StandardErrorPath = "${homeDir}/Library/Logs/llama-server.err";
      };
    };

    # macOS caps GPU-wired memory at ~2/3 of RAM (~21 GB on 32 GB), which the
    # 20.5 GB model + 0.6 GB mmproj + KV cache would brush against. Raise it to
    # 24 GB at boot; the sysctl doesn't persist across reboots on its own.
    launchd.daemons.gpu-wired-limit = {
      serviceConfig = {
        Label = "com.user.gpu-wired-limit";
        ProgramArguments = [
          "/usr/sbin/sysctl"
          "iogpu.wired_limit_mb=24576"
        ];
        RunAtLoad = true;
      };
    };

    # Keep the machine awake on boot (system sleep disabled while running).
    launchd.user.agents.caffeinate = {
      serviceConfig = {
        Label = "com.user.caffeinate";
        ProgramArguments = [
          "/usr/bin/caffeinate"
          "-s"
        ];
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };

  myconfig = {
    constants.username = username;

    applications.enable = true;
    programs.programming.enable = true;
    programs.programming.cloud.enable = true;
    fonts.enable = true;
  };
}
