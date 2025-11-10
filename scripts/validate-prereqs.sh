#!/bin/bash

# Zero-to-Running Developer Environment
# Prerequisites Validation Script
# Checks that all required tools are installed and meet minimum version requirements

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Status tracking
ALL_CHECKS_PASSED=true

# Helper functions
print_header() {
  echo ""
  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${BLUE}  Zero-to-Running Developer Environment${NC}"
  echo -e "${BOLD}${BLUE}  Prerequisites Validation${NC}"
  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
  ALL_CHECKS_PASSED=false
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

# Version comparison function
version_gte() {
  # Returns 0 if $1 >= $2, 1 otherwise
  printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

# Check functions
check_docker() {
  echo -n "Checking Docker... "
  
  if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed"
    print_info "Install from: https://docs.docker.com/get-docker/"
    return
  fi
  
  DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  MIN_VERSION="24.0.0"
  
  if version_gte "$DOCKER_VERSION" "$MIN_VERSION"; then
    print_success "Docker $DOCKER_VERSION (>= $MIN_VERSION required)"
  else
    print_error "Docker $DOCKER_VERSION found, but >= $MIN_VERSION required"
    print_info "Update from: https://docs.docker.com/get-docker/"
  fi
  
  # Check if Docker daemon is running
  if ! docker info &> /dev/null; then
    print_warning "Docker daemon is not running. Please start Docker Desktop."
  fi
}

check_docker_compose() {
  echo -n "Checking Docker Compose... "
  
  if ! command -v docker &> /dev/null; then
    print_error "Docker Compose is not available (Docker not installed)"
    return
  fi
  
  # Check for docker compose (v2) or docker-compose (v1)
  if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || docker compose version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    MIN_VERSION="2.0.0"
    
    if version_gte "$COMPOSE_VERSION" "$MIN_VERSION"; then
      print_success "Docker Compose $COMPOSE_VERSION (>= $MIN_VERSION required)"
    else
      print_error "Docker Compose $COMPOSE_VERSION found, but >= $MIN_VERSION required"
    fi
  elif command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    print_warning "Using legacy docker-compose v$COMPOSE_VERSION. Consider upgrading to Docker Compose v2."
  else
    print_error "Docker Compose is not installed"
    print_info "Included with Docker Desktop: https://docs.docker.com/compose/install/"
  fi
}

check_make() {
  echo -n "Checking Make... "
  
  if ! command -v make &> /dev/null; then
    print_error "Make is not installed"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
      print_info "Install via Xcode Command Line Tools: xcode-select --install"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      print_info "Install via: sudo apt-get install build-essential (Ubuntu/Debian)"
    else
      print_info "Install Make for your operating system"
    fi
    return
  fi
  
  MAKE_VERSION=$(make --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
  MIN_VERSION="3.0"
  
  if version_gte "$MAKE_VERSION" "$MIN_VERSION"; then
    print_success "Make $MAKE_VERSION (>= $MIN_VERSION required)"
  else
    print_error "Make $MAKE_VERSION found, but >= $MIN_VERSION required"
  fi
}

check_node() {
  echo -n "Checking Node.js... "
  
  if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed"
    print_info "Install via nvm: https://github.com/nvm-sh/nvm"
    print_info "Or download from: https://nodejs.org/"
    return
  fi
  
  NODE_VERSION=$(node --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  MIN_VERSION="20.0.0"
  
  if version_gte "$NODE_VERSION" "$MIN_VERSION"; then
    print_success "Node.js $NODE_VERSION (>= $MIN_VERSION required)"
  else
    print_error "Node.js $NODE_VERSION found, but >= $MIN_VERSION required"
    print_info "Install Node.js 20.x via nvm: nvm install 20"
  fi
}

check_npm() {
  echo -n "Checking npm... "
  
  if ! command -v npm &> /dev/null; then
    print_error "npm is not installed (comes with Node.js)"
    return
  fi
  
  NPM_VERSION=$(npm --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  MIN_VERSION="10.0.0"
  
  if version_gte "$NPM_VERSION" "$MIN_VERSION"; then
    print_success "npm $NPM_VERSION (>= $MIN_VERSION required)"
  else
    print_error "npm $NPM_VERSION found, but >= $MIN_VERSION required"
    print_info "Update npm: npm install -g npm@latest"
  fi
}

check_git() {
  echo -n "Checking Git... "
  
  if ! command -v git &> /dev/null; then
    print_error "Git is not installed"
    print_info "Install from: https://git-scm.com/downloads"
    return
  fi
  
  GIT_VERSION=$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  MIN_VERSION="2.0.0"
  
  if version_gte "$GIT_VERSION" "$MIN_VERSION"; then
    print_success "Git $GIT_VERSION (>= $MIN_VERSION required)"
  else
    print_error "Git $GIT_VERSION found, but >= $MIN_VERSION required"
  fi
}

check_aws_cli() {
  echo -n "Checking AWS CLI (optional)... "
  
  if ! command -v aws &> /dev/null; then
    print_warning "AWS CLI not installed (optional - needed for cloud deployment)"
    print_info "Install from: https://aws.amazon.com/cli/"
    return
  fi
  
  AWS_VERSION=$(aws --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  MIN_VERSION="2.0.0"
  
  if version_gte "$AWS_VERSION" "$MIN_VERSION"; then
    print_success "AWS CLI $AWS_VERSION (>= $MIN_VERSION recommended)"
  else
    print_warning "AWS CLI $AWS_VERSION found, but >= $MIN_VERSION recommended"
  fi
}

check_terraform() {
  echo -n "Checking Terraform (optional)... "
  
  if ! command -v terraform &> /dev/null; then
    print_warning "Terraform not installed (optional - needed for cloud deployment)"
    print_info "Install from: https://www.terraform.io/downloads"
    return
  fi
  
  TERRAFORM_VERSION=$(terraform --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  MIN_VERSION="1.6.0"
  
  if version_gte "$TERRAFORM_VERSION" "$MIN_VERSION"; then
    print_success "Terraform $TERRAFORM_VERSION (>= $MIN_VERSION recommended)"
  else
    print_warning "Terraform $TERRAFORM_VERSION found, but >= $MIN_VERSION recommended"
  fi
}

# Main execution
print_header

echo -e "${BOLD}Required Tools:${NC}"
echo ""
check_docker
check_docker_compose
check_make
check_node
check_npm
check_git

echo ""
echo -e "${BOLD}Optional Tools (for AWS deployment):${NC}"
echo ""
check_aws_cli
check_terraform

echo ""
echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Summary
if [ "$ALL_CHECKS_PASSED" = true ]; then
  echo -e "${GREEN}${BOLD}✓ All required prerequisites are met!${NC}"
  echo ""
  echo -e "Next steps:"
  echo -e "  1. Copy environment file: ${BOLD}cp .env.example .env${NC}"
  echo -e "  2. Start development: ${BOLD}make dev${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}${BOLD}✗ Some prerequisites are missing or outdated.${NC}"
  echo ""
  echo -e "Please install or update the required tools listed above."
  echo ""
  exit 1
fi

