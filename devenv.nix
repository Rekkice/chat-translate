{ pkgs, ... }: 

{ 
  languages.elixir.enable = true;
  packages = [
    pkgs.inotify-tools
    pkgs.nodejs_21
    pkgs.nodePackages_latest.npm
    pkgs.nodePackages_latest.typescript-language-server
    pkgs.flyctl
    pkgs.docker_25
  ];

  services.postgres = {
    enable = true;
    initialScript = ''
      CREATE ROLE postgres WITH SUPERUSER LOGIN PASSWORD 'postgres';
    '';
  };
}
