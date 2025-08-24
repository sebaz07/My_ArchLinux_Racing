#!/usr/bin/env bash
# Development Environment Setup Script
# Installs and configures development tools

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

main() {
    log_info "Starting development environment setup..."
    
    # Install development packages
    install_dev_packages
    
    # Setup Docker
    setup_docker
    
    # Setup Node.js environment
    setup_nodejs
    
    # Setup .NET environment
    setup_dotnet
    
    # Setup Python environment
    setup_python
    
    # Setup Rust environment
    setup_rust
    
    # Setup Go environment
    setup_go
    
    # Install VS Code extensions (if VS Code is installed)
    setup_vscode_extensions
    
    log_success "Development environment setup completed!"
}

install_dev_packages() {
    log_info "Installing development packages..."
    
    local dev_packages=(
        "git"
        "base-devel"
        "cmake"
        "ninja"
        "meson"
        "clang"
        "llvm"
        "gdb"
        "valgrind"
        "strace"
        "htop"
        "tree"
        "fd"
        "ripgrep"
        "bat"
        "exa"
        "zoxide"
        "fzf"
        "tmux"
        "neovim"
        "curl"
        "wget"
        "unzip"
        "zip"
        "tar"
        "xz"
    )
    
    for package in "${dev_packages[@]}"; do
        sudo pacman -S --noconfirm "$package" || log_warning "Failed to install: $package"
    done
    
    log_success "Development packages installed"
}

setup_docker() {
    log_info "Setting up Docker..."
    
    # Docker should already be installed from package list
    if ! command -v docker &> /dev/null; then
        sudo pacman -S --noconfirm docker docker-compose
    fi
    
    # Enable and start Docker service
    sudo systemctl enable docker
    sudo systemctl start docker
    
    # Add user to docker group
    sudo usermod -aG docker "$USER"
    
    log_success "Docker configured (logout/login required for group changes)"
}

setup_nodejs() {
    log_info "Setting up Node.js environment..."
    
    # Install Node.js and npm
    sudo pacman -S --noconfirm nodejs npm
    
    # Install global packages
    local npm_packages=(
        "yarn"
        "pnpm"
        "typescript"
        "@angular/cli"
        "create-react-app"
        "vue-cli"
        "eslint"
        "prettier"
        "nodemon"
        "pm2"
    )
    
    for package in "${npm_packages[@]}"; do
        npm install -g "$package" || log_warning "Failed to install npm package: $package"
    done
    
    log_success "Node.js environment configured"
}

setup_dotnet() {
    log_info "Setting up .NET environment..."
    
    # .NET SDK should already be installed from package list
    if command -v dotnet &> /dev/null; then
        # Install global tools
        dotnet tool install -g dotnet-ef
        dotnet tool install -g dotnet-aspnet-codegenerator
        
        log_success ".NET environment configured"
    else
        log_warning ".NET SDK not found, skipping .NET setup"
    fi
}

setup_python() {
    log_info "Setting up Python environment..."
    
    # Install Python packages
    sudo pacman -S --noconfirm python python-pip python-pipenv python-virtualenv
    
    # Install common Python packages
    local python_packages=(
        "numpy"
        "pandas"
        "matplotlib"
        "requests"
        "flask"
        "django"
        "fastapi"
        "pytest"
        "black"
        "flake8"
        "mypy"
    )
    
    for package in "${python_packages[@]}"; do
        pip install --user "$package" || log_warning "Failed to install Python package: $package"
    done
    
    log_success "Python environment configured"
}

setup_rust() {
    log_info "Setting up Rust environment..."
    
    # Install Rust via rustup
    if ! command -v rustc &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    # Install common Rust tools
    if command -v cargo &> /dev/null; then
        cargo install cargo-edit cargo-watch cargo-expand
        log_success "Rust environment configured"
    else
        log_warning "Rust installation failed"
    fi
}

setup_go() {
    log_info "Setting up Go environment..."
    
    # Install Go
    sudo pacman -S --noconfirm go
    
    # Set up Go environment
    mkdir -p "$HOME/go"/{bin,src,pkg}
    
    # Add Go environment variables to shell config
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "GOPATH" "$HOME/.zshrc"; then
            cat >> "$HOME/.zshrc" <<EOF

# Go environment
export GOPATH=\$HOME/go
export PATH=\$PATH:\$GOPATH/bin
EOF
        fi
    fi
    
    log_success "Go environment configured"
}

setup_vscode_extensions() {
    log_info "Setting up VS Code extensions..."
    
    if command -v code &> /dev/null; then
        local extensions=(
            "ms-vscode.vscode-typescript-next"
            "bradlc.vscode-tailwindcss"
            "ms-python.python"
            "ms-dotnettools.csharp"
            "rust-lang.rust-analyzer"
            "golang.go"
            "ms-vscode.cmake-tools"
            "ms-vscode.cpptools"
            "formulahendry.auto-rename-tag"
            "esbenp.prettier-vscode"
            "ms-vscode.vscode-eslint"
            "ms-vscode-remote.remote-ssh"
            "ms-azuretools.vscode-docker"
            "gitpod.gitpod-desktop"
        )
        
        for extension in "${extensions[@]}"; do
            code --install-extension "$extension" || log_warning "Failed to install extension: $extension"
        done
        
        log_success "VS Code extensions installed"
    else
        log_warning "VS Code not found, skipping extension installation"
    fi
}

# Run main function
main "$@"
