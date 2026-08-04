# configure the color of the column
addhl global/ column '%opt{textwidth}' default,rgb:0c2229
hook global WinSetOption filetype=diff %{
    require-module diff
#
    remove-highlighter window/diff
    add-highlighter window/diff group

    # Inserted lines: diffEditor.insertedLineBackground
    add-highlighter window/diff/ regex \
        '^\+[^\n]*\n' \
        0:default,rgba:57575720

    # Removed lines: diffEditor.removedLineBackground
    add-highlighter window/diff/ regex \
        '^-[^\n]*\n' \
        0:default,rgba:72727220

    # Hunk headers
    add-highlighter window/diff/ regex \
        '^@@[^\n]*@@' \
        0:rgb:575757,default

    # Added trailing whitespace
    add-highlighter window/diff/ regex \
        '^\+[^\n]*?(\h+)\n' \
        1:default,rgba:72727240
}
# For Code
face global value red
face global type yellow
face global variable green
face global module green
face global function cyan
face global string magenta
face global keyword blue
face global operator yellow
face global attribute green
face global comment cyan
face global documentation comment
face global meta magenta
face global builtin default+b

# For markup
face global title blue
face global header cyan
face global mono green
face global block magenta
face global link cyan
face global bullet cyan
face global list yellow

# builtin faces
face global Default default,default
face global PrimarySelection white,blue+fg
face global SecondarySelection black,blue+fg
face global PrimaryCursor black,white+fg
face global SecondaryCursor black,white+fg
face global PrimaryCursorEol black,cyan+fg
face global SecondaryCursorEol black,cyan+fg
face global LineNumbers default,default
face global LineNumberCursor default,default+r
face global MenuForeground white,blue
face global MenuBackground blue,white
face global MenuInfo cyan
face global Information black,yellow
face global Error black,red
face global DiagnosticError red
face global DiagnosticWarning yellow

# subtle statusline
face global StatusLine cyan,rgb:0f242a

face global StatusLineMode yellow,default
face global StatusLineInfo blue,default
face global StatusLineValue green,default
face global StatusCursor black,cyan
face global Prompt yellow,default
face global MatchingChar default,default+b
face global Whitespace default,default+fd
face global BufferPadding blue,default
