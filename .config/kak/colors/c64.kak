# C64 colorscheme for Kakoune

# Base faces
face global Default rgb:6C5EB5,rgb:352879

# Code
face global value       rgb:9AD284
face global string      rgb:9AD284
face global type        rgb:588D43
face global variable    rgb:6F4F25
face global module      rgb:6F4F25
face global function    rgb:6F4F25
face global keyword     rgb:70A4B2
face global operator    rgb:70A4B2
face global attribute   rgb:B8C76F
face global comment     rgb:6C6C6C
face global documentation rgb:6C6C6C
face global meta        rgb:6F3D86
face global builtin     rgb:B8C76F

# Markup
face global title       rgb:FFFFFF
face global header      rgb:70A4B2
face global mono        rgb:9AD284
face global block       rgb:6F3D86
face global link        rgb:70A4B2
face global bullet      rgb:B8C76F
face global list        rgb:70A4B2

# Selection
# The original Vim scheme preserved the syntax foreground in Visual mode.
face global PrimarySelection   default,rgb:000000
face global SecondarySelection default,rgb:000000

# Cursors
face global PrimaryCursor       rgb:352879,rgb:FFFFFF+fg
face global SecondaryCursor     rgb:352879,rgb:FFFFFF+fg
face global PrimaryCursorEol   rgb:352879,rgb:FFFFFF+fg
face global SecondaryCursorEol rgb:352879,rgb:FFFFFF+fg

# Menus
face global MenuForeground rgb:FFFFFF,rgb:6F3D86
face global MenuBackground rgb:FFFFFF,rgb:6C5EB5
face global MenuInfo       rgb:FFFFFF,rgb:6C5EB5

# Messages
face global Information       rgb:FFFFFF,rgb:352879
face global InlineInformation rgb:FFFFFF,rgb:352879
face global Error            rgb:FFFFFF,rgb:68372B

# Diagnostics and spelling
face global DiagnosticError   default,default,rgb:68372B+c
face global DiagnosticWarning default,default,rgb:B8C76F+c

face global SpellBad   default,default,rgb:68372B+c
face global SpellCap   default,default,rgb:68372B+c
face global SpellLocal default,default,rgb:588D43+c
face global SpellRare  default,default,rgb:588D43+c

# Status line
face global StatusLine      rgb:FFFFFF,rgb:6C5EB5
face global StatusLineMode  rgb:FFFFFF,rgb:6C5EB5
face global StatusLineInfo  rgb:FFFFFF,rgb:6C5EB5
face global StatusLineValue rgb:FFFFFF,rgb:6C5EB5
face global StatusCursor    rgb:352879,rgb:FFFFFF+fg
face global Prompt          rgb:FFFFFF,rgb:6C5EB5

# Line numbers and other UI highlighters
face global LineNumbers        rgb:000000,rgb:352879
face global LineNumberCursor   default,rgb:FFFFFF
face global LineNumbersWrapped rgb:000000,rgb:352879
face global BufferPadding       rgb:000000,rgb:352879
face global MatchingChar        rgb:352879,rgb:6F3D86
face global Whitespace          rgb:444444,rgb:352879
face global WrapMarker          rgb:444444,rgb:352879

# Diff
face global DiffAdd    rgb:352879,rgb:9AD284
face global DiffRm     rgb:352879,rgb:9A6759
face global DiffMeta   rgb:352879,rgb:B8C76F

# Extra faces corresponding to Vim's diff groups
face global DiffChange rgb:352879,rgb:B8C76F
face global DiffDelete rgb:352879,rgb:9A6759
face global DiffText   rgb:9A6759,rgb:B8C76F

# Miscellaneous syntax faces
face global underlined default,default+u
face global Underlined default,default+u
face global ignore     rgb:959595,rgb:352879
face global Ignore     rgb:959595,rgb:352879
face global error      rgb:000000,rgb:9A6759
face global todo       rgb:352879,rgb:6C6C6C
