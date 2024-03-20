s/$/\n/
s/ /~/g # NO-BREAK SPACE
s/…/~\\dots{}/g
s/-/‐/g # HYPHEN-MINUS -> HYPHEN
s/–/--/g # EN DASH
s/—/---/g # EM DASH
s/„/``/g # DOUBLE LOW-9 QUOTATION MARK
s/“/\x27\x27/g # LEFT DOUBLE QUOTATION MARK
s/”/\x27\x27/g # RIGHT DOUBLE QUOTATION MARK
s/\xCC\x81//g # COMBINING ACUTE ACCENT (ударение)
