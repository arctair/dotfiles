# disable screen blanking
xset s off
xset -dpms
xset s noblank

xrdb -merge $HOME/.Xresources
exec i3
