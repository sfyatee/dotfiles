hook global WinSetOption filetype=go %{
    set buffer lsp_servers %{
        [gopls]
        root_globs = ["Gopkg.toml", "go.mod", ".git", ".hg"]
    }
    lsp-enable-window
    lsp-semantic-tokens-enable
}
