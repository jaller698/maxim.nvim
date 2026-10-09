local M = {}

local Snacks = require("snacks")

M.options = {
	board = "FTHR_RevA",
	baudrate = 115200,
	serial_command = "picocom",
	make_command = "make",
}

local function terminal(command, title)
	Snacks.terminal.open(command, {
		win = {
			width = 0.7,
			height = 0.7,
			border = "single",
			title = title,
			title_pos = "center",
		},
	})
end

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", M.options, opts or {})
end

function M.list_ports()
	local ports = {}
	local scandir = vim.uv.fs_scandir("/dev")

	if not scandir then
		return ports
	end

	while true do
		local name = vim.uv.fs_scandir_next(scandir)

		if not name then
			break
		end

		if name:match("^ttyACM%d+$") or name:match("^ttyUSB%d+$") then
			table.insert(ports, {
				port = "/dev/" .. name,
			})
		end
	end

	table.sort(ports, function(a, b)
		return a.port < b.port
	end)

	return ports
end

function M.build()
	local opts = M.options
	terminal(string.format("%s BOARD=%s", opts.make_command, opts.board), "MAX78000 Build")
end

function M.flash()
	local opts = M.options
	terminal(string.format("%s BOARD=%s flash.openocd", opts.make_command, opts.board), "MAX78000 Flash")
end

function M.clean()
	local opts = M.options
	terminal(string.format("%s BOARD=%s clean", opts.make_command, opts.board), "MAX78000 Clean")
end

function M.monitor(port)
	local opts = M.options
	terminal(
		string.format("%s -b %d %s", opts.serial_command, opts.baudrate, vim.fn.shellescape(port)),
		"MAX78000 Serial Monitor"
	)
end

function M.pick_port(action)
	Snacks.picker.pick({
		prompt = "Select MAX78000 serial port",
		finder = M.list_ports,
		format = function(item)
			return { { item.port } }
		end,
		confirm = function(picker, item)
			picker:close()

			if action == "monitor" then
				M.monitor(item.port)
			end
		end,
	})
end

function M.info()
	local messages = {}
	local opts = M.options

	local function check(condition, label)
		table.insert(messages, (condition and "✓ " or "✗ ") .. label)
	end

	check(vim.fn.executable(opts.make_command) == 1, opts.make_command)
	check(vim.fn.executable(opts.serial_command) == 1, opts.serial_command)
	check(vim.env.MAXIM_PATH ~= nil, "MAXIM_PATH is set")
	check(#M.list_ports() > 0, "MAX78000 serial port detected")

	table.insert(messages, "Board: " .. opts.board)
	table.insert(messages, "Baudrate: " .. opts.baudrate)

	vim.notify(table.concat(messages, "\n"), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("MAXBuild", function()
	M.build()
end, {})

vim.api.nvim_create_user_command("MAXFlash", function()
	M.flash()
end, {})

vim.api.nvim_create_user_command("MAXMonitor", function()
	M.pick_port("monitor")
end, {})

vim.api.nvim_create_user_command("MAXClean", function()
	M.clean()
end, {})

vim.api.nvim_create_user_command("MAXInfo", function()
	M.info()
end, {})

return M
