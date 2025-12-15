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
    hash = "sha256-rqu4Aqp5VyQ/5+y1udAE/45ZThU1iJAlDZX8yf3ZafA=";
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
    (buildPythonPackage rec {
      pname = "antlr4-python3-runtime";
      version = "4.11.1";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-pT3nATEvm9rMUlimhyzWxiuQ06kK4l5JQCb3YmczO2A=";
      };
    })
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
