# Repository Guidelines

## Project Structure & Module Organization
This repository is a Salesforce DX project. The default package directory is `force-app/`, with metadata under `force-app/main/default/`. Current top-level metadata folders include `classes/`, `triggers/`, and `tabs/`; add new Salesforce source in the matching metadata folder rather than creating ad hoc directories.

Use `config/` for scratch org definitions such as `config/project-scratch-def.json`, and `scripts/` for reusable SOQL and anonymous Apex helpers like `scripts/soql/account.soql` and `scripts/apex/hello.apex`. Project-wide tooling lives in `package.json`, `eslint.config.js`, `jest.config.js`, and `sfdx-project.json`.

## Build, Test, and Development Commands
- `npm run lint` checks JavaScript in Aura and LWC bundles with ESLint.
- `npm test` runs the configured unit-test entry point.
- `npm run test:unit`, `npm run test:unit:watch`, `npm run test:unit:debug`, and `npm run test:unit:coverage` run LWC Jest tests in normal, watch, debug, and coverage modes.
- `npm run prettier` formats supported source files, including Apex and metadata XML.
- `npm run prettier:verify` checks formatting without rewriting files.
- `sf project deploy start` deploys local metadata to an authorized org.
- `sf project retrieve start` pulls metadata changes back into `force-app/`.

## Coding Style & Naming Conventions
Prettier is the source of truth. Use 2 spaces for JS, JSON, YAML, Markdown, HTML, and XML; Apex (`*.cls`, `*.trigger`) is formatted with 4 spaces. Keep line length within the configured 120 characters.

Follow Salesforce naming conventions: Apex classes in `PascalCase`, triggers named `<ObjectName>Trigger`, and LWC bundle folders in `camelCase`. Run `npm run prettier` before opening a PR.

## Testing Guidelines
LWC tests use `@salesforce/sfdx-lwc-jest`. Name test files `*.test.js` under `**/lwc/**` so they match the ESLint and Jest setup. For Apex, add focused test classes named `*Test.cls` beside the feature they cover and validate behavior in the target org with `sf apex run test` when applicable.

## Commit & Pull Request Guidelines
Current history uses Conventional Commit prefixes, for example `feat: init agent skills for project`. Keep commits small, imperative, and scoped.

PRs should include a short summary, impacted metadata paths, deployment or test commands run, and screenshots for UI changes. Link the related work item or issue when one exists.
