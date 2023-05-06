#compositor and background wms only
#~/.fehbg &
feh --no-fehbg --bg-fill 'wallpaper/astolfo.png' &

# execute dwmblocks
dwmblocks & 

# set brightness as 10%
xbacklight -set 10% &

# execute dunst
dunst -config ~/.config/dunst/dunstrc &

# execute pipewire
#pipewire &

#wireplumber &

#dbus-run-session pipewire

#execute elogind
#exec elogind &

#dbus-run-session elogind

# make CapsLock behave like Ctrl:
setxkbmap -option ctrl:nocaps

# # make short-pressed Ctrl behave like Escape:
xcape -e 'Control_L=Escape'


# exec picom
picom &

# exec .Xresources
exec xrdb -merge ~/.Xresources &

# dbus
exec dbus-run-session dwm

exec dwm
