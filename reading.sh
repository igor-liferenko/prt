iconv -f UTF-8 -t UCS-2 $1 >/dev/null 2>&1 || { echo File is not UTF-8; exit 1; }
sed -i 's/\r$//' $1
sed -i 's/$/\n/' $1
sed -i 's/ / /g' $1 # NO-BREAK SPACE -> SPACE
sed -i 's/…/~\\dots{}/g' $1
sed -i 's/-/^^ff/g' $1 # HYPHEN (not MINUS)
sed -i 's/–/--/g' $1 # EN DASH
sed -i 's/—/---/g' $1 # EM DASH
# sed -i 's/\xCC\x81//g' $1 # COMBINING ACUTE ACCENT
{ rm $1; ( echo % begin reading.tex; cat ~/prt/reading.tex; echo % end reading.tex; cat ) >$1; } <$1
