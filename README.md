# NixOS Configuration

This repository contains my personal NixOS configuration, managed using flakes.
It includes configurations for both NixOS (Linux) and Darwin (macOS) systems.

**Key Features:**

- Declarative system configuration using Nix.
- Home Manager integration for user-specific settings.
- Flakes for reproducible builds and dependency management.
- Configurations for both desktop/laptop (NixOS) and MacBook Pro (Darwin).

**Getting Started:**

To use this configuration, you'll need Nix and flakes enabled. See the
[NixOS website](https://nixos.org/) for installation instructions.

**Structure:**

- `flake.nix`: Main flake file that defines inputs and outputs.
- `hosts/`: System-specific configurations.
- `home/`: User-specific configurations managed by Home Manager.
- `pkgs/`: Custom packages and overlays.
- `system/`: System wide configuration

**Contributing:**

This is my personal configuration, so I am not actively soliciting
contributions. However, feel free to fork and adapt it for your own use! This
repository contains my personal NixOS configurations, managed using flakes. It's
designed to be modular and easily customizable to fit my specific needs across
different machines.
