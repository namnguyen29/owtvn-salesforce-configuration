# Requirement Analysis

Analyze the ticket before editing files. Convert the request into explicit implementation decisions.

## Capture the Request Shape

Infer or confirm:

- Business outcome
- Net-new build, enhancement, bug fix, or operational task
- Metadata types involved
- Whether the local project may be stale relative to the org
- Whether the user expects retrieval, test execution, validation readiness, or developer-led deployment
- Whether `manifest/package.xml` should be updated to track new or changed metadata

When the request is clear enough to proceed, act without unnecessary questions.

## Decide What Must Be Generated

Use these rules:

- Generate metadata when the ticket introduces or changes Salesforce configuration, data model, security, navigation, page layout, list views, or app structure.
- Generate Apex when the ticket requires business logic, triggers, services, controllers, integrations, invocable actions, queueables, batch jobs, or test classes.
- Generate custom LWC only when the ticket explicitly calls for a custom Lightning Web Component, custom UI behavior, or a UI surface that standard metadata cannot satisfy.
- Generate Apex tests when production Apex is added or modified.
- Generate LWC tests when custom LWC behavior is added or modified and the component warrants Jest coverage under the selected LWC skill.

Prefer the smallest set of generated artifacts that satisfies the ticket.

## Decide Whether Retrieval Comes First

Retrieve first when any of these are true:

- The ticket modifies existing org metadata and local state may be stale.
- The user indicates recent org-side changes.
- You need the current org definition to safely extend an object, FlexiPage, tab, permission set, or similar metadata.

Skip retrieval when the work is clearly net-new and local source is already the intended source of truth.

## Decide Whether Manifest Maintenance Is Required

Update `manifest/package.xml` when:

- The ticket adds new metadata that should be tracked for validation or packaging.
- The ticket retrieves metadata that must remain represented in the manifest.
- The repository workflow expects the manifest to reflect delivered components.

Use `platform-metadata-api-context-get` before editing manifest XML directly.
