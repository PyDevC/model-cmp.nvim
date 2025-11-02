# How to contribute

First of all Thanks for considering contributing to model-cmp.nvim.

<!-- toc -->
- [Code Rules](#code-rules)
- [How to make changes](#how-to-make-changes)
- [Build and Test](#build-and-test)
- [How to Raise Issue](#how-to-raise-issue)
- [Commit message Rules](#commit-message-rules)
- [Writing tests](#writing-tests)
    - [Individual files](#individual-files)
    - [Integration Tests](#integration-tests)

## Code Rules

1. Local functions should not be assigned to variables as
```lua
local helloworld = function()
    print("Hello, World!")
end
```
2. Constants should be All UPPERCASE
3. Log every important state of a variable or a function output, you can choose not to log in the trivial case where the function output is not bound to change under any circumstances.
4. For all module exposed functions write `---@param` and `---@return` for intellisense to show the types correctly.
5. Every table should have a type associated to it. Make class for them, and for minor cases write alias.

## How to make changes

Before making any change first clone and test your repo by [checking test](#build-and-test).
```bash
git clone https://github.com/PyDevC/model-cmp.nvim
cd model-cmp.nvim
```

Create a branch before writing any changes. The name of the branch should not be more than four words and should be kabab case. Ex: new-feature.

After writing your changes test them with available [tests](#build-and-test), if the current changes require new tests or modificaiton of existing tests then, write the sample test and create a PR for further discussion to the changes.

After commiting all your w.r.t [commit message rules](#commit-message-rules), create a pull request to the main branch and get your changes merged by the approval of the code owner.

*NOTE:* Do not create a PR without raising an Issue.

## Build and Test

Model-cmp.nvim uses some tools for linting, formating, and testing. Before you submit any of you changes you should run the make command for formatting linting and testing your code. To submit all your changes you can run `make all` in you termainl to get run `fmt, lint, test, ready-commit`.

*Warning:* Running `make all` in your terminal will stage all your changes and open the diff and commit window for you to commit.

- Formating is done with the help of stylua.
- Linting is done with the help of luacheck
- Tests are preformed with plenary.nvim

You can check Makefile for all the `make` targets.

## How to Raise Issue

First check if there is any issue from your side if its a bug report.

We already have templates for Both feature request and bug report kind of issues, you check the label lists to tag the correct label for the issue.

Make sure you check whether there is any similar issue already present in the Issue section. If you find that some issue is related to someother thing feel free to tag it in the issue itself.

You can create a PR right after raising the Issue.

## Commit message Rules

Your commit message determines how well I can understand the changes made in a commit. Also this makes it easier for me to search through the commit logs.

Your commit message should have a prefix, module(optional), issue number that it closes, reason for making such changes (optional)

```markdown
[Feat][test]: This is testing something

Fixes Issue: #12

These things were overlooked when working in the virutal text
```

List of prefixes:
- [Bug] - for making bug fixes
- [Feat] - for new features
- [BE] - for formatting and better structuring of code
- [Edge Case] - for commits related to the issues with edge-case label
- [Other] - Everything else

List of module:
- Can be a file name (if changes are related to one particular file)
- [test] - when writing tests
- [modelapi] - if changes are in modelapi folder

## Writing tests

The testing structure is underdevelopment you can write tests based on what is going around in the test model at the moment.

### Individual files

will be updated soon

### Integration Tests

will be updated soon
