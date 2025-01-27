# Project Structure

This project follows a modular structure to keep the codebase clean, maintainable, and scalable. Below is an overview of the directory structure:

```
.
├── application     # Core application logic, such as services, state management, and controllers
├── config          # Configuration files (e.g., environment variables, app settings)
├── features        # Feature-specific modules, with each feature having its own folder for separation
└── shared          # Shared resources such as utilities, constants, and reusable components
```

## Description

- **application**: Contains business logic, which is used in multiple features
- **config**: Stores configuration files to centralize settings like API keys and environment variables.
- **features**: Each subdirectory represents a self-contained feature/module, keeping feature-specific code isolated.
- **shared**: Houses reusable components, helper functions, constants, and styles used across multiple features.

This structure ensures that the project remains modular, making it easier to add or modify features while maintaining clear boundaries between different parts of the application.
