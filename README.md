# maxim.nvim

**MAX78000 development helper for Neovim.**

Provides convenient Neovim commands for building, flashing, and monitoring Maxim MSDK projects using [snacks.nvim](https://github.com/folke/snacks.nvim).

## Features

- Build MSDK projects
- Flash using OpenOCD and CMSIS-DAP
- Open a serial monitor with `picocom`
- Select available serial ports
- Configurable target board and baud rate

## Requirements

- [Maxim MSDK](https://github.com/analogdevicesinc/msdk)
- `make`
- OpenOCD with CMSIS-DAP support
- `picocom`
- [snacks.nvim](https://github.com/folke/snacks.nvim)

For the MAX78000FTHR, the default board is:

```text
FTHR_RevA
```

Your MSDK environment must be configured before starting Neovim.

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "jaller698/maxim.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  opts = {
    board = "FTHR_RevA",
    baudrate = 115200,
  },
}
```

## Configuration

```lua
opts = {
  board = "FTHR_RevA",
  baudrate = 115200,
  serial_command = "picocom",
  make_command = "make",
}
```

## Commands

| Command       | Description                                  |
| :------------ | :------------------------------------------- |
| `:MAXBuild`   | Build the current MSDK project               |
| `:MAXFlash`   | Flash using OpenOCD                          |
| `:MAXMonitor` | Select a serial port and open `picocom`      |
| `:MAXClean`   | Clean the current project                    |
| `:MAXInfo`    | Show tool, board, and serial-port information |

## Example Workflow

Open an MSDK project:

```fish
cd ~/MaximSDK/Examples/MAX78000/hello_world
nvim .
```

Build and flash:

```vim
:MAXBuild
:MAXFlash
```

Open the serial monitor:

```vim
:MAXMonitor
```

The equivalent commands from a shell are:

```fish
make BOARD=FTHR_RevA
make BOARD=FTHR_RevA flash.openocd
picocom -b 115200 /dev/ttyACM0
```

Press the board's reset button after opening the serial monitor.

To exit `picocom`:

```text
Ctrl-A, then Ctrl-X
```

## Linux Permissions

Your user must have permission to access the board's serial device and CMSIS-DAP debugger.

### Serial Port Permissions

On Fedora, add your user to the `dialout` group:

```fish
sudo usermod -aG dialout $USER
```

On Arch Linux and CachyOS, add your user to the `uucp` group:

```fish
sudo usermod -aG uucp $USER
```

Log out and back in for the change to take effect. Check your groups with:

```fish
groups
```

### CMSIS-DAP udev Rule

If OpenOCD cannot access the debugger, create a udev rule:

```fish
sudo vim /etc/udev/rules.d/70-max78000-daplink.rules
```

Add:

```udev
KERNEL=="hidraw*", ATTRS{idVendor}=="0d28", ATTRS{idProduct}=="0204", TAG+="uaccess", MODE="0660"
```

Reload the udev rules:

```fish
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Disconnect and reconnect the board afterward.

The board should appear as a CMSIS-DAP device with vendor/product ID:

```text
0d28:0204
```

You can verify this with:

```fish
lsusb | grep -i -E 'mbed|dap|cmsis|0d28'
```

Check whether the serial port is available with:

```fish
ls -l /dev/ttyACM* /dev/ttyUSB* 2>/dev/null
```
## Notes

- Close `picocom` before flashing.
- The baud rate must match the firmware.
- The plugin does not install the MSDK or its tools.
- On Linux, your user may need permission to access `/dev/ttyACM*`.

## License

MIT License
