#!/bin/bash

# =============================================================================
# 🚀 Bicrypto V5 Advanced Installer
# =============================================================================
# An intelligent, robust, and user-friendly installation script
# Supports multiple Linux distributions with comprehensive error handling
# =============================================================================

set -euo pipefail  # Exit on any error

# Color codes for enhanced output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Installation configuration
readonly SCRIPT_VERSION="5.0.0"
readonly MIN_RAM_MB=4096
readonly REQUIRED_NODE_VERSION="20"
readonly INSTALLATION_LOG="/var/log/bicrypto-installer.log"

# Global variables
DISTRO=""
PACKAGE_MANAGER=""
SERVICE_MANAGER="systemctl"
INSTALLATION_START_TIME=""
TOTAL_STEPS=12

# =============================================================================
# 🎨 UI Functions
# =============================================================================

print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║    ██████╗ ██╗ ██████╗██████╗ ██╗   ██╗██████╗ ████████╗ ██████╗            ║
║    ██╔══██╗██║██╔════╝██╔══██╗╚██╗ ██╔╝██╔══██╗╚══██╔══╝██╔═══██╗           ║
║    ██████╔╝██║██║     ██████╔╝ ╚████╔╝ ██████╔╝   ██║   ██║   ██║           ║
║    ██╔══██╗██║██║     ██╔══██╗  ╚██╔╝  ██╔═══╝    ██║   ██║   ██║           ║
║    ██████╔╝██║╚██████╗██║  ██║   ██║   ██║        ██║   ╚██████╔╝           ║
║    ╚═════╝ ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝        ╚═╝    ╚═════╝            ║
║                                                                              ║
║                      🚀 ADVANCED INSTALLER V5                               ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${WHITE}${BOLD}Welcome to Bicrypto V5 Professional Installation Suite${NC}"
    echo -e "${BLUE}Version: ${SCRIPT_VERSION} | $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo ""
}

print_step() {
    local step_num=$1
    local step_title=$2
    local step_desc=$3
    
    echo -e "\n${PURPLE}${BOLD}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}${BOLD}║ STEP ${step_num}/${TOTAL_STEPS}: ${step_title}${NC}"
    echo -e "${PURPLE}${BOLD}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}${step_desc}${NC}\n"
}

print_success() {
    echo -e "${GREEN}${BOLD}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}${BOLD}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}${BOLD}ℹ $1${NC}"
}

show_progress() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local remaining=$((width - completed))
    
    # Clear the current line first
    printf "\r%*s\r" 80 ""
    
    # Use ASCII characters that work universally
    printf "${CYAN}${BOLD}Progress: ${WHITE}[${GREEN}"
    for ((i=0; i<completed; i++)); do
        printf "="
    done
    printf "${WHITE}"
    for ((i=0; i<remaining; i++)); do
        printf "-"
    done
    printf "${WHITE}] ${YELLOW}${BOLD}%d%%${NC}" $percentage
    
    # Always add a newline and clear the line after showing progress
    echo ""
}

# =============================================================================
# 🛠 System Detection Functions
# =============================================================================

detect_system() {
    print_step 1 "SYSTEM DETECTION" "Analyzing your system configuration..."
    
    # Detect distribution
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$ID
        print_success "Detected OS: $NAME ($VERSION)"
    else
        print_error "Cannot detect operating system"
        exit 1
    fi
    
    # Detect package manager
    if command -v apt >/dev/null 2>&1; then
        PACKAGE_MANAGER="apt"
        print_success "Package Manager: APT (Debian/Ubuntu)"
    elif command -v dnf >/dev/null 2>&1; then
        PACKAGE_MANAGER="dnf"
        print_success "Package Manager: DNF (Fedora/RHEL 8+)"
    elif command -v yum >/dev/null 2>&1; then
        PACKAGE_MANAGER="yum"
        print_success "Package Manager: YUM (CentOS/RHEL 7)"
    else
        print_error "Unsupported package manager"
        exit 1
    fi
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        print_error "This installer must be run as root (use sudo)"
        exit 1
    fi
    
    print_success "System detection completed"
}

