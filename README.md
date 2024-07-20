# Data Tree Explorer

Data Tree Explorer is a terminal-based application to view different data
formats in a file explorer-like view. The difference in such a method is that
rather than navigating the file through multiple screens of text, you can look
at one nesting level at a time which may be beneficial, depending on your exact
use case.

## Supported OSes

The application has been tested on OpenSUSE Tumbleweed as well as MacOS 14.5.
No guarantees are provided around the application running or compiling
successfully on any other platforms.

## Developing

This project uses a minimal set of dependencies, mainly NCurses for the TUI
output as well as a number of data parsing libraries to support different file
formats.

### Requirements

In order to properly build the project, you'll need the following:

* Zig 0.13+
* NCurses 6+

#### MacOS

On MacOS, HomeBrew can be used to install the Zig compiler via:

```
brew install zig
```

NCurses should already be available.

#### OpenSUSE

Zypper, OpenSUSE's default package manager, can configure the system for the
project's compilation via:

```
sudo zypper install zig ncurses-devel
```

### Compilation

To compile the application, the execute the following from your terminal:

```
zig build
```

To run it, simply ad the `run` subcommand:

```
zig build run
```
