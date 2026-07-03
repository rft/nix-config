# VPS Deployment (juniper)

`juniper` is a barebones server host for a generic KVM VPS. It carries only the
always-on baseline (core packages, xonsh, SSH, Netbird) — no desktop, no
self-hosted services. It is installed remotely with
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere) and updated
with [deploy-rs](https://github.com/serokell/deploy-rs).

Key properties:

- **SSH is key-only** — password and keyboard-interactive auth are disabled by
  `modules/core/ssh.nix`; the keys in `myconfig.constants.sshKeys` are
  authorized for both `nano` and `root` (root is `prohibit-password`, needed by
  nixos-anywhere and deploy-rs).
- **Netbird is the access path** — the client comes from core; the tunnel
  interface `wt0` is a trusted firewall interface, so once the peer is enrolled
  you can reach the machine (and later close public SSH) via the Netbird mesh.
- **Disk layout is declarative** — `hardware/juniper.nix` (disko) defines a
  hybrid BIOS+UEFI GPT layout, so it boots on either VPS firmware. Swap is
  zram, no swap partition.

## First-time install with nixos-anywhere

nixos-anywhere kexecs the VPS into a NixOS installer, **wipes the disk**
according to the disko layout, and installs the flake's configuration.

1. **Prerequisites**
   - A VPS (x86_64, ideally ≥1.5 GB RAM for the kexec image) running any Linux
     with root SSH access — most providers' stock Debian/Ubuntu image is fine.
   - Your SSH key must be in `myconfig.constants.sshKeys`
     (`modules/config/constants.nix`) *and* accepted by the provider's stock
     image (add it via the provider panel or `ssh-copy-id`).
   - An x86_64-linux machine to deploy from (e.g. mistletoe); the system is
     built locally and pushed.

2. **Check the disk device.** On the VPS run `lsblk`. The layout in
   `hardware/juniper.nix` assumes `/dev/vda` (typical for KVM); change it if
   the provider exposes `/dev/sda` or an NVMe device.

3. **Install:**

   ```bash
   nix run github:nix-community/nixos-anywhere -- --flake .#juniper root@<public-ip>
   ```

   This destroys everything on the target disk. The machine reboots into NixOS
   when it finishes.

4. **Verify access** (key-only; a password prompt means something is wrong):

   ```bash
   ssh nano@<public-ip>
   ```

## Enroll in Netbird

On the freshly installed host:

```bash
sudo netbird up          # interactive browser/device-code login
# or, with a setup key from the Netbird admin panel (keys are NOT managed in nix):
sudo netbird up --setup-key <key>
sudo netbird status
```

Rename the peer to `juniper` in the Netbird admin panel if it didn't pick up
the hostname, so the mesh DNS name matches the deploy target
(`juniper.netbird.cloud`). From another enrolled machine:

```bash
ssh nano@juniper.netbird.cloud
```

## Updating with deploy-rs

The deploy target is defined in `flake.nix` under `deploy.nodes.juniper`
(hostname `juniper.netbird.cloud`, pushed as `root`). From the repo root on an
x86_64-linux machine that is on the Netbird mesh:

```bash
nix run nixpkgs#deploy-rs -- .#juniper
```

Useful variants:

```bash
# before the host is on netbird, deploy via the public IP
nix run nixpkgs#deploy-rs -- --hostname <public-ip> .#juniper

# build without activating on the target
nix run nixpkgs#deploy-rs -- --dry-activate .#juniper
```

deploy-rs uses magic rollback: if the new generation breaks the SSH connection
back to you, it automatically reverts after ~30 s, which makes remote firewall
and SSH changes safe to try.

`nix flake check` runs the deploy-rs schema/activation checks added in
`flake.nix` (`checks.<system>.deploy-schema`, `deploy-activate`).

## Optional: close public SSH after Netbird works

Once you have confirmed SSH over the mesh, you can drop port 22 from the
public interface — `wt0` is a trusted interface, so mesh SSH keeps working:

```nix
# hosts/juniper/default.nix (nixos block)
networking.firewall.allowedTCPPorts = lib.mkForce [ ];
```

Deploy it with `--dry-activate` first, then for real — magic rollback will
recover the box if you locked yourself out.

## Adding another VPS host

1. Copy `hosts/juniper/default.nix` to `hosts/<newname>/default.nix` (tree/plant
   name), set `name`, timezone, and the current `stateVersion`.
2. Copy `hardware/juniper.nix` to `hardware/<newname>.nix`, adjust the disk
   device, and point the host's import at it. Do **not** put extra `.nix` files
   under `hosts/<newname>/` — denix auto-loads every file there as a module.
3. Add a `deploy.nodes.<newname>` entry in `flake.nix`.
4. `git add` the new files, then eval:
   `nix eval .#nixosConfigurations.<newname>.config.system.build.toplevel.drvPath`
5. Install with nixos-anywhere as above. No other flake changes are needed —
   hosts are discovered automatically.
