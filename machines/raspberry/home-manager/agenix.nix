{ inputs, ... }: {
    imports = [inputs.agenix.homeManagerModules.default];
    
    age.secrets.spotifyd.file = ./secrets/spotifyd.age;
}