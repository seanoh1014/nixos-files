{ config, pkgs,  ... }: 

let

    batify = import 
            ( pkgs.fetchFromGitHub 
                { 
                    owner = "ikrivosheev"; 
                    repo = "batify2"; 
                    rev= "";
                    sha256= "";
                }
            );

in

{ 
    environment = 
        {
            systemPackages = 
                [
                    batify
                ];
        };
}
