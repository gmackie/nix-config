{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Node.js versions
    nodejs_20
    nodejs_18
    
    # Package managers
    nodePackages.npm
    nodePackages.yarn
    nodePackages.pnpm
    
    # Development tools
    nodePackages.typescript
    nodePackages.ts-node
    nodePackages.nodemon
    nodePackages.pm2
    
    # Linting and formatting
    nodePackages.eslint
    nodePackages.prettier
    
    # Build tools
    nodePackages.webpack
    nodePackages.vite
    nodePackages.parcel
    
    # Testing
    nodePackages.jest
    nodePackages.mocha
    
    # CLI tools
    nodePackages.create-react-app
    nodePackages.create-next-app
    nodePackages.vercel
    nodePackages.netlify-cli
    nodePackages.firebase-tools
    nodePackages.serverless
    
    # Language servers
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodePackages.dockerfile-language-server-nodejs
  ];
  
  # Set npm prefix for global packages
  environment.variables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };
}