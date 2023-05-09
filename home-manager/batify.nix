{ stdenv, fetchurl }:

let 

  stdenv.mkDerivation {
    name = "batify";
    src = fetchurl {
    url = "http://github.com/Ventto/batify/tarball/master";
    sha256 = "1111111111111111111111111111111111111111111111111111";
    };
  }

in
{
  home.packages = [ batify ];
}
