#!/bin/bash

# Define the scaffold templates folder
SCAFFOLD_TEMPLATES="$PWD/scaffold-templates"

# Function to check for project name argument
function check_project_name() {
  echo "🔍 Checking project name"
  PROJECT_NAME=$1
  if [ -z "$PROJECT_NAME" ]; then
    read -p "Project name: " PROJECT_NAME
  fi
}

# Function to create Vite project
function create_vite_project() {
  echo "🚀 Creating Vite project"
  npm create vite@latest . -- --template react-ts || { echo "Vite init failed"; exit 1; }
}

# Function to scaffold folder structure
function scaffold_folder_structure() {
  echo "📂 Scaffolding folder structure"
  mkdir -p src/{components,pages,hooks,services,utils,assets,styles,types} || { echo "Failed to create folder structure"; exit 1; }
  echo "✅ Folder structure scaffolded."
}

# Fix the install_dependencies function to handle JSON data correctly
function install_dependencies() {
  echo "📦 Installing dependencies"
  DEPENDENCIES=$(jq -r '.dependencies | to_entries | map("\(.key)@\(.value)") | join(" ")' "$SCAFFOLD_TEMPLATES/dependencies.json")
  DEV_DEPENDENCIES=$(jq -r '.devDependencies | to_entries | map("\(.key)@\(.value)") | join(" ")' "$SCAFFOLD_TEMPLATES/dependencies.json")

  if [ -n "$DEPENDENCIES" ]; then
    npm install $DEPENDENCIES --legacy-peer-deps || { echo "Install dependencies failed"; exit 1; }
  fi

  if [ -n "$DEV_DEPENDENCIES" ]; then
    npm install -D $DEV_DEPENDENCIES --legacy-peer-deps || { echo "Install devDependencies failed"; exit 1; }
  fi

  echo "✅ Dependencies installed."
}

# Function to configure ESLint and Prettier
function configure_linting() {
  echo "🛠️ Configuring ESLint and Prettier"
  cp "$SCAFFOLD_TEMPLATES/.eslintrc.js" . || { echo "Failed to copy ESLint configuration"; exit 1; }
  cp "$SCAFFOLD_TEMPLATES/.prettierrc.js" . || { echo "Failed to copy Prettier configuration"; exit 1; }
  echo "✅ ESLint and Prettier configured."
}

# Function to set up Husky and lint-staged
function setup_husky_lint_staged() {
  echo "🐶 Setting up Husky and lint-staged"
  
  # Initialize Husky and install dependencies
  npx husky-init && npm install || { echo "Husky setup failed"; exit 1; }
  
  # Set up a pre-commit hook for lint-staged
  npx husky set .husky/pre-commit "npx lint-staged" || { echo "Husky pre-commit hook setup failed"; exit 1; }

  # Read lint-staged configuration from the template
  if [ -f "$SCAFFOLD_TEMPLATES/lint-staged-rules.json" ]; then
    LINT_STAGED_CONFIG=$(cat "$SCAFFOLD_TEMPLATES/lint-staged-rules.json") || { echo "Failed to read lint-staged configuration"; exit 1; }
  else
    echo "❌ lint-staged configuration file not found in scaffold-templates."
    exit 1
  fi

  # Update package.json with lint-staged configuration
  if [ -f package.json ]; then
    jq --argjson lintStaged "$LINT_STAGED_CONFIG" '. + {"lint-staged": $lintStaged}' package.json > package.tmp.json && mv package.tmp.json package.json || {
      echo "Failed to update package.json with lint-staged configuration";
      exit 1;
    }
  else
    echo "❌ package.json not found. Ensure you are in the correct project directory."
    exit 1
  fi

  echo "✅ Husky and lint-staged configured."
}

# Function to configure Vitest
function configure_vitest() {
  echo "🧪 Configuring Vitest"
  cp "$SCAFFOLD_TEMPLATES/vitest-config.ts" vite.config.ts || { echo "Failed to copy Vitest configuration"; exit 1; }
  cp "$SCAFFOLD_TEMPLATES/sample-test.tsx" src/App.test.tsx || { echo "Failed to copy sample test file"; exit 1; }
  echo "✅ Sample test added."

  # Add a test script to package.json
  if [ -f package.json ]; then
    jq '.scripts.test = "vitest"' package.json > package.tmp.json && mv package.tmp.json package.json || {
      echo "Failed to add test script to package.json";
      exit 1;
    }
    echo "✅ Test script added to package.json."
  else
    echo "❌ package.json not found. Ensure you are in the correct project directory.";
    exit 1;
  fi
}

# Update the initialize_storybook function to install dependencies without starting a server
function initialize_storybook() {
  echo "📖 Initializing Storybook"
  npx sb init --builder @storybook/builder-vite --skip-install || { echo "Storybook setup failed"; exit 1; }
  cp "$SCAFFOLD_TEMPLATES/storybook-button.stories.tsx" src/components/Button.stories.tsx || { echo "Failed to copy Storybook configuration template"; exit 1; }
  echo "✅ Storybook initialized and template story added. You can customize it in 'src/components/Button.stories.tsx'."
}

