# Compiling V-Sekai
Contributing engine/modules patches requires building our custom Godot engine.

You can use Github Actions or our automated build scripts (local).

## Using Github Actions
1. Fork [V-Sekai/world-godot](https://github.com/V-Sekai/world-godot) in Github Web UI
2. Enable Github Actions in `Actions` repository tab.
3. Github Runner will build editor for every platform at every commit push.

## Using Justfile
For local builds we use [just](https://github.com/casey/just) command-line utility.


#### Install `just` package
**Ubuntu 24.04+/Debian 13+** (For earlier versions, see `All platforms`)
```
sudo apt install just
```
**Windows** (Chocolatey)
```
choco install just
```
**macOS** (MacPort, Homebrew)
```
port install just
```
```
brew install just
```
[All platforms](https://github.com/casey/just?tab=readme-ov-file#packages)

#### Clone build repository
```
git clone https://github.com/V-Sekai/world-godot.git
cd world-godot
```

#### Build
 **Ubuntu/Debian/Fedora**
```
just install_packages

```
**Windows**
```
choco install just
```
**macOS**
```
port install just
```
