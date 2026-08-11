{ pkgs, ... }:

let
  marketplace = pkgs.nix-vscode-extensions.vscode-marketplace;
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (ps: with ps; [ gcc gdb ]);

    # Keep extensions immutable so another machine receives the exact set
    # locked by flake.lock instead of whatever the Marketplace serves later.
    mutableExtensionsDir = false;
    profiles.default = {
      extensions = with marketplace; [
        berrij.github-vscode-theme-dark-classic
        github.copilot-chat
        jeff-hykin.better-cpp-syntax
        ms-vscode.cmake-tools
        ms-vscode.cpp-devtools
        ms-vscode.cpptools
        ms-vscode.cpptools-extension-pack
        ms-vscode.cpptools-themes
        ms-vscode.remote-explorer
        ms-vscode.remote-server
        ngtystr.ppm-pgm-viewer-for-vscode
        openai.chatgpt
        vscodevim.vim
      ];

      userSettings = {
        "workbench.colorTheme" = "Light+";
        "explorer.sortOrder" = "type";
        "redhat.telemetry.enabled" = false;
      };

      keybindings = [
        {
          key = "ctrl+alt+c";
          command = "workbench.action.tasks.build";
        }
        {
          key = "ctrl+alt+r";
          command = "workbench.action.tasks.test";
        }
      ];

      userTasks = {
        version = "2.0.0";
        tasks = [
          {
            type = "cppbuild";
            label = "C/C++: g++ build active file";
            command = "g++";
            args = [
              "-g"
              "-std=c++17"
              "-Wall"
              "-Wextra"
              "-pedantic-errors"
              "-Weffc++"
              "-Wno-unused-parameter"
              "-fsanitize=undefined,address"
              "\${workspaceFolder}/*.cpp"
              "-o"
              "\${fileBasenameNoExtension}"
            ];
            options.cwd = "\${fileDirname}";
            problemMatcher = [ "$gcc" ];
            group = {
              kind = "build";
              isDefault = true;
            };
            detail = "compiler: g++";
          }
          {
            label = "Run";
            type = "shell";
            dependsOn = "C/C++: g++ build active file";
            command = "./\${fileBasenameNoExtension}";
            args = [ ];
            options.cwd = "\${fileDirname}";
            presentation = {
              reveal = "always";
              focus = true;
            };
            problemMatcher = [ ];
            group = {
              kind = "build";
              isDefault = true;
            };
          }
        ];
      };
    };
  };
}
