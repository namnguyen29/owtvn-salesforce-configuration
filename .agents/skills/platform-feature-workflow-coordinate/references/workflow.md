# Workflow

Use this phase order for multi-domain Salesforce tickets. Apply only the phases that the request needs.

## Phase 1: Analyze and Route

- Read the ticket and classify it with `requirement-analysis.md`.
- Select the smallest set of specialized skills needed for the work.
- Inspect local project conventions before introducing new files.

## Phase 2: Sync Source of Truth

- Use `platform-metadata-retrieve` when org metadata is likely newer than local files.
- Retrieve only the metadata needed for the feature unless the user requested a broader sync.

## Phase 3: Generate Metadata Foundations

- Use `platform-custom-object-generate` for new or changed custom objects.
- Use `platform-custom-field-generate` for fields and relationships.
- Use `platform-validation-rule-generate` and `platform-sharing-rules-generate` when business rules require them.
- Use `platform-permission-set-generate`, `platform-custom-tab-generate`, `platform-list-view-generate`, `platform-flexipage-generate`, and `platform-custom-application-generate` as the feature requires.

Create prerequisite metadata before adding code that depends on it.

## Phase 4: Generate Code and Automation

- Use `platform-apex-generate` for Apex classes, triggers, controllers, and automation.
- Use `experience-lwc-generate` only when the ticket explicitly needs custom LWC.
- Use `platform-custom-lightning-type-generate` for CLT or Agentforce type work.
- Use tracing or observability skills only when the request explicitly includes those settings.

Do not generate code when standard metadata can satisfy the requirement.

## Phase 5: Generate Tests and Supporting Data

- Use `platform-apex-test-generate` when production Apex is created or modified.
- Use `platform-apex-test-run` when the work requires Apex test execution, coverage checks, or a test-fix loop.
- Use `platform-soql-query` to define or optimize queries needed for verification.
- Use `platform-data-manage` for seed data, updates, cleanup, import, or export.

## Phase 6: Maintain Manifest

- Use `platform-metadata-api-context-get` before editing `manifest/package.xml`.
- Add or maintain entries for metadata delivered by the ticket when the manifest should track them.

## Phase 7: Validate Readiness

- Follow `validation-and-handoff.md`.
- Treat validation as the final AI-executed step for the ticket.

## Phase 8: Hand Off Deployment

- Do not run deployment commands.
- Report the validation result, the resolved default org alias, and any remaining risks.
- Leave actual deployment to the developer.
