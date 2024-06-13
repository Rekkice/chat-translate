{ pkgs, ... }: 

{ 
  languages.elixir.enable = true;
  packages = [
    pkgs.inotify-tools
    pkgs.nodejs_21
    pkgs.nodePackages_latest.npm
  ];

  services.postgres = {
    enable = true;
    initialScript = ''
      CREATE ROLE postgres WITH SUPERUSER LOGIN PASSWORD 'postgres';
    '';
  };
}
