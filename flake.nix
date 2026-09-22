{
  description = "Public Home Manager shell modules and mise configuration";

  outputs = { self }: {
    homeManagerModules = {
      workstation = import ./nix/workstation.nix;
      shell = import ./nix/shell/core.nix;
      npmPrefix = import ./nix/shell/npm-prefix.nix;
      userToolPaths = import ./nix/shell/user-tool-paths.nix;
      homebrewPaths = import ./nix/shell/homebrew-paths.nix;
      miseActivation = import ./nix/shell/mise-activation.nix;
      macosVsCode = import ./nix/shell/macos-vscode.nix;
      herdrCompletion = import ./nix/shell/herdr-completion.nix;
      gitWorktrees = import ./nix/shell/git-worktrees.nix;
      wslVsCode = import ./nix/shell/wsl-vscode.nix;
    };
  };
}
