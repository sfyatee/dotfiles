local lexers = vis.lexers

--lexers.STYLE_CONSTANT          = 'fore:black,underlined'
lexers.STYLE_KEYWORD           = 'fore:white,bold'
lexers.STYLE_NUMBER            = 'fore:white,underlined'
lexers.STYLE_OPERATOR          = 'fore:white'
lexers.STYLE_STRING            = 'fore:white,underlined'
lexers.STYLE_PREPROCESSOR      = 'underlined'

lexers.STYLE_STATUS            = 'fore:#0c0a0e,back:#fffaf3'
lexers.STYLE_STATUS_FOCUSED    = lexers.STYLE_STATUS .. ',bold'