check_system_requirements() {
    print_step 2 "SYSTEM REQUIREMENTS" "Verifying system meets minimum requirements..."
    
    local requirements_met=true
    
    # Check RAM
    local total_ram=$(free -m | awk '/^Mem:/{print $2}')
    if [[ $total_ram -lt $MIN_RAM_MB ]]; then
        print_error "Insufficient RAM: ${total_ram}MB detected, ${MIN_RAM_MB}MB required"
        requirements_met=false
    else
        print_success "RAM: ${total_ram}MB (✓ Sufficient)"
    fi
    
    # Check disk space (minimum 10GB)
    local available_space=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $available_space -lt 10 ]]; then
        print_error "Insufficient disk space: ${available_space}GB available, 10GB required"
        requirements_met=false
    else
        print_success "Disk Space: ${available_space}GB (✓ Sufficient)"
    fi
    
    # Check network connectivity
    if ping -c 1 google.com >/dev/null 2>&1; then
        print_success "Network: Connected (✓)"
    else
        print_error "Network: No internet connection detected"
        requirements_met=false
    fi
    
    if [[ $requirements_met == false ]]; then
        print_error "System requirements not met. Installation cannot continue."
        exit 1
    fi
    
    print_success "All system requirements satisfied"
}

# =============================================================================
# 🔧 Installation Functions
# =============================================================================

fix_ubuntu_ppa_issues() {
    if [[ $PACKAGE_MANAGER == "apt" ]]; then
        echo -e "\n${BLUE}${BOLD}ℹ Checking for Ubuntu PPA issues...${NC}"
        
        # Check if we're dealing with the specific ondrej/php PPA issue
        if apt-get update 2>&1 | grep -q "changed its 'Label' value"; then
            print_warning "Detected PPA label change issue, fixing automatically..."
            
            # Accept all repository changes
            DEBIAN_FRONTEND=noninteractive apt-get update --allow-releaseinfo-change -y >/dev/null 2>&1
            
            print_success "PPA repository issues resolved"
        else
            print_success "No PPA issues detected"
        fi
    fi
}

install_dependencies() {
    print_step 3 "DEPENDENCIES" "Installing system dependencies and utilities..."
    
    local packages=()
    
    case $PACKAGE_MANAGER in
        apt)
            packages=(
                "curl" "wget" "git" "unzip" "software-properties-common"
                "ca-certificates" "gnupg" "lsb-release" "apt-transport-https"
                "build-essential" "python3" "python3-pip"
            )
            
            # Handle common PPA repository changes
            print_info "Updating package repositories..."
            if ! apt-get update -qq 2>/dev/null; then
                print_warning "Repository update failed, attempting to fix common PPA issues..."
                
                # Accept repository changes automatically
                apt-get update --allow-releaseinfo-change -qq 2>/dev/null || {
                    print_warning "Removing problematic PPAs temporarily..."
                    # Move PPA files to backup location
                    if [ -d "/etc/apt/sources.list.d" ]; then
                        mkdir -p /tmp/ppa-backup
                        find /etc/apt/sources.list.d -name "*.list" -exec mv {} /tmp/ppa-backup/ \; 2>/dev/null || true
                    fi
                    
                    # Try update again
                    apt-get update -qq
                    
                    # Restore PPA files
                    if [ -d "/tmp/ppa-backup" ]; then
                        find /tmp/ppa-backup -name "*.list" -exec mv {} /etc/apt/sources.list.d/ \; 2>/dev/null || true
                        apt-get update -qq --allow-releaseinfo-change 2>/dev/null || true
                    fi
                }
            fi
            
            apt-get install -y "${packages[@]}"
            ;;
        dnf)
            packages=(
                "curl" "wget" "git" "unzip" "dnf-plugins-core"
                "ca-certificates" "gnupg" "python3" "python3-pip"
                "@development-tools"
            )
            dnf install -y "${packages[@]}"
            ;;
        yum)
            packages=(
                "curl" "wget" "git" "unzip" "ca-certificates"
                "python3" "python3-pip" "gcc" "gcc-c++" "make"
            )
            yum install -y "${packages[@]}"
            ;;
    esac
    
    print_success "System dependencies installed"
}

