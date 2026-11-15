{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "services.actual";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.actual.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.ifEnabled =
    { myconfig, ... }:
    let
      fqdn = "${myconfig.host.name}.netbird.cloud";
      # DynamicUser: /var/lib/actual is a symlink to this.
      dataDir = "/var/lib/private/actual";
      tlsDir = "/var/lib/actual/tls";
    in
    {
      # Actual Budget sync server. Upstream defaults to port 3000, which
      # Karakeep already holds, so use Actual's own documented default.
      services.actual = {
        enable = true;
        settings = {
          port = 5006;
          # The web client needs SharedArrayBuffer, which browsers only expose
          # in a secure context — plain http works on localhost only. With no
          # reverse proxy here, Actual terminates TLS itself with the
          # self-signed cert generated below.
          https = {
            key = "${tlsDir}/key.pem";
            cert = "${tlsDir}/cert.pem";
          };
        };
      };

      # Runs after upstream's config generation, as the service's own user.
      # The cert is its own root (CA:TRUE is openssl's -x509 default), so each
      # device trusts this one file; see docs/SERVICES.md. Apple rejects TLS
      # certs valid for more than 825 days even from user-trusted roots.
      # Regenerated when within 30 days of expiry — devices then need the new
      # cert trusted again.
      systemd.services.actual.preStart = lib.mkAfter ''
        mkdir -p ${tlsDir}
        if ! ${lib.getExe pkgs.openssl} x509 -checkend 2592000 -noout -in ${tlsDir}/cert.pem 2>/dev/null; then
          ${lib.getExe pkgs.openssl} req -x509 -nodes -days 825 \
            -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
            -subj "/CN=${fqdn}" \
            -addext "subjectAltName=DNS:${fqdn}" \
            -addext "extendedKeyUsage=serverAuth" \
            -keyout ${tlsDir}/key.pem -out ${tlsDir}/cert.pem
        fi
      '';

      # Hardening is left as upstream ships it rather than forced to
      # hardenedServiceConfig: upstream is already stricter (DynamicUser,
      # PrivateUsers, empty CapabilityBoundingSet, ProtectProc=invisible), and
      # forcing our SystemCallFilter would drop the @pkey group V8 needs.

      # Web UI only, so NetBird-only rather than LAN-open.
      networking.firewall.interfaces.wt0.allowedTCPPorts = [ 5006 ];

      # account.sqlite (server password hash, file registry) is dumped; the
      # budgets in user-files are copied raw. Their per-budget group-<id>.sqlite
      # sync DBs have generated names the hook can't list, but every client
      # keeps a full local copy of its budget to re-upload if one is torn.
      services.borgmatic.settings = {
        source_directories = [ dataDir ];
        sqlite_databases = [
          {
            name = "actual";
            path = "${dataDir}/server-files/account.sqlite";
          }
        ];
        exclude_patterns = [ "${dataDir}/server-files/account.sqlite*" ];
      };
    };
}
