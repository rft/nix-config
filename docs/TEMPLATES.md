# Templates

Flake templates for bootstrapping new projects with [devenv](https://devenv.sh)
development shells. Each template provides a ready-to-use `flake.nix`,
`devenv.nix`, `.envrc`, and `.gitignore`.

## Available Templates

| Template | Description |
|----------|-------------|
| `python` | Python with [uv](https://docs.astral.sh/uv/) package manager |
| `python-cad` | Python CAD with [build123d](https://github.com/gumyr/build123d) and [CadQuery](https://cadquery.readthedocs.io) |
| `python-electronics` | Python electronics with [SKiDL](https://github.com/devbisme/skidl) |
| `python-datascience` | Python data science (numpy, pandas, scikit-learn, jupyter, marimo) |
| `rust`   | Rust stable toolchain |
| `node`   | [Node.js](https://nodejs.org) with TypeScript and npm |
| `gleam`  | [Gleam](https://gleam.run) with Erlang/OTP |
| `haskell` | [Haskell](https://www.haskell.org) with GHC, Cabal, and HLS |
| `veryl`  | [Veryl](https://veryl-lang.org) HDL with Verilator and Surfer |
| `prolog` | [SWI-Prolog](https://www.swi-prolog.org) |
| `ada`    | [Ada](https://www.adacore.com) with GNAT and gprbuild |
| `amaranth` | [Amaranth](https://amaranth-lang.org) HDL with yosys and Surfer |

## Usage

### Scaffold a new project

```bash
mkdir my-project && cd my-project
nix flake init -t github:rft/nix-config#python
```

Or from a local checkout:

```bash
nix flake init -t /home/nano/nix-config#python
```

This copies the template files into your current directory.

### Enter the dev shell

With direnv (recommended):

```bash
git init
direnv allow
```

Each template includes an `.envrc` that uses `use flake . --impure` for
automatic shell activation. This requires
[nix-direnv](https://github.com/nix-community/nix-direnv) (already included
in this config's programming module via direnv).

Without direnv:

```bash
nix develop --impure
```

### Customize

Edit `devenv.nix` to add packages, services, scripts, or pre-commit hooks.
Refer to the [devenv docs](https://devenv.sh/reference/options/) for all
available options.

---

## Template Details

### Python

Sets up Python with uv for dependency management. Dependencies are declared in
`pyproject.toml`.

**Files:**
- `flake.nix` -- Flake with devenv integration
- `devenv.nix` -- Python + uv configuration
- `pyproject.toml` -- Project metadata and dependencies
- `.envrc` -- direnv integration
- `.gitignore` -- Ignores for devenv, direnv, Python, uv, and Nix artifacts

**Adding dependencies:**

```bash
uv add requests numpy
```

**devenv.nix options:**

```nix
{ pkgs, ... }:
{
  languages.python = {
    enable = true;
    uv = {
      enable = true;
      sync.enable = true;  # auto-sync deps on shell entry
    };
  };

  # Add system packages
  packages = [ pkgs.ffmpeg ];

  # Add pre-commit hooks
  pre-commit.hooks.ruff.enable = true;
}
```

### Python CAD

Sets up Python with build123d and CadQuery for programmatic CAD modeling.
Includes ocp-vscode for viewing models in VS Code. System packages for OpenGL
rendering are provided via devenv.

**Files:**
- `flake.nix` -- Flake with devenv integration
- `devenv.nix` -- Python + uv + OpenGL system libraries
- `pyproject.toml` -- build123d, cadquery, ocp-vscode
- `.envrc` -- direnv integration
- `.gitignore` -- Ignores for devenv, direnv, Python, uv, and Nix artifacts

**Included packages:**
- `build123d` -- Pythonic CAD API built on OpenCascade
- `cadquery` -- Parametric CAD scripting
- `ocp-vscode` -- VS Code viewer for OCP models

### Python Electronics

Sets up Python with SKiDL for programmatic circuit design. SKiDL lets you
describe electronic circuits in Python instead of graphical schematic editors.

**Files:**
- `flake.nix` -- Flake with devenv integration
- `devenv.nix` -- Python + uv configuration
- `pyproject.toml` -- skidl, kinparse, matplotlib
- `.envrc` -- direnv integration
- `.gitignore` -- Ignores for devenv, direnv, Python, uv, and Nix artifacts

**Included packages:**
- `skidl` -- Python-based circuit description
- `kinparse` -- KiCad netlist parser
- `matplotlib` -- Plotting and visualization

### Python Data Science

Sets up Python with a standard data science stack. Includes notebooks via
Jupyter and Marimo.

**Files:**
- `flake.nix` -- Flake with devenv integration
- `devenv.nix` -- Python + uv configuration
- `pyproject.toml` -- Full data science stack
- `.envrc` -- direnv integration
- `.gitignore` -- Ignores for devenv, direnv, Python, uv, and Nix artifacts

**Included packages:**
- `numpy`, `scipy` -- Numerical computing
- `pandas`, `polars` -- DataFrames
- `scikit-learn` -- Machine learning
- `matplotlib`, `seaborn`, `plotly` -- Visualization
- `jupyter`, `ipython` -- Interactive notebooks
- `marimo` -- Reactive notebook environment

### Rust

Sets up the Rust stable toolchain via devenv.

**Files:**
- `flake.nix` -- Flake with devenv integration
- `devenv.nix` -- Rust stable channel
- `.envrc` -- direnv integration
- `.gitignore` -- Ignores for devenv, direnv, Rust, and Nix artifacts

**devenv.nix options:**

```nix
{ pkgs, ... }:
{
  languages.rust = {
    enable = true;
    channel = "stable";  # or "nightly"
  };

  # Add system packages (e.g. for crates with C dependencies)
  packages = [ pkgs.openssl pkgs.pkg-config ];

  # Add pre-commit hooks
  pre-commit.hooks.clippy.enable = true;
}
```

### Node

Sets up Node.js with TypeScript and npm via devenv's built-in language support.
npm dependencies are auto-installed on shell entry.

**Files:**
- `flake.nix` -- Flake with devenv integration
- `devenv.nix` -- Node.js + TypeScript + npm auto-install
- `.envrc` -- direnv integration
- `.gitignore` -- Ignores for devenv, direnv, Node, and Nix artifacts

**Included tools:**
- `node` -- Node.js runtime
- `npm` -- Package manager (auto-installs on shell entry)
- `typescript` -- TypeScript compiler

### Gleam

Sets up Gleam with the Erlang/OTP runtime via devenv's built-in language
support.

**Files:**
- `flake.nix` -- Flake with devenv integration
- `devenv.nix` -- Gleam + Erlang
- `.envrc` -- direnv integration
- `.gitignore` -- Ignores for devenv, direnv, Gleam, and Nix artifacts

**Included tools:**
- `gleam` -- Gleam compiler and build tool
- `erlang` -- Erlang/OTP runtime

### Haskell

Sets up Haskell with GHC, Cabal, and Haskell Language Server via devenv's
built-in language support.

**Files:**
- `flake.nix` -- Flake with devenv integration
- `devenv.nix` -- GHC + Cabal + HLS
- `.envrc` -- direnv integration
- `.gitignore` -- Ignores for devenv, direnv, Haskell, and Nix artifacts

**Included tools:**
- `ghc` -- Glasgow Haskell Compiler
- `cabal-install` -- Cabal build tool (provided by devenv)
- `haskell-language-server` -- LSP server

### Veryl

Sets up Veryl, a modern hardware description language, with Verilator for
simulation and Surfer for waveform viewing.

**Files:**
- `flake.nix` -- Flake with devenv integration
- `devenv.nix` -- Veryl + Verilator + Surfer
- `.envrc` -- direnv integration
- `.gitignore` -- Ignores for devenv, direnv, Veryl, and Nix artifacts

**Included tools:**
- `veryl` -- Veryl compiler and language server
- `verilator` -- Verilog/SystemVerilog simulator
- `surfer` -- Waveform viewer

### Prolog

Sets up SWI-Prolog for logic programming.

**Files:**
- `flake.nix` -- Flake with devenv integration
- `devenv.nix` -- SWI-Prolog
- `.envrc` -- direnv integration
- `.gitignore` -- Ignores for devenv, direnv, Prolog, and Nix artifacts

**Included tools:**
- `swiProlog` -- SWI-Prolog interpreter and compiler

### Ada

Sets up Ada with the GNAT compiler (GCC-based) and gprbuild project manager.

**Files:**
- `flake.nix` -- Flake with devenv integration
- `devenv.nix` -- GNAT + gprbuild
- `.envrc` -- direnv integration
- `.gitignore` -- Ignores for devenv, direnv, Ada, and Nix artifacts

**Included tools:**
- `gnat` -- GNAT Ada compiler (part of GCC)
- `gprbuild` -- GNAT project build tool

### Amaranth

Sets up [Amaranth HDL](https://amaranth-lang.org), a modern hardware definition
language based on Python. Includes yosys for synthesis and Surfer for waveform
viewing.

**Files:**
- `flake.nix` -- Flake with devenv integration
- `devenv.nix` -- Python + uv + yosys + Surfer
- `pyproject.toml` -- amaranth, amaranth-boards
- `.envrc` -- direnv integration
- `.gitignore` -- Ignores for devenv, direnv, Python, uv, Amaranth, and Nix artifacts

**Included packages:**
- `amaranth` -- Hardware definition language (via uv)
- `amaranth-boards` -- Board definitions for common FPGA boards (via uv)
- `yosys` -- Open-source synthesis suite (nix)
- `surfer` -- Waveform viewer (nix)

---

## Adding a New Template

1. Create a directory under `templates/`:
   ```
   templates/my-lang/
   ├── flake.nix
   ├── devenv.nix
   ├── .envrc
   └── .gitignore
   ```

2. Add the template to `flake.nix` outputs:
   ```nix
   templates.my-lang = {
     path = ./templates/my-lang;
     description = "My language development environment with devenv";
   };
   ```

3. The `flake.nix` inside each template follows the same pattern -- only
   `devenv.nix` changes between languages. You can copy an existing template's
   `flake.nix` as-is.
