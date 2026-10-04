{ config, ... }:

{
  # The hermes CLI on PATH.
  programs.hermes-agent.enable = true;

  services.hermes-agent = {
    enable = true;
    gateway.enable = true;
    settings.model.default = "anthropic/claude-sonnet-4";
    # Shortcuts for /model <name>.
    settings.model_aliases = {
      qwen = { model = "qwen/qwen3.8-27b:free"; provider = "openrouter"; };
    };
    # API keys live outside the Nix store, e.g. ANTHROPIC_API_KEY=sk-ant-...
    environmentFiles = [ "${config.home.homeDirectory}/.config/hermes/env" ];
  };
}
