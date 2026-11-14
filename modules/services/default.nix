{ delib, ... }:
# Parent toggle for the self-hosted services. Each service is its own module
# in this directory and follows this toggle by default, so a host can take the
# whole set (`services.enable = true`) or pick individual ones
# (`services.jellyfin.enable = true`).
delib.module {
  name = "services";

  options = delib.singleEnableOption false;
}
