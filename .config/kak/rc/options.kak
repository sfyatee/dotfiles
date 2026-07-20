# minor color config
colorscheme default

# subtle statusline
face global StatusLine cyan,rgb:0f242a

# configure the color of the column
addhl global/ column '%opt{textwidth}' default,rgb:404040

# defaults
#set global autoinfo ""
set global ui_options terminal_assistant=off
set global disabled_hooks '.+-highlight'

# no color column by default
declare-option int textwidth 0

# all source code gets wrapped at <80 and auto-indented
hook global WinSetOption filetype=(c|cpp|gas|go|java|makefile|perl|sh) %{
    set buffer autowrap_column 79
    autowrap-enable
    set window textwidth 81
}

# makefiles and c have tabstops at 8 for portability
hook global WinSetOption filetype=(gas|makefile|c|cpp|sh) %{
    set buffer tabstop 8
    set buffer indentwidth 8
}

# email and commit messages - expand tabs, wrap at 68 for future quoting, enable spelling
hook global WinSetOption filetype=(git-commit|mail) %{
    set buffer autowrap_column 68
    autowrap-enable
    try %{ spell }
    set window textwidth 69
}

# markdown files get hard tabs, wrapped at 79 and spell checking
hook global WinSetOption filetype=markdown %{
    set buffer autowrap_column 79
    set buffer indentwidth 0
    autowrap-enable
    try %{ spell }
    set window textwidth 81
}
