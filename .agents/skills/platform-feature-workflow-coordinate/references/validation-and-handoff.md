# Validation And Handoff

Run this workflow after implementation is complete or when the user asks whether the ticket is ready.

## Resolve the Default Org

1. Run `sf org list --json`.
2. Read the JSON output.
3. Identify the org entry where `isDefaultUsername` is `true`.
4. Resolve the alias from that org entry and use it for subsequent `--target-org` arguments.

If no default org is present, stop and ask the user. Do not guess the target org.

## Validate the Manifest

Run this command with the resolved alias:

```bash
sf project deploy validate --manifest manifest/package.xml --test-level RunLocalTests --target-org <resolved-alias>
```

Rules:

- Run this only after implementation and manifest maintenance are complete.
- Treat this as the final AI-executed step for the ticket.
- Report the resolved alias used for validation.
- Report whether validation succeeded, failed, or was blocked by environment or credentials.

## Deployment Boundary

Deployment is not an AI responsibility in this workflow.

- Do not run `sf project deploy start`.
- Do not execute any production or sandbox deployment as part of ticket completion.
- Hand off to the developer after validation with the exact validation command outcome and any follow-up actions.

## Delivery Report

Include:

- Resolved default org alias
- Validation command attempted
- Validation outcome
- Tests or retrieval steps attempted earlier in the workflow
- Remaining manual deployment step for the developer