install_nodejs() {
    print_step 4 "NODE.JS INSTALLATION" "Installing Node.js ${REQUIRED_NODE_VERSION} and npm..."
    
    # Check if Node.js is already installed with correct version
    if command -v node >/dev/null 2>&1; then
        local current_version=$(node -v | sed 's/v//' | cut -d. -f1)
        if [[ $current_version -ge $REQUIRED_NODE_VERSION ]]; then
            print_success "Node.js v$(node -v) already installed"
            return
        fi
    fi
    
    case $PACKAGE_MANAGER in
        apt)
            # Add NodeSource repository
            curl -fsSL https://deb.nodesource.com/setup_${REQUIRED_NODE_VERSION}.x | bash -
            apt-get install -y nodejs
            ;;
        dnf|yum)
            # Install using NodeSource
            curl -fsSL https://rpm.nodesource.com/setup_${REQUIRED_NODE_VERSION}.x | bash -
            $PACKAGE_MANAGER install -y nodejs
            ;;
    esac
    
    # Verify installation
    if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
        print_success "Node.js $(node -v) and npm $(npm -v) installed successfully"
    else
        print_error "Node.js installation failed"
        exit 1
    fi
}

install_pnpm() {
    print_step 5 "PNPM INSTALLATION" "Installing pnpm package manager..."
    
    if command -v pnpm >/dev/null 2>&1; then
        print_success "pnpm $(pnpm -v) already installed"
        return
    fi
    
    npm install -g pnpm@latest
    
    # Verify installation
    if command -v pnpm >/dev/null 2>&1; then
        print_success "pnpm $(pnpm -v) installed successfully"
    else
        print_error "pnpm installation failed"
        exit 1
    fi
}

install_redis() {
    print_step 6 "REDIS INSTALLATION" "Installing and configuring Redis server..."
    
    case $PACKAGE_MANAGER in
        apt)
            apt-get install -y redis-server
            ;;
        dnf)
            dnf install -y redis
            ;;
        yum)
            yum install -y epel-release
            yum install -y redis
            ;;
    esac
    
    # Configure Redis
    systemctl enable redis-server 2>/dev/null || systemctl enable redis
    systemctl start redis-server 2>/dev/null || systemctl start redis
    
    # Test Redis connection
    if redis-cli ping | grep -q PONG; then
        print_success "Redis server installed and running"
    else
        print_error "Redis installation failed"
        exit 1
    fi
}

# =============================================================================
# 🗄 Database Configuration
# =============================================================================

