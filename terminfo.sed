# infocmp -1 $TERM | sed -f ~/prt/terminfo.sed | tic -
s/\\E\[?1049h/\\E7\\E[?47h/
s/\\E\[?1049l/\\E[2J\\E[?47l\\E8/
