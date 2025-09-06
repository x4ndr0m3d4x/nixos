{ config, pkgs, caelestia-shell, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ashley";
  home.homeDirectory = "/home/ashley";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ashley/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Ashley Fae";
    userEmail = "ashley.fae.uwu@gmail.com";
  };

  programs.foot = {
      enable = true;
      settings = {
          main = {
              letter-spacing = "0";
              font = "monospace:size=12";
              dpi-aware = "no";
              pad = "10x10";
              bold-text-in-bright = "no";
              gamma-correct-blending = "no";
          };

          scrollback.lines = "10000";

          cursor = {
              style = "beam";
              beam-thickness = "1.5";
          };

          colors.alpha = "0.78";
      };
  };
  programs.zellij.enable = true;

  programs.caelestia = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
      environment = [];
    };
    settings = {
      bar.status = {
        showBattery = false;
      };
      paths.wallpaperDir = "~/wallpapers";
    };
    cli = {
      enable = true;
    };
  };

  programs.fastfetch.enable = true;

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    withNodeJs = true;
    withPython3 = false;
    withRuby = false;

    extraPackages = [
        pkgs.rust-analyzer
        pkgs.clang-tools
        pkgs.clang
        pkgs.tailwindcss-language-server
        pkgs.vscode-langservers-extracted
        pkgs.typescript-language-server
        pkgs.lua-language-server
        pkgs.svelte-language-server
        pkgs.pyright
        pkgs.tinymist
        pkgs.harper
    ];

    extraLuaConfig = ''
        _G.MyStatusColumn = function()
        local lnum = vim.v.lnum -- The line number to draw
        local bufnr = vim.api.nvim_get_current_buf()
        local placed = vim.fn.sign_getplaced(bufnr, { lnum = lnum, group = '*' })
        local has_breakpoint = false
        local has_stopped = false
        local is_virtual = vim.v.virtnum ~= 0 -- Check if this is a virtual line (wrapped, virtual diagnostic lines)

        -- If this is a wrapped line, return empty space to maintain alignment
        if is_virtual then
            return " "
                end

                for _, group in ipairs(placed) do
                    for _, sign in ipairs(group.signs) do
                        if sign.name == "DapStopped" then
                            has_stopped = true
                                break
                                elseif sign.name:match("DapBreakpoint") then
                                has_breakpoint = true
                                end
                                end
                                if has_stopped then break end
                                    end

                                        local content = ""

                                        if has_stopped then
                                            if lnum == vim.fn.line('.') then
                                                content = content .. "%#DapStoppedCurrent#"
                                            else
                                                content = content .. "%#DapStopped#" -- Debugger stopped on current line has priority
                                                    end

                                                    content = content .. "→   " -- Debugger stopped on current line has priority
                                                    elseif has_breakpoint then
                                                    if lnum == vim.fn.line('.') then
                                                        content = content .. "%#BreakpointCurrent#"
                                                    else
                                                        content = content .. "%#Breakpoint#"
                                                            end

                                                            content = content .. "●   "
                                        else
                                            if lnum == vim.fn.line('.') then
                                                content = "%#Bold#" .. string.format("%-4s", tostring(lnum))
                                            else
                                                content = "%#CursorColumn#" .. string.format("%4s", tostring(lnum))
                                                    end
                                                    end

                                                    return content .. "%#CursorBorder#│"
                                                    end

        --- DISABLE DEFAULT PROVIDERS ---
        vim.g.loaded_perl_provider = 0

        --- LEADER ---
        vim.g.mapleader = " "
        vim.g.maplocalleader = "\\"

        --- STATUSCOLUMN ---
        vim.o.statuscolumn = "%!v:lua.MyStatusColumn()"

        --- TAB ---
        vim.opt.tabstop = 4      -- A tab counts as 4 spaces
        vim.opt.shiftwidth = 4   -- How many spaces for each level of autoindent
        vim.opt.expandtab = true -- When pressing <Tab> in insert mode, insert the appropriate amount of spaces instead

        --- STATUS LINE ---
        vim.opt.cmdheight = 0  -- Effectively hide the cmd line (replaces statusline while in command mode)
        vim.opt.laststatus = 3 -- Always show a status line, but only in the last window

        --- CURSOR ---
        vim.opt.scrolloff = 5     -- How many lines (at least) to keep above or below the cursor
        vim.opt.sidescrolloff = 5 -- How many columns (at least) to keep to the left or to the right of the cursor
        vim.opt.cursorline = true -- Highlight the line the cursor is currently at

        --- MISC ---
        vim.opt.smartcase = true          -- Respect case when searching using uppercase characters, ignore otherwise
        vim.opt.termguicolors = true      -- Enabled 24-bit RGB color
        vim.opt.wrap = false              -- Whether to wrap lines longer than the width of the window
        vim.opt.selection = "old"         -- Do not allow including the last character while selecting
        vim.opt.clipboard = "unnamedplus" -- Use system clipboard for yank/paste
        vim.opt.colorcolumn = "80"        -- A highlighted column at 80 chars

        --- LINE NUMBER ---
        vim.opt.number = true -- Show the line numbers in front of each line

        --- DIAGNOSTICS ---
        vim.diagnostic.config({
            update_in_insert = true, -- Update diagnostics when in insert mode
            virtual_text = false,    -- Do not show virtual text (diagnostics at the end of the line)
            virtual_lines = false,   -- Do not show virtual lines (under a given line)
            underline = true,        -- Underline a given token for diagnostics
            signs = {                -- Show line diagnostics by coloring the line number
                text = {
                    [vim.diagnostic.severity.ERROR] = "",
                    [vim.diagnostic.severity.WARN] = "",
                    [vim.diagnostic.severity.HINT] = "",
                    [vim.diagnostic.severity.INFO] = "",
                },
                numhl = {
                    [vim.diagnostic.severity.WARN] = "WarningMsg",
                    [vim.diagnostic.severity.ERROR] = "ErrorMsg",
                    [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
                    [vim.diagnostic.severity.HINT] = "DiagnosticHint",
                }
            },
            severity_sort = true
        })

        -- Only show virtual lines on keybind and hide it right after
        local function show_line_virtual_diagnostics()
        -- Save the current diagnostic settings so we can revert
        local old_config = vim.deepcopy(vim.diagnostic.config())

        -- Turn on virtual_lines just for the current line
        vim.diagnostic.config({
                virtual_lines = { current_line = true },
                })

        -- Create an autocmd group to clear these settings on cursor move
        local group = vim.api.nvim_create_augroup("HideLineVirtualDiagnostics", { clear = true })
        vim.api.nvim_create_autocmd("CursorMoved", {
                group = group,
                once = true,
                callback = function()
                -- Restore the old diagnostic config
                vim.diagnostic.config(old_config)
                -- Delete the group to clean up
                vim.api.nvim_del_augroup_by_id(group)
                end,
                })
        end

        vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
                callback = function(ev)
                    local client = vim.lsp.get_client_by_id(ev.data.client_id)
                    if not client then return end

                    ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
                    if client.supports_method("textDocument/formatting") then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = ev.buf,
                            callback = function()
                            vim.lsp.buf.format({ bufnr = ev.buf, id = client.id })
                            end
                            })
                    end

                    -- Enable the LSP
                    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf)
                    -- Refresh code lens
                    vim.lsp.codelens.refresh()
                    end,
            })

        vim.lsp.config('*', { root_markers = { '.git' } })

        vim.lsp.config('clangd', {
            cmd = { "clangd" },
            filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
            root_markers = {
                ".clangd",
                ".clang-tidy",
                ".clang-format",
                "compile_commands.json",
                "compile_flags.txt",
                "configure.ac",
                ".git",
                "src"
            },
            capabilities = {
                textDocument = {
                    completion = {
                        editsNearCursor = true
                    }
                },
                offsetEncoding = { "utf-8" }
            }
        })

        vim.lsp.config('harper-ls', {
            cmd = { "harper-ls", "--stdio" },
            filetypes = { "c", "cpp", "cs", "gitcommit", "go", "html", "java", "javascript", "lua", "markdown", "nix", "plaintext", "python", "ruby", "rust", "swift", "tex", "text", "toml", "typescript", "typescriptreact", "haskell", "cmake", "typst", "php", "dart" },
            root_markers = { ".git" },
            single_file_support = true
        })

        vim.lsp.config('html', {
            cmd = { "vscode-html-language-server", "--stdio" },
            filetypes = { "html" },
            root_markers = { ".git", "package.json", "node_modules" },
            init_options = {
                provideFormatter = true,
                embeddedLanguages = { css = true, javascript = true },
                configurationSection = { "html", "css", "javascript" }
            }
        })

        vim.lsp.config('lua', {
            cmd = { "lua-language-server" },
            root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
            filetypes = { "lua" },
            settings = {
                Lua = {
                    hint = { enable = true },
                    runtime = { version = "LuaJIT" },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME,
                            "''\${3rd}/luv/library",
                            "''\${3rd}/busted/library",
                        },
                    },
                    completion = { callSnippet = "Replace" },
                },
            },
        })

        vim.lsp.config('pyright', {
            cmd = { "pyright-langserver", "--stdio" },
            filetypes = { "python" },
            root_markers = { ".git", "requirements.txt", "setup.py", "setup.cfg", "venv" },
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = 'openFilesOnly'
                    }
                }
            }
        })

        vim.lsp.config('rust-analyzer', {
            cmd = { "rust-analyzer" },
            filetypes = { "rust" },
            root_markers = { ".git", "Cargo.toml" }
        })

        vim.lsp.config('svelte', {
            cmd = { "svelteserver", "--stdio" },
            filetypes = { "svelte" },
            root_markers = { ".git", "package.json" }
        })

        vim.lsp.config('tailwindcss', {
            cmd = { "tailwindcss-language-server", "--stdio" },
            filetypes = { "html", "markdown", "css", "less", "postcss", "sass", "scss", "javascript", "typescript", "svelte" },
            root_markers = { ".git", "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.ts", "node_modules", "package.json" }
        })

        vim.lsp.config('tinymist', {
            cmd = { "tinymist" },
            filetypes = { "typst" },
            root_markers = { "thesis.typ", ".git" }
        })

        vim.lsp.config('typescript', {
            cmd = { "typescript-language-server", "--stdio" },
            filetypes = { "javascript", "typescript" },
            root_markers = { ".git", "package.json", "tsconfig.json", "jsconfig.json" },
            init_options = {
                hostInfo = "neovim"
            }
        })

            vim.lsp.enable({
                    "rust-analyzer",
                    "clangd",
                    "tailwindcss",
                    "html",
                    "typescript",
                    "lua",
                    "svelte",
                    "pyright",
                    "tinymist",
                    "harper-ls",
                    })

        local map = vim.keymap.set

        --- QOL ---
        map("n", "<Esc>", "<cmd>noh<CR>", { desc = "De-highlight search results", noremap = true, silent = true })
        map("n", "L", show_line_virtual_diagnostics, { desc = "Show virtual line diagnotics", noremap = true, silent = true })
        map({ "n", "i" }, "<D-space>", "<Nop>", { noremap = true, silent = true })

        --- WINDOW NAVIGATION ---
        map("n", "<C-h>", "<C-w>h", { desc = "Cursor to window left", noremap = true, silent = true })
        map("n", "<C-j>", "<C-w>j", { desc = "Cursor to window down", noremap = true, silent = true })
        map("n", "<C-k>", "<C-w>k", { desc = "Cursor to window up", noremap = true, silent = true })
        map("n", "<C-l>", "<C-w>l", { desc = "Cursor to window right", noremap = true, silent = true })

        --- PICKERS ---
        map("n", "<C-n>", function() require('mini.files').open() end, { desc = "Open file explorer", noremap = true, silent = true })
        map("n", "<leader>o", function() Snacks.picker.buffers({ focus = "list" }) end,
                { desc = "Browse open buffers", noremap = true, silent = true })
        map("n", "<leader>g", function() Snacks.picker.grep({ focus = "list" }) end,
                { desc = "Grep", noremap = true, silent = true })
        map("n", "<leader>f", function() Snacks.picker.files({ focus = "list" }) end,
                { desc = "Files Picker", noremap = true, silent = true })

        --- LSP ---
        map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration", noremap = true, silent = true })
        map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", noremap = true, silent = true })
        map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation", noremap = true, silent = true })
        map("n", "gR", vim.lsp.buf.references, { desc = "Go to references", noremap = true, silent = true })
        map("n", "ga", vim.lsp.buf.code_action, { desc = "Code action", noremap = true, silent = true })
        map("n", "gr", vim.lsp.buf.rename, { desc = "Rename Symbol", noremap = true, silent = true })
        map("n", "<leader>ih", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
                { desc = "Toggle inlay hints", noremap = true, silent = true })

        --- DEBUG ---
        -- map("n", "<leader>ds", require("dap").continue, { desc = "Start debugging", noremap = true, silent = true })
        -- map("n", "<leader>do", require("dap").step_over, { desc = "Debug - step over", noremap = true, silent = true })
        -- map("n", "<leader>di", require("dap").step_into, { desc = "Debug - step into", noremap = true, silent = true })
        -- map("n", "<leader>dt", require("dap").step_out, { desc = "Debug - step out", noremap = true, silent = true })
        -- map("n", "<leader>db", require("dap").step_back, { desc = "Debug - step back", noremap = true, silent = true })
        -- map("n", "<leader>dc", require("dap").run_to_cursor, { desc = "Debug - run to cursor", noremap = true, silent = true })

        local colors = {
            Normal = { fg = "#E0E2EB", bg = "#0F161F" },
            BlinkCmpDoc = { bg = "#172230" },
            BlinkCmpDocBorder = { bg = "#172230" },
            BlinkCmpDocSeparator = { bg = "#172230" },
            BlinkCmpSignatureHelp = { bg = "#172230" },
            Bold = { bold = true },
            Boolean = { fg = "#F28F0D" },
            Breakpoint = { fg = "#FF4D4D", bg = "#0C1118" },
            BreakpointCurrent = { fg = "#FF4D4D", bg = "#283A53" },
            Character = { fg = "#FCAC8D" },
            ColorColumn = { bg = "#2B1717" },
            Comment = { fg = "#656A81" },
            Constant = { fg = "#F28F0D" },
            CurSearch = { fg = "#0F161F", bg = "#F7E7A1" },
            CursorBorder = { fg = "#E0E2EB", bg = "#0D131C" },
            CursorColumn = { bg = "#0C1118" },
            CursorLine = { bg = "#1B2737" },
            CursorLineNr = { bg = "#283A53" },
            DapStopped = { fg = "#FF4D4D", bg = "#0C1118" },
            DapStoppedCurrent = { fg = "#FF4D4D", bg = "#283A53" },
            Delimiter = { fg = "#B9BDD0" },
            DiagnosticError = { fg = "#FF4D4D" },
            DiagnosticFloatingError = { fg = "#FF4D4D" },
            DiagnosticFloatingHint = { fg = "#67E4A8" },
            DiagnosticFloatingInfo = { fg = "#8FFDFF" },
            DiagnosticFloatingWarn = { fg = "#FFE866" },
            DiagnosticHint = { fg = "#67E4A8" },
            DiagnosticInfo = { fg = "#8FFDFF" },
            DiagnosticSignError = { fg = "#FF4D4D" },
            DiagnosticSignHint = { fg = "#67E4A8" },
            DiagnosticSignInfo = { fg = "#8FFDFF" },
            DiagnosticSignWarn = { fg = "#FFE866" },
            DiagnosticUnderlineError = { sp = "#FF4D4D", undercurl = true },
            DiagnosticUnderlineHint = { sp = "#67E4A8", undercurl = true },
            DiagnosticUnderlineInfo = { sp = "#8FFDFF", undercurl = true },
            DiagnosticUnderlineWarn = { sp = "#FFE866", undercurl = true },
            DiagnosticUnnecessary = { fg = "#81869C" },
            DiagnosticVirtualTextError = { fg = "#FF4D4D" },
            DiagnosticVirtualTextHint = { fg = "#67E4A8" },
            DiagnosticVirtualTextInfo = { fg = "#8FFDFF" },
            DiagnosticVirtualTextWarn = { fg = "#FFE866" },
            DiagnosticWarn = { fg = "#FFE866" },
            DiffAdd = { fg = "#0F161F", bg = "#67E4A8" },
            DiffChange = { fg = "#0F161F", bg = "#8FFDFF" },
            DiffDelete = { fg = "#0F161F", bg = "#FF4D4D" },
            DiffText = { fg = "#0F161F", bg = "#8FFDFF" },
            Directory = { fg = "#6ABFFB" },
            Float = { fg = "#F28F0D" },
            FloatBorder = { fg = "#E0E2EB", bg = "#0F161F" },
            Function = { fg = "#33AAFF" },
            Identifier = { fg = "#99CFFF" },
            IncSearch = { fg = "#0F161F", bg = "#F7E7A1" },
            LineNr = { fg = "#839FC3" },
            LspInlayHint = { fg = "#B2B4BD", bg = "#1B2737" },
            LspSignatureActiveParameter = { fg = "#E0E2EB", bg = "#3B444E" },
            MiniFilesBorder = { fg = "#E0E2EB" },
            MiniFilesBorderModified = { fg = "#FFE866" },
            MiniFilesNormal = { bg = "#0F161F" },
            MiniFilesTitle = { fg = "#E0E2EB" },
            MiniFilesTitleFocused = { fg = "#E0E2EB", bold = true },
            MiniIndentscopeSymbol = { fg = "#727AA1" },
            MiniJump2dSpot = { fg = "#0F161F", bg = "#E0E2EB" },
            MiniNotifyBorder = { fg = "#E0E2EB", bg = "#0F161F" },
            MiniNotifyNormal = { fg = "#E0E2EB", bg = "#0F161F" },
            MiniNotifyTitle = { fg = "#E0E2EB", bg = "#0F161F", bold = true },
            NormalFloat = { fg = "#E0E2EB", bg = "#172230" },
            Number = { fg = "#F28F0D" },
            Operator = { fg = "#B9BDD0" },
            PmenuSbar = { bg = "#080C11" },
            PmenuSel = { fg = "#E0E2EB", bg = "#3C587C" },
            PmenuThumb = { bg = "#26384F" },
            Search = { fg = "#0F161F", bg = "#ECC413" },
            SnacksPicker = { fg = "#E0E2EB", bg = "#0F161F" },
            Special = { fg = "#B9BDD0" },
            ["@lsp.type.formatSpecifier"] = { link = "Special" },
            Statement = { fg = "#FF4DB5" },
            StatusLine = { fg = "#E0E2EB", bg = "#080C11" },
            StatusLineNC = { fg = "#0F161F", bg = "#E0E2EB" },
            String = { fg = "#FB8151" },
            Substitute = { fg = "#0F161F", bg = "#ECC413" },
            TodoBgFIX = { fg = "#0F161F", bg = "#FF4D4D", bold = true },
            TodoBgNOTE = { fg = "#0F161F", bg = "#1EA7A9", bold = true },
            TodoBgTEST = { fg = "#0F161F", bg = "#67E4A8", bold = true },
            TodoBgTODO = { fg = "#0F161F", bg = "#8FFDFF", bold = true },
            TodoBgWARN = { fg = "#0F161F", bg = "#FFE866", bold = true },
            TodoFgFIX = { fg = "#FF4D4D" },
            TodoFgNOTE = { fg = "#1EA7A9" },
            TodoFgTEST = { fg = "#67E4A8" },
            TodoFgTODO = { fg = "#8FFDFF" },
            TodoFgWARN = {},
            Type = { fg = "#14B82A" },
            Underlined = { underline = true },
            Visual = { fg = "#E0E2EB", bg = "#2D425D" },
            WhichKey = { fg = "#E0E2EB", bg = "#0F161F" },
            WhichKeyDesc = { fg = "#6ABFFB", bg = "#0F161F" },
            WhichKeyGroup = { fg = "#FF4DB5", bg = "#0F161F" },
            WhichKeyNormal = { fg = "#E0E2EB", bg = "#0F161F" },
            ["@constant.builtin"] = { fg = "#F28F0D" },
            ["@constant.macro"] = { fg = "#33AAFF" },
            ["@float"] = { fg = "#F28F0D" },
            ["@keyword.directive"] = { fg = "#F3AAD5" },
            ["@label"] = { fg = "#F3AAD5" },
            ["@lsp.type.builtinType"] = { fg = "#14B82A" },
            ["@lsp.type.decorator"] = { fg = "#EABA7B" },
            ["@lsp.type.enumMember"] = { fg = "#17D375" },
            ["@lsp.type.interface"] = { fg = "#A0E4A9" },
            ["@lsp.type.namespace"] = { fg = "#EABA7B" },
            ["@lsp.type.selfKeyword"] = { fg = "#FF7070" },
            ["@macro"] = { fg = "#33AAFF" },
            ["@tag"] = { fg = "#FF4DB5" },
            ["@tag.attribute"] = { fg = "#99D5FF" },
            ["@tag.delimiter"] = { fg = "#99CFFF" },
        }

        vim.cmd("highlight clear")
            vim.cmd("set t_Co=256")
            vim.cmd("let g:colors_name='my_theme'")

            for group, attrs in pairs(colors) do
                vim.api.nvim_set_hl(0, group, attrs)
                    end
        '';

    plugins = [
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [ 
            p.bash p.c p.c_sharp p.cmake p.cpp p.css p.gdscript p.gdshader
            p.git_config p.git_rebase p.gitattributes p.gitcommit p.gitignore
            p. html p.json p.lua p.markdown p.markdown_inline p.python p.rust
            p.scss p.sql p.svelte p.toml p.typescript p.typst p.vimdoc p.qmljs
        ]))

        pkgs.vimPlugins.friendly-snippets
        pkgs.vimPlugins.blink-cmp-dictionary
        pkgs.vimPlugins.plenary-nvim
        {
            plugin = pkgs.vimPlugins.blink-cmp;
            type = "lua";
            config = ''
                require('blink.cmp').setup({
                    appearance = {
                        use_nvim_cmp_as_default = true,
                        nerd_font_variant = 'mono'
                    },
                    signature = { enabled = true },
                    completion = {
                        keyword = {
                            range = "full"
                        },
                        list = {
                            selection = {
                                preselect = true,
                                auto_insert = false
                            }
                        },
                        documentation = {
                            auto_show = true
                        },
                        menu = {
                            draw = {
                                gap = 1,
                                columns = { { "kind_icon" }, { "label" }, { "kind" } }
                            }
                        }
                    }
                })
            '';
        }

        {
            plugin = pkgs.vimPlugins.fidget-nvim;
            type = "lua";
            config = ''
                require('fidget').setup()
            '';
        }

        {
            plugin = pkgs.vimPlugins.mini-nvim;
            type = "lua";
            config = ''
                require('mini.git').setup()  -- Required for mini.statusline
                require('mini.diff').setup({ -- Required for mini.statusline
                    view = {
                        style = "sign",
                        signs = { add = "", change = "", delete= "" } -- Do not display the signcolumn
                    },
                    delay = {
                        text_change = math.huge -- Do not update to increase performance
                    }
                })

                require('mini.statusline').setup()
                require('mini.icons').setup()
                require('mini.files').setup()       -- File explorer
                require('mini.indentscope').setup({ -- Visualize current scope
                    draw = {                        -- Do not animate and display the line immediately
                        delay = 0,
                        animation = require('mini.indentscope').gen_animation.none()
                    },
                    symbol = '│'
                })
                require('mini.comment').setup({ -- Autocomment line and selection
                    mappings = {
                        comment_line = "<leader>/",
                        comment_visual = "<leader>/"
                    }
                })
                require('mini.pairs').setup()    -- Autopairs
                require('mini.ai').setup()       -- Selection around/inside
                require('mini.move').setup()     -- Move line and selection
                require('mini.surround').setup() -- Surround textobjects
                require('mini.jump2d').setup()   -- Jump to any visible position using 2 chars
            '';
        }

        {
            plugin = pkgs.vimPlugins.nvim-colorizer-lua;
            type = "lua";
            config = ''
                require('colorizer').setup({
                    filetypes = { "html", "markdown", "css", "less", "postcss", "sass", "scss", "javascript", "typescript", "svelte" },
                    user_default_options = {
                        css = true,
                        tailwind = "both",
                        mode = "virtualtext",
                        virtualtext_inline = "before",
                        tailwind_opts = {
                            update_names = true -- Enabled highlight custom colors from tailwind.config.ts
                        }
                    }
                })
            '';
        }

        {
            plugin = pkgs.vimPlugins.roslyn-nvim;
            type = "lua";
            config = ''
                require('roslyn').setup({
                    config = {
                        settings = {
                            ["csharp|background_analysis"] = {
                                background_analysis = {
                                    dotnet_analyzer_diagnostics_scope = "fullSolution",
                                    dotnet_compiler_diagnostics_scope = "fullSolution"
                                }
                            },

                            ["csharp|code_lens"] = {
                                dotnet_enable_references_code_lens = true
                            },

                            ["csharp|completion"] = {
                                dotnet_show_completion_items_from_unimported_namespaces = true
                            },

                            ["csharp|inlay_hints"] = {
                                csharp_enable_inlay_hints_for_implicit_object_creation = true,
                                csharp_enable_inlay_hints_for_implicit_variable_types = true,
                                csharp_enable_inlay_hints_for_lambda_parameter_types = true,
                                csharp_enable_inlay_hints_for_types = true,
                                dotnet_enable_inlay_hints_for_indexer_parameters = true,
                                dotnet_enable_inlay_hints_for_literal_parameters = true,
                                dotnet_enable_inlay_hints_for_object_creation_parameters = true,
                                dotnet_enable_inlay_hints_for_other_parameters = true,
                                dotnet_enable_inlay_hints_for_parameters = true,
                                dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
                                dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
                                dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true
                            }
                        }
                    }
                })
            '';
        }
        
        {
            plugin = pkgs.vimPlugins.snacks-nvim;
            type = "lua";
            config = ''
                require('snacks').setup({
                    picker = {}, -- Telescope alternative
                    input = {}   -- Prettier input field
                })
            '';
        }

        {
            plugin = pkgs.vimPlugins.todo-comments-nvim;
            type = "lua";
            config = ''
                require('todo-comments').setup({
                    signs = false
                })
            '';
        }
        
        pkgs.vimPlugins.typst-preview-nvim
        pkgs.vimPlugins.vim-wakatime

        {
            plugin = pkgs.vimPlugins.which-key-nvim;
            type = "lua";
            config = ''
                require('which-key').setup({
                    preset = "helix", -- Display a small window in the lower right corner
                    delay = 500       -- 0.5s delay
                })
            '';
        }
        
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
        "$mod" = "SUPER";
        "$terminal" = "foot";
        "$browser" = "zen";

        env = [
            "XCURSOR_SIZE, 24"
                "HYPRCURSOR_SIZE, 24"
        ];

        monitor = [
            "DP-1, 1920x1080@144, 0x0, 1"
                "DP-2, 1920x1080@60, -1920x0, 1"
                "HDMI-A-1, 1920x1080@60, 1920x0, 1"
        ];

        general = {
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
        };

        decoration = {
            rounding = 10;

            blur = {
                enabled = true;
                xray = false;
                special = false;
                ignore_opacity = true;
                new_optimizations = true;
                popups = true;
                input_methods = true;
                size = 8;
                passes = 2;
            };

            shadow = {
                enabled = true;
                range = 20;
                render_power = 3;
            };
        };

        animations = {
            enabled = true;
        };

        bindm = [
            "$mod, mouse:272, movewindow"
        ];

        bind = [
            "$mod, T, exec, $terminal"
                "$mod, B, exec, $browser"
                "$mod, Q, killactive"

                "$mod, SUPER_L, exec, caelestia-shell ipc call drawers toggle launcher"
                "$mod, L, exec, caelestia-shell ipc call lock lock"
                "Ctrl+Alt, Delete, exec, caelestia-shell ipc call drawers toggle session"

                "$mod, 1, workspace, 1"
                "$mod, 2, workspace, 2"
                "$mod, 3, workspace, 3"
                "$mod, 4, workspace, 4"
                "$mod, 5, workspace, 5"
                "$mod, 6, workspace, 6"
                "$mod, 7, workspace, 7"
                "$mod, 8, workspace, 8"
                "$mod, 9, workspace, 9"

                "$mod+Shift, 1, movetoworkspacesilent, 1"
                "$mod+Shift, 2, movetoworkspacesilent, 2"
                "$mod+Shift, 3, movetoworkspacesilent, 3"
                "$mod+Shift, 4, movetoworkspacesilent, 4"
                "$mod+Shift, 5, movetoworkspacesilent, 5"
                "$mod+Shift, 6, movetoworkspacesilent, 6"
                "$mod+Shift, 7, movetoworkspacesilent, 7"
                "$mod+Shift, 8, movetoworkspacesilent, 8"
                "$mod+Shift, 9, movetoworkspacesilent, 9"
                ];
    };
  };
}
