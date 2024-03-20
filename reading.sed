s/$/\n/
s/ /~/g # NO-BREAK SPACE
s/…/~\\dots{}/g
s/-/‐/g # HYPHEN-MINUS -> HYPHEN
s/–/--/g # EN DASH
s/—/---/g # EM DASH
s/„/``/g
s/“/\x27\x27/g
s/”/\x27\x27/g
s/\xCC\x81//g # COMBINING ACUTE ACCENT
