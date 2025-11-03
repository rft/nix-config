ps:
let
  xxh = ps.callPackage ../packages/xxh {
    python3Packages = ps;
  };
in
with ps; [
  numpy
  requests
  coconut
  sympy
  matplotlib
  scipy
  polars
  pandas
  beautifulsoup4
  ipdb
  xxh
  xonsh.xontribs.xontrib-vox
  xonsh.xontribs.xonsh-direnv
  xonsh.xontribs.xontrib-whole-word-jumping
  xonsh.xontribs.xontrib-bashisms
]
