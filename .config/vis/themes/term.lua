local lexers = vis.lexers

local grey0 = '#555551'

local comment  = 'dim'
local constant = 'fore:blue'
local keyword  = 'bold'
local operator = 'fore:yellow'

lexers.STYLE_DEFAULT           = ''
lexers.STYLE_NOTHING           = ''
lexers.STYLE_ATTRIBUTE         = keyword
lexers.STYLE_CLASS             = keyword
lexers.STYLE_COMMENT           = comment
lexers.STYLE_CONSTANT          = constant
lexers.STYLE_DEFINITION        = ''
lexers.STYLE_ERROR             = 'fore:red'
lexers.STYLE_FUNCTION          = ''
lexers.STYLE_FUNCTION_BUILTIN  = lexers.STYLE_FUNCTION
lexers.STYLE_FUNCTION_METHOD   = lexers.STYLE_FUNCTION
lexers.STYLE_HEADING           = keyword
lexers.STYLE_KEYWORD           = keyword
lexers.STYLE_LABEL             = keyword
lexers.STYLE_NUMBER            = constant
lexers.STYLE_OPERATOR          = operator
lexers.STYLE_REGEX             = ''
lexers.STYLE_STRING            = constant
lexers.STYLE_PREPROCESSOR      = keyword
lexers.STYLE_TAG               = ''
lexers.STYLE_TYPE              = ''
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
