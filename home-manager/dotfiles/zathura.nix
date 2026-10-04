{ lib, config, pkgs, ... }:

{
  programs.zathura = {
    enable = true;
    package = pkgs.zathura;
    extraConfig = ''
      set default-fg                "#4C4F69"
      set default-bg 	            "#EFF1F5"

      set completion-bg		          "#CCD0DA"
      set completion-fg		          "#4C4F69"
      set completion-highlight-bg	  "#575268"
      set completion-highlight-fg	  "#4C4F69"
      set completion-group-bg		    "#CCD0DA"
      set completion-group-fg		    "#1E66F5"

      set statusbar-fg		          "#4C4F69"
      set statusbar-bg		          "#CCD0DA"

      set notification-bg		        "#CCD0DA"
      set notification-fg		        "#4C4F69"
      set notification-error-bg	    "#CCD0DA"
      set notification-error-fg	    "#D20F39"
      set notification-warning-bg	  "#CCD0DA"
      set notification-warning-fg	  "#FAE3B0"

      set inputbar-fg			      "#4C4F69"
      set inputbar-bg 		          "#CCD0DA"

      set recolor-lightcolor	      "#EFF1F5"
      set recolor-darkcolor		      "#4C4F69"

      set index-fg			            "#4C4F69"
      set index-bg			            "#EFF1F5"
      set index-active-fg		        "#4C4F69"
      set index-active-bg		        "#CCD0DA"

      set render-loading-bg		      "#EFF1F5"
      set render-loading-fg		      "#4C4F69"

      set highlight-color		        "#575268"
      set highlight-fg                  "#EA76CB"
      set highlight-active-color	    "#EA76CB"
     '';
  };

  # Read by zathura-pdf-mupdf for EPUBs; overrides publisher styling that breaks layout
  xdg.configFile."zathura/epub.css".text = ''
    body, p, div, span, li, td, blockquote {
      font-family: serif !important;
      font-size: 1em !important;
      line-height: 1.4 !important;
      text-align: left !important;
    }
    body { margin: 0 !important; padding: 0.5em !important; }
    p { margin: 0 0 0.6em 0 !important; text-indent: 0 !important; }
    h1, h2, h3, h4, h5, h6 { font-family: sans-serif !important; line-height: 1.2 !important; }
    img, svg, table { max-width: 100% !important; height: auto !important; }
    pre, code { font-family: monospace !important; white-space: pre-wrap !important; }
  '';
}