configure_database() {
    print_step 7 "DATABASE CONFIGURATION" "Setting up database connection..."
    
    # Ensure .env file exists
    if [[ ! -f ".env" ]]; then
        if [[ -f ".env.example" ]]; then
            cp .env.example .env
            print_info "Created .env from .env.example"
        else
            print_error "No .env or .env.example file found"
            exit 1
        fi
    fi
    
    # Function to safely read from .env
    read_env_value() {
        local key=$1
        local default=$2
        local value=""
        
        if [[ -f ".env" ]]; then
            value=$(grep "^${key}=" .env 2>/dev/null | head -1 | cut -d'=' -f2- | sed 's/^["'\'']*//;s/["'\'']*$//' | xargs)
        fi
        
        # Use default if value is empty
        if [[ -z "$value" ]]; then
            value="$default"
        fi
        
        echo "$value"
    }
    
    # Get current values from .env with better parsing
    local current_url=$(read_env_value "NEXT_PUBLIC_SITE_URL" "https://localhost")
    local current_name=$(read_env_value "NEXT_PUBLIC_SITE_NAME" "Bicrypto")
    local current_db=$(read_env_value "DB_NAME" "bicrypto")
    local current_user=$(read_env_value "DB_USER" "root")
    local current_host=$(read_env_value "DB_HOST" "localhost")
    local current_port=$(read_env_value "DB_PORT" "3306")
    
    # Debug output (remove this later)
    print_info "Debug - Current values found:"
    echo -e "${CYAN}  URL: '${current_url}'${NC}"
    echo -e "${CYAN}  Name: '${current_name}'${NC}"
    echo -e "${CYAN}  DB: '${current_db}'${NC}"
    echo -e "${CYAN}  User: '${current_user}'${NC}"
    echo -e "${CYAN}  Host: '${current_host}'${NC}"
    echo -e "${CYAN}  Port: '${current_port}'${NC}"
    
    echo -e "\n${YELLOW}${BOLD}📋 Database Configuration${NC}"
    echo -e "${CYAN}Please provide your database connection details:${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    # Clear any input buffer
    read -t 1 -n 10000 discard 2>/dev/null || true
    
    # Site URL
    echo -e "${WHITE}${BOLD}Site URL:${NC}"
    echo -e "${CYAN}Current: ${current_url}${NC}"
    echo -n "Enter Site URL (or press Enter to keep current): "
    read SITE_URL
    if [[ -z "$SITE_URL" ]]; then
        SITE_URL="$current_url"
        echo -e "${GREEN}Using: ${SITE_URL}${NC}"
    fi
    
    # Site Name
    echo -e "\n${WHITE}${BOLD}Site Name:${NC}"
    echo -e "${CYAN}Current: ${current_name}${NC}"
    echo -n "Enter Site Name (or press Enter to keep current): "
    read SITE_NAME  
    if [[ -z "$SITE_NAME" ]]; then
        SITE_NAME="$current_name"
        echo -e "${GREEN}Using: ${SITE_NAME}${NC}"
    fi
    
    # Database Name
    echo -e "\n${WHITE}${BOLD}Database Name:${NC}"
    echo -e "${CYAN}Current: ${current_db}${NC}"
    echo -n "Enter Database Name (or press Enter to keep current): "
    read DB_NAME
    if [[ -z "$DB_NAME" ]]; then
        DB_NAME="$current_db"
        echo -e "${GREEN}Using: ${DB_NAME}${NC}"
    fi
    
    # Database User
    echo -e "\n${WHITE}${BOLD}Database User:${NC}"
    echo -e "${CYAN}Current: ${current_user}${NC}"
    echo -n "Enter Database User (or press Enter to keep current): "
    read DB_USER
    if [[ -z "$DB_USER" ]]; then
        DB_USER="$current_user"
        echo -e "${GREEN}Using: ${DB_USER}${NC}"
    fi
    
    # Database Password
    echo -e "\n${WHITE}${BOLD}Database Password:${NC}"
    echo -n "Enter Database Password: "
    read -s DB_PASSWORD
    echo
    if [[ -z "$DB_PASSWORD" ]]; then
        print_error "Database password cannot be empty!"
        exit 1
    fi
    
    # Database Host
    echo -e "\n${WHITE}${BOLD}Database Host:${NC}"
    echo -e "${CYAN}Current: ${current_host}${NC}"
    echo -n "Enter Database Host (or press Enter to keep current): "
    read DB_HOST
    if [[ -z "$DB_HOST" ]]; then
        DB_HOST="$current_host"
        echo -e "${GREEN}Using: ${DB_HOST}${NC}"
    fi
    
    # Database Port
    echo -e "\n${WHITE}${BOLD}Database Port:${NC}"
    echo -e "${CYAN}Current: ${current_port}${NC}"
    echo -n "Enter Database Port (or press Enter to keep current): "
    read DB_PORT
    if [[ -z "$DB_PORT" ]]; then
        DB_PORT="$current_port"
        echo -e "${GREEN}Using: ${DB_PORT}${NC}"
    fi
    
    # Test database connection
    print_info "Testing database connection..."
    if mysql -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" -P "$DB_PORT" -e "SELECT 1;" >/dev/null 2>&1; then
        print_success "Database connection successful"
    else
        print_error "Database connection failed. Please check your credentials."
        exit 1
    fi
    
    # Generate secure tokens
    print_info "Generating secure tokens..."
    local ACCESS_TOKEN=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
    local REFRESH_TOKEN=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
    local RESET_TOKEN=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
    local VERIFY_TOKEN=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
    
    # Update .env file
    update_env_file "NEXT_PUBLIC_SITE_URL" "$SITE_URL"
    update_env_file "NEXT_PUBLIC_SITE_NAME" "$SITE_NAME"
    update_env_file "DB_NAME" "$DB_NAME"
    update_env_file "DB_USER" "$DB_USER"
    update_env_file "DB_PASSWORD" "$DB_PASSWORD"
    update_env_file "DB_HOST" "$DB_HOST"
    update_env_file "DB_PORT" "$DB_PORT"
    update_env_file "APP_ACCESS_TOKEN_SECRET" "$ACCESS_TOKEN"
    update_env_file "APP_REFRESH_TOKEN_SECRET" "$REFRESH_TOKEN"
    update_env_file "APP_RESET_TOKEN_SECRET" "$RESET_TOKEN"
    update_env_file "APP_VERIFY_TOKEN_SECRET" "$VERIFY_TOKEN"
    
    print_success "Database configuration completed"
}

