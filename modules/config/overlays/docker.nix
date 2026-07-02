{ delib, ... }:
delib.overlayModule {
  name = "docker";
  # docker 28.x (the default `docker` attr in 25.11) is unmaintained and
  # marked insecure; point `docker` at docker_29 so modules that hardcode
  # pkgs.docker (e.g. kasmweb) keep evaluating.
  overlay = _final: prev: {
    docker = prev.docker_29;
  };
}
