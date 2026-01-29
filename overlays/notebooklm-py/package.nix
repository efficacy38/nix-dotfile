{
  lib,
  python3Packages,
  fetchFromGitHub,
  makeWrapper,
  playwright-driver,
}:

python3Packages.buildPythonApplication rec {
  pname = "notebooklm-py";
  version = "0.3.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "teng-lin";
    repo = "notebooklm-py";
    rev = "v${version}";
    hash = "sha256-TXaJbOfWklqDSrtWbZq1vaIMr+sCknfuSLYnfpI4QkU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  build-system = with python3Packages; [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = with python3Packages; [
    httpx
    click
    rich
    playwright
  ];

  pythonImportsCheck = [ "notebooklm" ];

  # Tests require network access and playwright
  doCheck = false;

  postFixup = ''
    wrapProgram $out/bin/notebooklm \
      --set PLAYWRIGHT_BROWSERS_PATH "${playwright-driver.browsers}"
  '';

  meta = {
    description = "Unofficial Python library for automating Google NotebookLM";
    homepage = "https://github.com/teng-lin/notebooklm-py";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "notebooklm";
  };
}
