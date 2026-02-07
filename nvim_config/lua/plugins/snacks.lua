return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        dashboard = {
            enabled = true,
            sections = {
                { section = "header" },
                { 
                    section = "keys", 
                    gap = 1, 
                    padding = 1,
                    -- Добавляем кастомные кнопки
                    preset = {
                        keys = {
                            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
                            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
                            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
                            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.picker.files({cwd = vim.fn.stdpath('config')})" },
                            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
                            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                        },
                    },
                },
                { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 2 },
                { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
                { section = "startup" },
            },
        },
        indent = { enabled = true },
        picker = { enabled = true },
    },
}
