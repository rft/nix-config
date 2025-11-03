{
  lib,
  fetchFromGitHub,
  python3Packages,
  ...
}:

python3Packages.buildPythonApplication rec {
  pname = "xxh";
  version = "0.8.14";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "xxh";
    repo = "xxh";
    rev = version;
    hash = "sha256-Y1yTn0lZemQgWsW9wlW+aNndyTXGo46PCbCl0TGYspQ=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3Packages; [
    pexpect
    pyyaml
  ];

  doCheck = false;

  pythonImportsCheck = [ "xxh_xxh" ];

  meta = with lib; {
    description = "Bring your favorite shell wherever you go through ssh";
    homepage = "https://github.com/xxh/xxh";
    license = licenses.bsd3;
    maintainers = [ ];
    mainProgram = "xxh";
    platforms = platforms.unix;
  };
}
