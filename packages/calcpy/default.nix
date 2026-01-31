{
  lib,
  inputs,
  namespace,
  pkgs,
  python3,
  fetchFromGitHub,
  fetchPypi,
  ...
}:

python3.pkgs.buildPythonApplication rec {
  pname = "calcpy";
  version = "unstable-2024-08-16";

  src = fetchFromGitHub {
    owner = "idanpa";
    repo = "calcpy";
    rev = "main";
    hash = "sha256-ra96u/FGJeYKexmwaQJHdc5PACA9sdtTqXn5GyNly0Q=";
  };

  pyproject = true;
  build-system = [ python3.pkgs.setuptools ];

  propagatedBuildInputs = with python3.pkgs; [
    requests
    ipython
    pickleshare
    matplotlib
    sympy
    dateparser
    antlr4-python3-runtime
  ];

  # No tests available in the repository
  doCheck = false;

  meta = with lib; {
    description = "Terminal programmer calculator and advanced math solver";
    homepage = "https://github.com/idanpa/calcpy";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
