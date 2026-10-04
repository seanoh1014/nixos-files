{ ... }:

{
  # Only overrides; fbii (patched) fills in the rest from its defaults.
  xdg.configFile."fbii/config.toml".text = ''
    [typography]
    measure = 72
    line_spacing = 0
    paragraph_indent = 0
    paragraph_spacing = 1
    hyphenation = false
    justified = false

    [display]
    respect_epub_css = false
    image_protocol = "sixel"
  '';
}
