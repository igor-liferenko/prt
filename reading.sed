# s/$/\n/
s/ / /g # NO-BREAK SPACE -> SPACE
s/\r$//
s/…/~\\dots{}/g
s/-/‐/g # HYPHEN-MINUS -> HYPHEN
s/–/--/g # EN DASH
s/—/---/g # EM DASH
# s/\xCC\x81//g # COMBINING ACUTE ACCENT
