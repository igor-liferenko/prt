s/\r$//
s/$/\n/
s/ / /g # NO-BREAK SPACE -> SPACE
s/…/~\\dots{}/g
s/-/^^ff/g # HYPHEN (not MINUS)
s/–/--/g # EN DASH
s/—/---/g # EM DASH
# s/\xCC\x81//g # COMBINING ACUTE ACCENT