update_env_file() {
    local key=$1
    local value=$2
    local env_file=".env"
    
    # Create a temporary file for safe sed operations
    local temp_file=$(mktemp)
    
    if grep -q "^${key}=" "$env_file"; then
        # Remove the existing line and add the new one
        grep -v "^${key}=" "$env_file" > "$temp_file"
        echo "${key}=${value}" >> "$temp_file"
        mv "$temp_file" "$env_file"
    else
        # Simply append the new key-value pair
        echo "${key}=${value}" >> "$env_file"
        rm -f "$temp_file"
    fi
}

# =============================================================================
# 🏗 Application Build
# =============================================================================

build_application() {
    print_step 8 "APPLICATION BUILD" "Installing dependencies and building the application..."
    
    # Install dependencies
    print_info "Installing project dependencies..."
    if ! pnpm install --frozen-lockfile; then
        print_error "Failed to install dependencies"
        exit 1
    fi
    
    # Build application
    print_info "Building application (this may take several minutes)..."
    if ! pnpm build:all; then
        print_error "Application build failed"
        exit 1
    fi
    
    # Seed database
    print_info "Seeding database with initial data..."
    if ! pnpm seed; then
        print_error "Database seeding failed"
        exit 1
    fi
    
    print_success "Application built successfully"
}

# =============================================================================
# 🌐 Web Server Configuration
# =============================================================================

configure_webserver() {
    print_step 9 "WEB SERVER" "Configuring web server (Apache/Nginx)..."
    
    # Detect web server
    if systemctl is-active --quiet apache2 2>/dev/null || systemctl is-active --quiet httpd 2>/dev/null; then
        configure_apache
    elif systemctl is-active --quiet nginx 2>/dev/null; then
        configure_nginx
    else
        print_warning "No active web server detected. You'll need to configure manually."
        return
    fi
}

configure_apache() {
    print_info "Configuring Apache..."
    
    # Enable required modules
    local modules=("proxy" "proxy_http" "proxy_wstunnel" "ssl" "rewrite")
    
    case $PACKAGE_MANAGER in
        apt)
            for module in "${modules[@]}"; do
                a2enmod "$module" >/dev/null 2>&1 || true
            done
            systemctl restart apache2
            ;;
        dnf|yum)
            # Modules are typically compiled in for RHEL/CentOS
            systemctl restart httpd
            ;;
    esac
    
    print_success "Apache configured successfully"
}

configure_nginx() {
    print_info "Configuring Nginx..."
    # Add Nginx configuration here if needed
    systemctl restart nginx
    print_success "Nginx configured successfully"
}

# =============================================================================
# 🔒 Security & Firewall
# =============================================================================

