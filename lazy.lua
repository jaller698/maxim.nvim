return {
	"jaller698/maxim.nvim",
	dependencies = {
		"folke/snacks.nvim",
	},
	opts = {
		board = "FTHR_RevA",
		baudrate = 115200,
		serial_command = "picocom",
	},
	keys = {
		{ "<leader>M", desc = "MAX78000" },
		{
			"<leader>Mb",
			function()
				require("maxim").build()
			end,
			desc = "MAX78000: Build",
		},
		{
			"<leader>Mf",
			function()
				require("maxim").flash()
			end,
			desc = "MAX78000: Flash",
		},
		{
			"<leader>Mm",
			function()
				require("maxim").pick_port("monitor")
			end,
			desc = "MAX78000: Pick & Monitor",
		},
		{
			"<leader>Mc",
			function()
				require("maxim").clean()
			end,
			desc = "MAX78000: Clean",
		},
		{
			"<leader>Mi",
			function()
				require("maxim").info()
			end,
			desc = "MAX78000: Info",
		},
	},
}
