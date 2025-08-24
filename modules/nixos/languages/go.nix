{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Go compiler
    go_1_21
    
    # Go tools
    gopls # Language server
    delve # Debugger
    go-tools # Various Go tools (goimports, etc.)
    golangci-lint # Linter aggregator
    gomodifytags # Modify struct tags
    gotests # Generate tests
    impl # Generate interface implementations
    
    # Build tools
    goreleaser
    ko # Build and deploy Go applications to Kubernetes
    
    # Development tools
    air # Live reload for Go apps
    goose # Database migrations
    sqlc # Generate type-safe Go from SQL
    
    # Testing
    gotestsum # Better test output
    ginkgo # BDD testing framework
    gomega # Matcher library for Ginkgo
    
    # Documentation
    godoc
  ];
  
  # Go environment variables
  environment.variables = {
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
  };
  
  # Add GOBIN to PATH
  environment.sessionVariables = {
    PATH = "$GOBIN:$PATH";
  };
}