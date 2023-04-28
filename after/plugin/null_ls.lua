local null_ls = require("null-ls");


null_ls.setup({
    sources = {
        null_ls.builtins.formatting.djhtml,
        null_ls.builtins.formatting.djlint,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.diagnostics.pyproject_flake8,

        null_ls.builtins.formatting.jq,
    },
});
