# React TypeScript Project Scaffolding

Welcome to the **React TypeScript Project Scaffolding** script! This script is designed to help you quickly set up a modern React project with TypeScript, complete with essential tools and configurations for a seamless development experience.

---

## Features

- **Vite Integration**: Quickly bootstrap a React TypeScript project using Vite.
- **Folder Structure**: Automatically creates a well-organized folder structure (`src/components`, `src/pages`, `src/hooks`, etc.).
- **Dependency Management**: Installs all required dependencies and devDependencies from a predefined list.
- **Linting and Formatting**: Configures ESLint and Prettier for consistent code quality.
- **Husky and lint-staged**: Sets up pre-commit hooks to ensure code quality before committing.
- **Testing**: Configures Vitest and adds a sample test file.
- **Storybook**: Initializes Storybook for building and testing UI components.
- **Docker Support**: Includes a Dockerfile template for containerizing your application.
- **Git Integration**: Initializes a Git repository with a `main` branch and sets up user configuration.
- **Customizable README**: Generates a project-specific README file.
- **Workspace Cleanup**: Offers options to clean the workspace or remove scaffolding setup files.

---

## How to Use

1. **Download the Repository**:  
   Click on the green "Code" button at the top of this repository page and select "Download ZIP". Extract the downloaded ZIP file to your desired location.
2. **Run the Script**:
   ```bash
   bash scaffold-react-ts.sh
   ```
3. **Follow the Prompts**: The script will guide you through the setup process, including Git configuration and workspace cleanup options.
4. **Start Developing**: Once the script completes, your project is ready to go!

---

## Additional Commands

- **Clean Workspace**:
  Removes all files except `scaffold-templates` and `scaffold-react-ts.sh`.

  ```bash
  bash scaffold-react-ts.sh clean
  ```

- **Clean Scaffolding Setup**:
  Deletes `scaffold-templates` and `scaffold-react-ts.sh`.
  ```bash
  bash scaffold-react-ts.sh clean-self
  ```

---

## Notes

- Ensure you have **Node.js** and **npm** installed before running the script.
- The script uses `jq` for JSON processing. Make sure it is installed on your system.

---

Happy coding! 🚀
