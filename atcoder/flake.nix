{
  description = "flake for atcoder";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, systems, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;

      perSystem = { pkgs, ... }: let
        inherit (pkgs) buildPythonPackage buildPythonApplication;

        my-atcoder-cli = pkgs.buildNpmPackage {
          pname = "atcoder-cli";
          version = "2.2.0";
          src = pkgs.fetchFromGitHub {
            owner = "Tatamo"; repo = "atcoder-cli";
            rev = "f385e71ba270716f5a94e3ed9bd23a24f78799d0";
            hash = "sha256-7pbCTgWt+khKVyMV03HanvuOX2uAC0PL9OLmqly7IWE=";
          };
          npmDepsHash = "sha256-ufG7Fq5D2SOzUp8KYRYUB5tYJYoADuhK+2zDfG0a3ks=";
          npmFlags = "--ignore-scripts";
          buildPhase = ''
            export NODE_OPTIONS=--openssl-legacy-provider
            npm run build
          '';
          installPhase = ''
            runHook preInstall
            libPath=$out/lib/node_modules/atcoder-cli
            mkdir -p "$libPath"
            cp -r bin "$libPath/"
            cp -r schema "$libPath/"
            cp -r node_modules "$libPath/"
            cp package.json "$libPath/"
            mkdir -p "$out/bin"
            cat > "$out/bin/acc" <<ENDOFSCRIPT
          #!/bin/sh
          exec ${pkgs.nodejs}/bin/node $libPath/bin/index.js "\$@"
          ENDOFSCRIPT
            chmod +x "$out/bin/acc"
            runHook postInstall
          '';
        };

        my-aclogin = buildPythonApplication {
          pname = "aclogin"; version = "0.1.3";
          format = "setuptools";
          src = pkgs.fetchFromGitHub {
            owner = "key-moon"; repo = "aclogin";
            rev = "e461311c0326578b16d1488be84261f4b24f6134";
            hash = "sha256-kyU7KpFenFb7obwSrDp6dPfuE+36r0BGYerrJj3+EyA=";
          };
          propagatedBuildInputs = [ pkgs.python3Packages.appdirs ];
        };

        my-online-judge-api-client = buildPythonPackage {
          pname = "online-judge-api-client"; version = "10.10.1-dev";
          format = "setuptools";
          src = pkgs.fetchFromGitHub {
            owner = "online-judge-tools"; repo = "api-client";
            rev = "615c345f169e2603e0b907287559a4535fc3c6f9";
            hash = "sha256-mi+Ihqjrbe6zu9BEej/+VdIjVk8kJGKMfHG0ZXZno44=";
          };
          doCheck = false;
          patchPhase = ''
            sed -i "s/(KB|MB)'/(KB|MB|MiB)'/" onlinejudge/service/atcoder.py
            sed -i "s/memory_limit_unit == 'MB'/memory_limit_unit in ('MB', 'MiB')/" onlinejudge/service/atcoder.py
          '';
          propagatedBuildInputs = with pkgs.python3Packages; [
            appdirs beautifulsoup4 colorlog lxml requests jsonschema
          ];
        };

        my-online-judge-tools = buildPythonApplication {
          pname = "online-judge-tools"; version = "12.0.0-dev";
          format = "setuptools";
          src = pkgs.fetchFromGitHub {
            owner = "online-judge-tools"; repo = "oj";
            rev = "d90b0a2bd87ae72cf89951b80c8fa4bd834afd0a";
            hash = "sha256-m6V4Sq3yU/KPnbpA0oCLI/qaSrAPA6TutcBL5Crb/Cc=";
          };
          doCheck = false;
          propagatedBuildInputs = with pkgs.python3Packages; [
            colorama my-online-judge-api-client packaging requests
          ];
        };
      in {
        packages = {
          inherit my-atcoder-cli my-online-judge-tools my-aclogin;
          atcoder-cli = my-atcoder-cli;
          aclogin = my-aclogin;
          default = my-atcoder-cli;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.gcc
            pkgs.llvmPackages.clang-tools
            pkgs.python3
            my-atcoder-cli
            my-online-judge-tools
            my-aclogin
          ];
          shellHook = ''
            TOOLS="$PWD/tools"
            if [[ -d "$TOOLS" ]] && [[ ":$PATH:" != *":$TOOLS:"* ]]; then
              export PATH="$TOOLS:$PATH"
            fi
            if [[ -f "$TOOLS/chelp" ]]; then
              bash "$TOOLS/chelp"
            fi
          '';
        };
      };
    };
}