configure_security() {
    print_step 10 "SECURITY" "Configuring security and firewall settings..."
    
    # Configure firewall if available
    if command -v ufw >/dev/null 2>&1; then
        print_info "Configuring UFW firewall..."
        ufw --force enable
        ufw allow ssh
        ufw allow http
        ufw allow https
        ufw allow 3000  # Application port
        print_success "UFW firewall configured"
    elif command -v firewall-cmd >/dev/null 2>&1; then
        print_info "Configuring firewalld..."
        systemctl enable --now firewalld
        firewall-cmd --permanent --add-service=ssh
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        firewall-cmd --permanent --add-port=3000/tcp
        firewall-cmd --reload
        print_success "Firewalld configured"
    else
        print_warning "No supported firewall found. Manual configuration may be required."
    fi
    
    # Set proper file permissions and ownership
    print_info "Setting file permissions and ownership..."
    
    # Detect the owner and group of the public_html folder (or current directory if not in public_html)
    local target_dir="."
    if [[ -d "../public_html" ]]; then
        target_dir="../public_html"
    elif [[ "$(basename $(pwd))" == "public_html" ]]; then
        target_dir="."
    elif [[ -d "public_html" ]]; then
        target_dir="public_html"
    fi
    
    local dir_owner=$(stat -c '%U' "$target_dir")
    local dir_group=$(stat -c '%G' "$target_dir")
    
    print_info "Detected directory owner: ${dir_owner}:${dir_group}"
    
    # Set ownership recursively to match the parent directory
    chown -R "${dir_owner}:${dir_group}" .
    
    # Set proper permissions
    find . -type d -exec chmod 755 {} \;
    find . -type f -exec chmod 644 {} \;
    chmod +x *.sh 2>/dev/null || true
    chmod 600 .env
    
    print_success "Security configuration completed"
}

# =============================================================================
# 🚀 Service Management
# =============================================================================

setup_process_manager() {
    print_step 11 "PROCESS MANAGER" "Setting up PM2 process manager..."
    
    # Install PM2 globally
    if ! command -v pm2 >/dev/null 2>&1; then
        npm install -g pm2
    fi
    
    # Create PM2 ecosystem file
    cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'bicrypto-v5',
    script: 'pnpm',
    args: 'start',
    cwd: '$(pwd)',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production'
    }
  }]
};
EOF
    
    # Setup PM2 startup
    pm2 startup | tail -n 1 | bash || true
    
    print_success "PM2 process manager configured"
}

# =============================================================================
# ✅ Final Steps
# =============================================================================

finalize_installation() {
    print_step 12 "FINALIZATION" "Completing installation..."
    
    # Calculate installation time
    local end_time=$(date +%s)
    local duration=$((end_time - INSTALLATION_START_TIME))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    
    print_success "Installation completed in ${minutes}m ${seconds}s"
    print_info "You can now start the application manually with: pnpm start"
}

# =============================================================================
# 📊 Installation Summary
# =============================================================================

