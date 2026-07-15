hook global BufCreate .*aerc/.*\.conf %{
    set-option buffer filetype ini
}
