# SwiftSweep

[![Swift](https://github.com/mikeger/SwiftSweep/actions/workflows/test.yml/badge.svg)](https://github.com/mikeger/SwiftSweep/actions/workflows/test.yml)

SwiftSweep is a tool designed to help you identify and remove unused symbols (functions, classes, variables, etc.) from your Swift codebase. By keeping your code clean and free of unused elements, you improve maintainability, reduce potential bugs, and decrease compile times.

**Note:** SwiftSweep is currently in **beta**. Please be aware of its limitations and use caution when removing code based on its output.

## Table of Contents

- [Why Remove Unused Code Continuously](#why-remove-unused-code-continuously)
- [Installation](#installation)
- [Usage](#usage)
  - [Initial Setup](#initial-setup)
  - [Creating a Known False Positives List](#creating-a-known-false-positives-list)
  - [Filtering Results](#filtering-results)
  - [Automating Detection](#automating-detection)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)
- [License](#license)

---

## Why Remove Unused Code Continuously

Continuously removing unused code from your codebase is essential for several reasons:

- **Improved Readability:** Clean code is easier to read and understand, making it simpler for new developers to onboard and for existing developers to maintain the code.
- **Reduced Complexity:** Eliminating unused code reduces the overall complexity of the codebase, which can help prevent bugs and unintended interactions.
- **Better Performance:** Less code means faster compile times and potentially improved runtime performance due to smaller binaries.
- **Security:** Unused code might contain vulnerabilities that could be exploited. Removing it reduces the attack surface.
- **Resource Optimization:** Reduces the memory footprint and storage requirements for your application.

---

## Installation

SwiftSweep can be installed using [Mint](https://github.com/yonaskolb/Mint), a package manager that installs and runs Swift command-line tools.

### Prerequisites

- Swift 5.5 or later
- Mint installed on your system

### Install with Mint

```bash
mint install mikeger/SwiftSweep
```

---

## Usage

SwiftSweep analyzes your Swift codebase to identify symbols that are potentially unused. The output is a list of symbols suspected to be unused.

### Basic Command

```bash
swift-sweep ./YourAppDirectory
```

This command will analyze all Swift files in the specified directory and output a list of unused symbols.

---

### Initial Setup

When running SwiftSweep for the first time, you might get a list of symbols that are actually used but are reported as unused due to certain limitations (see [Known Limitations](#known-limitations)).

1. **Run SwiftSweep:**

   ```bash
   swift-sweep ./YourAppDirectory
   ```

2. **Review the Output:**

   Examine the list of symbols and identify any false positives.

3. **Create a List of Known False Positives:**

   Save the list of known false positives in a text file within your repository, e.g., `known_unused.txt`.

   ```txt
   SymbolOne, SymbolTwo, SymbolThree
   ```

---

### Creating a Known False Positives List

Having a list of known false positives helps you filter out symbols that are incorrectly identified as unused due to the tool's limitations.

1. **Identify False Positives:**

   From the initial run, determine which symbols are actually in use.

2. **Save Them to `known_unused.txt`:**

   ```txt
   SymbolOne, SymbolTwo, SymbolThree
   ```

3. **Commit `known_unused.txt` to Your Repository:**

   This ensures the list is version-controlled and shared among your team.

---

### Filtering Results

You can use the `--ignore-regex` option to filter out symbols from the results using regular expressions.

#### Example Command

```bash
swift-sweep ./YourAppDirectory --ignore-regex "[a-zA-Z0-9]*Test[a-zA-Z0-9]*|$(cat known_unused.txt | sed 's/, /|/g')"
```

**Explanation:**

- `--ignore-regex`: Specifies a regular expression to ignore certain symbols.
- `"[a-zA-Z0-9]*Test[a-zA-Z0-9]*"`: Ignores any symbols that contain the word "Test".
- ```bash
  $(cat known_unused.txt | sed 's/, /|/g')
  ```
  - Reads the `known_unused.txt` file.
  - Replaces `, ` with `|` to form a regex pattern.
  - Integrates the pattern into the `--ignore-regex` option.

---

### Automating Detection

To continuously monitor for new unused symbols, you can set up a nightly job that runs SwiftSweep and alerts you if new symbols are detected.

#### Steps:

1. **Create a Script:**

   ```bash
   #!/bin/bash
   swift-sweep ./YourAppDirectory --ignore-regex "[a-zA-Z0-9]*Test[a-zA-Z0-9]*|$(cat known_unused.txt | sed 's/, /|/g')" > unused_symbols.txt
   if [ -s unused_symbols.txt ]; then
       echo "New unused symbols detected:"
       cat unused_symbols.txt
       # Optionally, send an email or Slack notification
   else
       echo "No new unused symbols detected."
   fi
   ```

2. **Set Up a Cron Job or CI Pipeline:**

   Configure your CI/CD system to run the script nightly.

3. **Review and Act:**

   If new symbols are detected, review them and decide whether to remove them or update your `known_unused.txt` file.

---

## Known Limitations

- **Beta Software:** SwiftSweep is currently in beta. Expect potential bugs and incomplete features.
- **External Libraries:** The tool may incorrectly identify protocol methods from external libraries as unused.
- **Reflection and Dynamic Usage:** Symbols used via reflection or dynamically constructed names may not be detected as used.
- **False Positives:** Some symbols might be reported as unused even if they are in use due to analysis limitations.
- **False Negatives:** The tool currently lacks the capability to distinguish between actual usage of a symbol and mere mentions of its name in the codebase. Consequently, if a symbol’s name appears anywhere—including in comments or string literals—it is considered as being used. This limitation can lead to the tool failing to identify unused symbols, especially for short or commonly used names that may frequently appear without representing functional usage.

---

## Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue or submit a pull request.

1. **Fork the Repository**
2. **Create a Feature Branch**
3. **Commit Your Changes**
4. **Push to the Branch**
5. **Open a Pull Request**

---

## Authors

- 🇺🇦 Michael Gerasymenko <mike (at) gera.cx>

---

## License

SwiftSweep is released under the [MIT License](LICENSE).

---

*Disclaimer: Use this tool at your own risk. Always review the output before removing code to prevent accidental deletion of necessary code.*
