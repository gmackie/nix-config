{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Python versions
    python311
    python312
    
    # Python package managers
    python311Packages.pip
    python311Packages.setuptools
    python311Packages.wheel
    pipenv
    poetry
    
    # Python development tools
    python311Packages.ipython
    python311Packages.jupyter
    python311Packages.black
    python311Packages.pylint
    python311Packages.mypy
    python311Packages.pytest
    python311Packages.tox
    python311Packages.virtualenv
    
    # Common Python libraries
    python311Packages.numpy
    python311Packages.pandas
    python311Packages.matplotlib
    python311Packages.requests
    python311Packages.beautifulsoup4
    python311Packages.sqlalchemy
    python311Packages.redis
    python311Packages.boto3
    
    # Python LSP
    python311Packages.python-lsp-server
    python311Packages.python-lsp-black
    python311Packages.pylsp-mypy
    python311Packages.python-lsp-ruff
  ];
}