# Function to configure project files
function configure_project_files() {
  echo "📝 Configuring project files"
  cp "$SCAFFOLD_TEMPLATES/tsconfig-template.json" tsconfig.json || { echo "Failed to copy tsconfig.json"; exit 1; }
  sed "s/\$PROJECT_NAME/$PROJECT_NAME/" "$SCAFFOLD_TEMPLATES/README-template.md" > README.md || { echo "Failed to create README.md"; exit 1; }
  echo "✅ README.md created."
  cp "$SCAFFOLD_TEMPLATES/Dockerfile-template" Dockerfile || { echo "Failed to copy Dockerfile"; exit 1; }
  cp "$SCAFFOLD_TEMPLATES/.dockerignore-template" .dockerignore || { echo "Failed to copy .dockerignore"; exit 1; }
  cp "$SCAFFOLD_TEMPLATES/.gitignore-template" .gitignore || { echo "Failed to copy .gitignore"; exit 1; }
}

# Function to initialize Git repository
function initialize_git() {
  echo "🔧 Initializing Git repository"
  if [ ! -d .git ]; then
    git init -b main || { echo "Failed to initialize Git repository with 'main' branch"; exit 1; }
    git add . || { echo "Failed to stage files"; exit 1; }
    echo "✅ Git repository initialized with 'main' branch as default."
  fi
}

function configure_git_user() {
  echo "🔧 Configuring Git user"
  # Check if Git user name and email are already set
  GIT_USER_NAME=$(git config --get user.name)
  GIT_USER_EMAIL=$(git config --get user.email)

  if [ -z "$GIT_USER_NAME" ]; then
    read -p "Enter your Git user name: " GIT_USER_NAME
    git config user.name "$GIT_USER_NAME" || { echo "Failed to set Git user name"; exit 1; }
    echo "✅ Git user name configured."
  else
    echo "ℹ️ Git user name is already set to '$GIT_USER_NAME'."
  fi

  if [ -z "$GIT_USER_EMAIL" ]; then
    read -p "Enter your Git user email: " GIT_USER_EMAIL
    git config user.email "$GIT_USER_EMAIL" || { echo "Failed to set Git user email"; exit 1; }
    echo "✅ Git user email configured."
  else
    echo "ℹ️ Git user email is already set to '$GIT_USER_EMAIL'."
  fi
}

# Function to commit changes to Git, accepts a commit message
function commit_changes() {
  COMMIT_MESSAGE=$1
  if [ -z "$COMMIT_MESSAGE" ]; then
    echo "❌ Commit message is required."
    return 1
  fi
  git add . || { echo "Failed to stage files"; exit 1; }
  git commit -m "$COMMIT_MESSAGE" || { echo "Failed to create commit"; exit 1; }
}

# Add a script to delete all files except scaffold-templates folder and scaffold-react-ts.sh
function clean_workspace() {
  echo "🧹 Cleaning workspace"
  echo ""
  echo "⚠️ WARNING: This will delete all files except scaffold-templates and scaffold-react-ts.sh."
  read -p "Are you sure you want to clean the workspace? (y/n): " CONFIRMATION
  if [[ "$CONFIRMATION" =~ ^[Yy]$ ]]; then
    find . -mindepth 1 -maxdepth 1 -not -name 'scaffold-react-ts.sh' -not -name 'scaffold-templates' -exec rm -rf {} +
    echo ""
    echo "✅ Workspace cleaned."
  else
    echo ""
    echo "❌ Clean up aborted."
  fi
}


function clean_self() {
  echo "🧹 Cleaning Scaffolding setup files"
  echo ""
  echo "⚠️ WARNING: This will delete files in scaffold-templates and scaffold-react-ts.sh."
  read -p "Are you sure you want to continue? (y/n): " CONFIRMATION
  if [[ "$CONFIRMATION" =~ ^[Yy]$ ]]; then
    find . -mindepth 1 -maxdepth 1 -name 'scaffold-react-ts.sh' -name 'scaffold-templates' -exec rm -rf {} +
    echo ""
    echo "✅ Scaffold Setup cleaned."
  else
    echo ""
    echo "❌ Clean up aborted."
  fi
}

// function that will print a beautiful line on terminal
function print_line() {
  LINE_LENGTH=60
  LINE_CHAR="*"
  printf "\n%${LINE_LENGTH}s\n\n" | tr ' ' "$LINE_CHAR"
}

# Add a command-line interface to invoke clean_workspace
if [ "$1" == "clean" ]; then
  print_line
  clean_workspace
  print_line
  exit 0
fi

# Add a command-line interface to invoke clean_self
if [ "$1" == "clean-self" ]; then
  print_line
  clean_workspace
  print_line
  exit 0
fi

# Main script execution
check_project_name "$1"
print_line
create_vite_project
print_line
scaffold_folder_structure
print_line
install_dependencies
print_line
configure_linting
print_line
configure_vitest
print_line
initialize_storybook
print_line
configure_project_files
print_line
initialize_git
print_line
configure_git_user
print_line
setup_husky_lint_staged
print_line
commit_changes "Initial commit"
print_line

# Final message
echo "✅ Project '$PROJECT_NAME' scaffolded successfully!"