{ ... }: {
  programs.zsh = {
    sessionVariables.EDITOR = "vim";
    shellAliases = {
      pp = "pulumi";
      pps = "pulumi stack select";
      creds = "source ~/.config/2fctl/credentials.sh";
      shell = "nix develop -c $SHELL";
      format = "nixfmt ~/nix-config";
      gct = "git commit --template ~/.config/git/gitmessage";
      gf = "git commit --amend --no-edit --signoff";

      kx = "kubectx";
      c = "zed .";
      c1 = "cd ~/workspace/platform && zed .";
      c2 = "cd ~/workspace/platform/cosmic-inflation && zed .";
      c3 = "cd ~/workspace/platform/space && zed .";

      # 2F Login helpers
      dev2 = "2fctl login -a gov_AWS_2F_Dev";
      prd2 = "2fctl login -a gov_AWS_2F_Production";
      prd4 = "2fctl login -a gov_AWS_2F_IL4_Production";
      prd5 = "2fctl login -a gov_AWS_2F_IL5_Production";
      stg4 = "2fctl login -a gov_AWS_2F_IL4_Staging";
      stg5 = "2fctl login -a gov_AWS_2F_IL5_Staging";
      stg2 = "2fctl login -a gov_AWS_2F_Staging";
    };
  };
}
