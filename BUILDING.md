# Compiling V-Sekai
Contributing engine/modules patches requires building our custom Godot engine.

You can use Github Actions or our automated build scripts (local).

## Using Github Actions
1. Fork [V-Sekai/world-godot](https://github.com/V-Sekai/world-godot) in Github Web UI
2. Enable Github Actions in `Actions` repository tab.
3. Github Runner will build editor for every platform at every commit push.

## Using Justfile
For local builds with debug symbols we use [just](https://github.com/casey/just) command-line utility.

#### Install `just` package
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

#### Clone build tools repository
```
git clone https://github.com/V-Sekai/world-godot.git
cd world-godot
```

#### Build editor
 **Ubuntu/Debian/Fedora**
```
just install_packages
just build-platform-target linuxbsd editor
```
**macOS**
```
just fetch-vulkan-sdk
just build-target-macos-editor-double
```

#### Build export templates
**All export templates**
```
PLATFORMS="linuxbsd windows android web"
for in ; do
just fetch-openjdk setup-android-sdk fetch-llvm-ming setup-arm64
just build-platform-templates ${{ matrix.platform }} ${{ matrix.architecture }} ${{ matrix.precision }}';
done
 build-platform-templates macos
```case "${{ matrix.platform }}" in  
            android)  
              PLATFORM_ARGS="fetch-openjdk setup-android-sdk fetch-llvm-ming setup-arm64"  
              ;;  
            web)  
              PLATFORM_ARGS="setup-emscripten"
              if [ ${{ matrix.target }} == 'template_debug' ]; then
                  EXTRA_OPTIONS="optimize=none"; # Fix Github runner out of RAM
              fi
              ;;  
            windows)  
              PLATFORM_ARGS="fetch-llvm-mingw"  
              ;;  
            macos)  
              PLATFORM_ARGS="build-osxcross fetch-vulkan-sdk"  
              ;;  
            *)  
              PLATFORM_ARGS="nil"  
              ;;  
          esac
          if "${{ matrix.architecture == 'arm64' }}"; then
              PLATFORM_ARGS="setup-arm64 $PLATFORM_ARGS"
          fi
          if [ ${{ matrix.platform }} == 'android' ] && [ ${{ matrix.target }} == 'template_release' ]; then
              # Combined debug/release templates step
              hyperfine --show-output --runs 1 'just $PLATFORM_ARGS && 
          else
              hyperfine --show-output --runs 1 'just $PLATFORM_ARGS && just build-platform-target ${{ matrix.platform }} ${{ matrix.target }} ${{ matrix.architecture }} ${{ matrix.precision }} yes $EXTRA_OPTIONS';
          fi
