{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    initExtra = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
    plugins = [
      { name = "zsh-autosuggestions"; src = pkgs.zsh-autosuggestions; }
      { name = "zsh-syntax-highlighting"; src = pkgs.zsh-syntax-highlighting; }
      { name = "zsh-completions"; src = pkgs.zsh-completions; }
      { name = "powerlevel10k"; src = pkgs.zsh-powerlevel10k; file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme"; }
    ];
    oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins =
        [
            "git"
            "npm"
            "history"
            "node"
            "rust"
            "deno"
        ];
    };
    profileExtra = ''
      export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share
    '';
  };

  programs.git = {
    enable = true;
    userName  = "efficacy38";
    userEmail = "efficacy38@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
    };
  };

  home.file = {
    ".p10k.zsh" = {
      source = ../dotfiles/p10k.zsh;
    };
  };
}
