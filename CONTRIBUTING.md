# Contributing to Daytistics

We appreciate your interest in contributing to Daytistics! This document outlines the guidelines for submitting bug reports, feature suggestions, and code changes.

## How to Contribute

There are several ways you can contribute to Daytistics:

- **Reporting Bugs**:
  If you encounter a bug, please search for existing issues on the issue tracker first. If you can't find a duplicate issue, open a new one. Provide a clear description of the bug, including steps to reproduce it if possible. Screenshots, logs, or code snippets can also be helpful.
- **Suggesting Features**:
  Do you have an idea on how Daytistics can be improved? Share your thoughts by opening an issue on the issue tracker. Describe the proposed feature in detail, including its benefits and potential implementation considerations.
- **Submitting Pull Requests**:
  If you'd like to contribute code changes, fork the Daytistics repository on GitHub. Make your changes on your local fork and create a pull request to the main repository. Ensure your code adheres to our project structure and style guidelines. Write clear and concise commit messages that describe your changes.

> [!WARNING]  
> Before working on an issue, ensure it has the approved label. Without it, there's a risk that the issue may not be merged, even if you've implemented it. Also make sure that no one else is working on the issue.

## Coding Guidelines

Things need to be done before this Pull Request can be merged. Your CI also checks most of them automatically and will fail if something is not fulfilled. Please adhere to the following guidelines:

**Basic**

- **Code Formatting**: Code must be well-formatted and follow the project's style guidelines. You can use `dart format` to ensure correct formatting.
- **No Warnings**: Code should not produce any warnings. You can check for warnings using `dart analyze`.
- **Passing Tests**: All existing tests must pass successfully. You can run the tests with `dart test`.

**Best Practices**

- **Writing Tests**: When adding new features or modifying existing code, consider adding unit tests to prevent regressions. Refer to the Dart documentation for guidance on writing tests: https://dart.dev/guides/testing
- **Performance**: If your changes might impact performance, consider adding performance benchmarks.
- **Clear and Concise Commit Messages**: Use clear and concise commit messages that describe the changes you've made.
- **Code Style**: Adhere to consistent coding style throughout your contributions.
- **Documentation**: If your changes introduce new functionality, consider updating the relevant documentation.

## Additional Information

We encourage you to comment on existing issues and pull requests to share your thoughts and provide feedback. Feel free to ask questions in the issue tracker or reach out to the project maintainers if you need assistance. Before submitting a large contribution, consider opening an issue or discussing your approach with us via the GitHub Issues.
