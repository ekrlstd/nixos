{ ... }:
{
  xdg.mime.defaultApplications = {
    "application/json" = "nvim.desktop";
    "application/x-zerosize" = "nvim.desktop";
    "text/markdown" = "nvim.desktop";
    "text/plain" = "nvim.desktop";
    "text/x-c++src" = "nvim.desktop";
    "text/x-csrc" = "nvim.desktop";
    "text/x-python" = "nvim.desktop";
    "text/x-shellscript" = "nvim.desktop";
    "x-scheme-handler/http" = "zen-beta.desktop";
    "x-scheme-handler/https" = "zen-beta.desktop";
    "x-scheme-handler/chrome" = "zen-beta.desktop";
    "text/html" = "zen-beta.desktop";
    "application/x-extension-htm" = "zen-beta.desktop";
    "application/x-extension-html" = "zen-beta.desktop";
    "application/x-extension-shtml" = "zen-beta.desktop";
    "application/xhtml+xml" = "zen-beta.desktop";
    "application/x-extension-xhtml" = "zen-beta.desktop";
    "application/x-extension-xht" = "zen-beta.desktop";
  };
  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [ "kitty.desktop" ];
    };
  };
}
