---
name: platform-feature-workflow-coordinate
description: Coordinate end-to-end Salesforce feature delivery across multiple installed Salesforce skills. Use when the user asks to build or modify a business feature or workflow that spans more than one component type, such as custom objects, fields, validation rules, tabs, FlexiPages, Apex, tests, data setup, retrieval, or deployment, and the work should be executed in dependency order.
---

# Coordinate Salesforce Feature Work

Coordinate multi-step Salesforce requests by selecting the smallest set of installed skills and running them in dependency order. Prefer delegation to an existing Salesforce skill over inventing new rules.

## Gather Inputs

Infer or confirm:

- Business outcome
- Net-new build, enhancement, bug fix, or operational task
- Component types involved
- The current default target org alias from `sf org list`
- Whether the local project may be stale relative to the org
- Whether the user expects retrieval, test execution, deployment, or data seeding
- Whether the implemented ticket should update `manifest/package.xml` to include newly added or retrieved metadata

When the request is clear enough to proceed, act without unnecessary questions.

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
4. After implementing a ticket, load `platform-metadata-api-context-get` before completion if `manifest/package.xml` or other metadata XML must be updated to reflect delivered components.
5. Load `platform-docs-get` only when official Salesforce documentation is needed to resolve uncertainty.
6. When deployment or deployment validation is required, first run `sf org list --json` and identify the alias on the org where `isDefaultUsername` is `true`. Use that alias for subsequent `--target-org` arguments instead of a placeholder.

Do not bypass a specialized installed skill for a metadata type it covers.

## Use This Execution Order

Apply only the phases that the request needs:

1. Sync source of truth
   - Use `platform-metadata-retrieve` when org metadata is likely newer than local files.
   - Inspect local conventions before introducing new files.
2. Model data
   - Use `platform-custom-object-generate`.
   - Use `platform-custom-field-generate`.
   - Use `platform-validation-rule-generate` and `platform-sharing-rules-generate` when business rules require them.
3. Build user access and navigation
   - Use `platform-permission-set-generate`.
   - Use `platform-custom-tab-generate`.
   - Use `platform-list-view-generate`.
   - Use `platform-flexipage-generate`.
   - Use `platform-custom-application-generate` when the feature needs app-level navigation.
4. Add code and automation
   - Use `platform-apex-generate` for Apex classes and triggers.
   - Use `experience-lwc-generate` for Lightning Web Components.
   - Use `platform-custom-lightning-type-generate` for CLT or Agentforce type work.
   - Use `platform-tracing-configure` or `platform-tracing-agentforce-configure` only when observability settings are part of the request.
5. Prepare data and verification
   - Use `platform-soql-query` to define or optimize queries.
   - Use `platform-data-manage` for seed data, updates, cleanup, import, or export.
   - Use `platform-apex-test-run` when the work requires Apex test execution, coverage checks, or test-fix loops.
   - When the request includes deployment readiness, run `sf org list --json`, resolve the current default org alias, then run `sf project deploy validate --manifest manifest/package.xml --test-level RunLocalTests --target-org <resolved-alias>` before any deploy step.
6. Ship changes
   - Use `platform-metadata-deploy` when the user expects deployment.
   - Use `platform-metadata-api-context-get` to update `manifest/package.xml` with implemented or retrieved metadata before closing the ticket when package maintenance is expected.
   - Do not deploy until the manifest validation command against the resolved default org alias has been attempted, unless the environment blocks CLI access.
   - Retrieve again only when post-deploy org-side changes must be synchronized locally.

## Apply Workflow Patterns

Use the narrowest matching pattern:

- For a net-new business feature:
  - Retrieve if needed.
  - Build metadata foundations first.
  - Add UI metadata next.
  - Add Apex or LWC only after supporting metadata exists.
  - Run tests, validate with `sf project deploy validate --manifest manifest/package.xml --test-level RunLocalTests --target-org <resolved-default-alias>`, and deploy last.
- For an enhancement to an existing feature:
  - Retrieve if local state may be stale.
  - Diff the current implementation.
  - Modify the smallest affected metadata or code surface.
  - Update `manifest/package.xml` through `platform-metadata-api-context-get` when the ticket adds or retrieves metadata that should be tracked in the manifest.
  - Re-run only the validations and tests relevant to the touched areas, including the manifest validation command when deployment is expected.
- For a production issue:
  - Use logs, retrieval, tests, or SOQL first to reproduce or isolate the problem.
  - Patch the narrowest responsible layer.
  - Validate, including the manifest validation command against the resolved default org alias when deployment is expected, then deploy.

## Enforce Handoffs

- When `platform-apex-generate` creates or edits production Apex, also follow its requirement to use `platform-apex-test-generate` for test class creation.
- When a ticket has been implemented and the delivered metadata should be reflected in `manifest/package.xml`, hand off to `platform-metadata-api-context-get` to make that XML update before reporting completion.
- When a selected skill requires deployment validation, do not report completion before running `sf org list --json`, resolving the current default org alias, and attempting `sf project deploy validate --manifest manifest/package.xml --test-level RunLocalTests --target-org <resolved-alias>`, unless the environment blocks it.
- When a request expands into a complete app build, hand off to `platform-lightning-app-coordinate` instead of re-planning the same dependency graph here.

## Stop Conditions

Stop and ask the user only when one of these is true:

- The request is too vague to identify the target business feature.
- Requirements conflict in a way that changes architecture or security.
- Deployment validation is required but `sf org list --json` does not identify a current default org alias.
- The needed org action cannot be performed without approval or credentials.

Otherwise, make the smallest reasonable assumption and continue.

## Report Format

Return a concise delivery report with:

- Request classification
- Skills loaded
- Execution order used
- Files created or changed
- Validation, test, retrieval, and deploy actions attempted
- Remaining risks or blocked org actions