show_installation_summary() {
    clear
    echo -e "${GREEN}${BOLD}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  🎉 INSTALLATION COMPLETED SUCCESSFULLY! 🎉                                 ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${WHITE}${BOLD}🚀 Bicrypto V5 is now ready!${NC}\n"
    
    echo -e "${CYAN}${BOLD}📋 INSTALLATION SUMMARY${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}• Site URL:${NC}        ${GREEN}$(grep "^NEXT_PUBLIC_SITE_URL=" .env | cut -d'=' -f2)${NC}"
    echo -e "${WHITE}• Site Name:${NC}      ${GREEN}$(grep "^NEXT_PUBLIC_SITE_NAME=" .env | cut -d'=' -f2)${NC}"
    echo -e "${WHITE}• Database:${NC}       ${GREEN}$(grep "^DB_NAME=" .env | cut -d'=' -f2)${NC}"
    echo -e "${WHITE}• Node.js:${NC}        ${GREEN}$(node -v)${NC}"
    echo -e "${WHITE}• pnpm:${NC}           ${GREEN}$(pnpm -v)${NC}"
    echo -e "${WHITE}• Redis:${NC}          ${GREEN}Running${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}${BOLD}🔐 ADMIN CREDENTIALS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}• Email:${NC}          ${GREEN}superadmin@example.com${NC}"
    echo -e "${WHITE}• Password:${NC}       ${GREEN}12345678${NC}"
    echo -e "${WHITE}• Admin Panel:${NC}    ${GREEN}$(grep "^NEXT_PUBLIC_SITE_URL=" .env | cut -d'=' -f2)/admin${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${PURPLE}${BOLD}⚡ QUICK COMMANDS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}• Start Server:${NC}   ${CYAN}pnmp start${NC}"
    echo -e "${WHITE}• Stop Server:${NC}    ${CYAN}pnpm stop${NC}"
    echo -e "${WHITE}• View Logs:${NC}      ${CYAN}pnpm logs${NC}"
    echo -e "${WHITE}• Restart:${NC}        ${CYAN}pnpm restart${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${RED}${BOLD}⚠️  IMPORTANT SECURITY NOTES${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}• Change the default admin password immediately after first login${NC}"
    echo -e "${YELLOW}• Configure SSL certificates for production use${NC}"
    echo -e "${YELLOW}• Review and update firewall settings as needed${NC}"
    echo -e "${YELLOW}• Keep your system and dependencies updated regularly${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${WHITE}${BOLD}📞 Support: ${BLUE}https://support.mash3div.com${NC}"
    echo -e "${WHITE}${BOLD}📖 Documentation: ${BLUE}https://docs.bicrypto.com${NC}\n"
    
    echo -e "${GREEN}${BOLD}Thank you for choosing Bicrypto V5! 🚀${NC}\n"
}

# =============================================================================
# 🎯 Main Installation Flow
# =============================================================================

main() {
    INSTALLATION_START_TIME=$(date +%s)
    
    # Setup logging
    exec 1> >(tee -a "$INSTALLATION_LOG")
    exec 2> >(tee -a "$INSTALLATION_LOG" >&2)
    
    # Show banner
    print_banner
    
    # Confirm installation
    echo -e "${YELLOW}${BOLD}This will install Bicrypto V5 with all required dependencies.${NC}"
    echo -e "${WHITE}The installation process will take 10-15 minutes.${NC}\n"
    
    read -p "$(echo -e ${WHITE}Continue with installation? [Y/n]: ${NC})" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        echo -e "${RED}Installation cancelled.${NC}"
        exit 0
    fi
    
    # Execute installation steps
    detect_system
    sleep 1
    show_progress 1 $TOTAL_STEPS
    sleep 1
    
    check_system_requirements  
    sleep 1
    show_progress 2 $TOTAL_STEPS
    sleep 1
    
    # Fix common Ubuntu PPA issues before installing dependencies
    fix_ubuntu_ppa_issues
    
    install_dependencies
    sleep 1
    show_progress 3 $TOTAL_STEPS
    sleep 1
    
    install_nodejs
    sleep 1
    show_progress 4 $TOTAL_STEPS
    sleep 1
    
    install_pnpm
    sleep 1
    show_progress 5 $TOTAL_STEPS
    sleep 1
    
    install_redis
    sleep 1
    show_progress 6 $TOTAL_STEPS
    sleep 1
    
    configure_database
    sleep 1
    show_progress 7 $TOTAL_STEPS
    sleep 1
    
    build_application
    sleep 1
    show_progress 8 $TOTAL_STEPS
    sleep 1
    
    configure_webserver
    sleep 1
    show_progress 9 $TOTAL_STEPS
    sleep 1
    
    configure_security
    sleep 1
    show_progress 10 $TOTAL_STEPS
    sleep 1
    
    setup_process_manager
    sleep 1
    show_progress 11 $TOTAL_STEPS
    sleep 1
    
    finalize_installation
    sleep 1
    show_progress 12 $TOTAL_STEPS
    sleep 1
    
    echo -e "\n"
    
    # Show final summary
    show_installation_summary
}

# =============================================================================
# 🚦 Script Entry Point
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 
