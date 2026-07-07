#compositor and background wms only
#~/.fehbg &
feh --no-fehbg --bg-fill 'wallpaper/astolfo.png' &

# unmute volume
#amixer set Master unmute & 

# set volume to 75%
#amixer -Ddefault set Master 75% &

# set startup volume on the same device the status script reads
amixer -Ddefault set Master 75% &

# execute dwmblocks
dwmblocks &
#pipewire &
#pipewire-pulse &
#wireplumber &

#kill -44 $(pidof dwmblocks) &

# set brightness to 10%
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

# make short-pressed Ctrl behave like Escape:
xcape -e 'Control_L=Escape'

# betterlockscreen
betterlockscreen -u "$HOME/wallpaper" --fx blur --blur 0.5 & 

# exec picom
picom &

# exec .Xresources
exec xrdb -merge ~/.Xresources &

# export env var
export _JAVA_AWT_WM_NONREPARENTING=1
export XDG_SESSION_TYPE=x11
export QT_QPA_PLATFORM=xcb

# Start Flameshot inside the same D-Bus session as DWM. Flameshot 14 uses a
# single background instance to handle subsequent `flameshot gui` commands.
exec dbus-run-session sh -c 'flameshot & exec dwm'
