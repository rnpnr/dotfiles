local lexers = vis.lexers

local grey0 = '#555551'

lexers.STYLE_DEFAULT           = ''
lexers.STYLE_NOTHING           = ''
lexers.STYLE_ATTRIBUTE         = 'bold'
lexers.STYLE_CLASS             = 'bold'
lexers.STYLE_COMMENT           = 'dim'
lexers.STYLE_CONSTANT          = ''
lexers.STYLE_DEFINITION        = ''
lexers.STYLE_ERROR             = 'fore:red'
lexers.STYLE_FUNCTION          = ''
lexers.STYLE_FUNCTION_BUILTIN  = lexers.STYLE_FUNCTION
lexers.STYLE_FUNCTION_METHOD   = lexers.STYLE_FUNCTION
lexers.STYLE_HEADING           = 'bold'
lexers.STYLE_KEYWORD           = 'bold'
lexers.STYLE_LABEL             = 'bold'
lexers.STYLE_NUMBER            = ''
lexers.STYLE_OPERATOR          = 'fore:yellow'
lexers.STYLE_REGEX             = ''
lexers.STYLE_STRING            = ''
lexers.STYLE_PREPROCESSOR      = 'bold'
lexers.STYLE_TAG               = ''
lexers.STYLE_TYPE              = 'bold'
lexers.STYLE_VARIABLE          = ''
lexers.STYLE_WHITESPACE        = ''
lexers.STYLE_EMBEDDED          = ''
lexers.STYLE_IDENTIFIER        = ''

lexers.STYLE_LINENUMBER        = ''
lexers.STYLE_LINENUMBER_CURSOR = 'bold'
lexers.STYLE_CURSOR            = 'back:white,fore:black'
lexers.STYLE_CURSOR_PRIMARY    = lexers.STYLE_CURSOR
lexers.STYLE_CURSOR_LINE       = 'underlined'
lexers.STYLE_COLOR_COLUMN      = 'back:' .. grey0
lexers.STYLE_SELECTION         = 'bold,back:' .. grey0
lexers.STYLE_STATUS            = 'fore:black,back:white'
lexers.STYLE_STATUS_FOCUSED    = lexers.STYLE_STATUS .. ',bold'
lexers.STYLE_SEPARATOR         = lexers.STYLE_DEFAULT
lexers.STYLE_INFO              = 'bold'
lexers.STYLE_EOF               = ''

-- diff
lexers.STYLE_ADDITION          = 'fore:green'
lexers.STYLE_CHANGE            = 'fore:yellow'
lexers.STYLE_DELETION          = 'fore:red'

-- latex, tex, texinfo
lexers.STYLE_COMMAND           = lexers.STYLE_KEYWORD
lexers.STYLE_COMMAND_SECTION   = lexers.STYLE_CLASS
lexers.STYLE_ENVIRONMENT       = lexers.STYLE_TYPE
lexers.STYLE_ENVIRONMENT_MATH  = lexers.STYLE_NUMBER

-- markdown and friends
for i = 1,6 do lexers['STYLE_HEADING_H'..i] = 'fore:cyan,bold' end
lexers.STYLE_BOLD              = 'bold'
lexers.STYLE_ITALIC            = 'italics'
