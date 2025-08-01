# Contributing to BenGQL

Thank you for considering contributing to BenGQL!
We welcome contributions of all kinds, including new automated testing tools, new case studies integration, new analysis scripts, bug reports, feature requests, documentation improvements, and code contributions.

## How to Contribute

### 1. Fork the Repository
Click the "Fork" button at the top right of the repository page to create your own copy.

### 2. Create a Branch
Create a new branch for your changes:
```bash
git checkout -b my-feature
```

### 3. Make Your Changes
Make your changes in your branch.
Please follow the existing guidelines in the documentation for adding new case studies, tools, or analysis scripts.

### 4. Test Your Changes
Ensure all tests pass and your changes do not break existing functionality.
If something is not behaving as expected, please contact project maintainers for guidance.

### 5. Commit and Push
Commit your changes with a clear message and push to your fork:
```bash
git add .
git commit -m "Describe your change"
git push origin my-feature
```

All commit messages **must** start with one of the following tags:

- `[tool/"tool_name"]`
- `[case_study/"case_study_name"]`
- `[analysis/"script"]`
- `[docs]`
- `[infrastructure]`
- `[bug]`
- `[feat]`

** Example commit message:**
```[tool/EvoMaster] New tool integration```
```

### 6. Open a Pull Request
Go to the original repository and open a Pull Request from your branch. Please describe your changes and reference any related issues.

## Reporting Issues

If you find a bug or have a feature request, please [open an issue](https://github.com/your-org/BenGQL/issues) and provide as much detail as possible.

## Code Style

- Use clear, descriptive commit messages.
- Follow the existing formatting and naming conventions.
- Add comments where necessary.

## Community

Be respectful and constructive in all interactions. See our [Code of Conduct](CODE_OF_CONDUCT.md).

---

Thank you for helping make BenGQL better!