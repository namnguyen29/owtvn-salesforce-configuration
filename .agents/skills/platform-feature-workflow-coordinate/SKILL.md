---
name: platform-feature-workflow-coordinate
description: Coordinate end-to-end Salesforce feature delivery across multiple installed Salesforce skills. Use when the user asks to build or modify a business feature or workflow that spans more than one component type, such as custom objects, fields, validation rules, tabs, FlexiPages, Apex, tests, data setup, retrieval, or validation, and the work should be executed in dependency order.
---

# Coordinate Salesforce Feature Work

Coordinate multi-step Salesforce requests by selecting the smallest set of installed skills and running them in dependency order. Prefer delegation to an existing Salesforce skill over inventing new rules.

Keep this file as the coordinator. Load the detailed references only when they match the ticket:

- Read `references/requirement-analysis.md` before changing files to classify the ticket, identify deliverables, and decide whether metadata, Apex, LWC, tests, retrieval, or manifest updates are required.
- Read `references/workflow.md` when the request spans multiple component types and you need the phase order for implementation.
- Read `references/validation-and-handoff.md` when the ticket is implemented or when the user expects validation readiness.

## Route the Request

Classify the request before changing files:

- Use `platform-lightning-app-coordinate` when the request is a complete Lightning app or business solution with multiple connected metadata types.
- Use a single specialized skill when the request touches only one domain:
  - `platform-custom-object-generate`
  - `platform-custom-field-generate`
  - `platform-validation-rule-generate`
  - `platform-sharing-rules-generate`
  - `platform-custom-tab-generate`
  - `platform-list-view-generate`
  - `platform-flexipage-generate`
  - `platform-custom-application-generate`
  - `platform-permission-set-generate`
  - `platform-apex-generate`
  - `experience-lwc-generate`
  - `platform-soql-query`
  - `platform-data-manage`
  - `platform-trust-archive-manage`
  - `platform-apex-logs-debug`
- Continue with this coordinator when the request spans two or more domains or needs execution sequencing.

## Load Skills Deliberately

For every selected skill:

1. Read its `SKILL.md` completely before acting.
2. Follow its required validation or downstream delegation rules.
3. Load `platform-metadata-api-context-get` when authoring or editing metadata XML directly, or when a selected skill requires Metadata API confirmation.
4. Load `platform-docs-get` only when official Salesforce documentation is needed to resolve uncertainty.
5. Do not bypass a specialized installed skill for a metadata type it covers.

## Apply Core Rules

- Start with requirement analysis and identify the smallest valid delivery slice before editing code or metadata.
- Generate metadata first when the ticket introduces or changes Salesforce configuration that code depends on.
- Generate Apex only when the ticket requires server-side logic, automation, controllers, integrations, or tests.
- Generate custom LWC only when the ticket explicitly needs custom UI behavior or Lightning component implementation.
- Generate Apex tests when production Apex is created or changed, using `platform-apex-test-generate`.
- Update `manifest/package.xml` when the delivered metadata should be tracked in the manifest.
- Treat deployment validation as the final AI-executed step. Deployment itself remains a developer action and must not be executed by the LLM or AI agent.

## Enforce Handoffs

- When `platform-apex-generate` creates or edits production Apex, also follow its requirement to use `platform-apex-test-generate` for test class creation.
- When the ticket needs implementation sequencing, follow `references/workflow.md` instead of improvising a new order.
- When the ticket is implemented or the user asks for validation readiness, follow `references/validation-and-handoff.md`.
- When a request expands into a complete app build, hand off to `platform-lightning-app-coordinate` instead of re-planning the same dependency graph here.

## Stop Conditions

Stop and ask the user only when one of these is true:

- The request is too vague to identify the target business feature.
- Requirements conflict in a way that changes architecture or security.
- Validation readiness is required but `sf org list --json` does not identify a current default org alias.
- The needed org action cannot be performed without approval or credentials.

Otherwise, make the smallest reasonable assumption and continue.

## Report Format

Return a concise delivery report with:

- Request classification
- Skills loaded
- Workflow phases used
- Files created or changed
- Validation, test, retrieval, and manifest actions attempted
- Remaining risks or blocked org actions
