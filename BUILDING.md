# Compiling V-Sekai
Contributing engine/modules patches requires building our custom Godot engine.

You can use Github Actions or our automated build scripts (local).

## Using Github Actions
1. Fork [V-Sekai/world-godot](https://github.com/V-Sekai/world-godot) in Github Web UI
2. Enable Github Actions in `Actions` repository tab.
3. Github Runner will build editor for every platform at every commit push.

## Using Justfile
For local builds with debug symbols we use [just](https://github.com/casey/just) command-line utility.

### Install `just` package
**Ubuntu 24.04+/Debian 13+** (For earlier versions, see `Install 'just' all platforms`)
```
sudo apt install just golang
```
**Fedora**
```
dnf install just golang
```
**macOS** (MacPort, Homebrew)
```
port install just go
```
```
brew install just go
```
[Install 'just' all platforms](https://github.com/casey/just?tab=readme-ov-file#packages)

### Clone build tools repository
```
git clone https://github.com/V-Sekai/world-godot.git
cd world-godot
```

### Build editor
 **Ubuntu/Debian/Fedora**
```
just install_packages
just build-platform-target linuxbsd editor
# Available platforms: linuxbsd windows android web macos
```
**macOS**
```
just fetch-vulkan-sdk
just build-target-macos-editor-double
```

### Build export templates
**All export templates**
```
just fetch-openjdk setup-android-sdk fetch-llvm-ming setup-arm64
just build-platform-templates linuxbsd x86_64
just build-platform-templates windows x86_64
just build-platform-templates web wasm32
just build-platform-templates ios
just build-platform-templates android arm64
just build-platform-templates macos arm64

if [ ${{ matrix.platform }} == 'x86_64' ]; then
    hyperfine
else if [ ${{ matrix.platform }} == 'arm64' ];
    hyperfine
fi    
```
