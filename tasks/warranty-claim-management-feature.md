# Ticket: Build Warranty Claim Management Feature

## Objective

Create a new Salesforce feature that allows service users to manage customer warranty claims and view a summary of warranty claim records directly in Salesforce.

This implementation should validate the Salesforce Skill Coordinator workflow by generating required metadata, custom code, permissions, deployment package updates, and validation steps from a single business requirement.

---

# Requirements

## 1. Custom Object

Create a new custom object:

**Object Name:** Warranty Claim
**API Name:** Warranty_Claim__c

The object should be available as a Salesforce tab.

---

## 2. Custom Fields

Create the following fields for Warranty Claim:

### Status

**Field API Name:** Status__c
**Type:** Picklist

Values:

* New
* In Progress
* Approved
* Rejected

---

### Claim Date

**Field API Name:** Claim_Date__c
**Type:** Date

---

### Claim Amount

**Field API Name:** Claim_Amount__c
**Type:** Currency

---

### Customer

**Field API Name:** Customer__c
**Type:** Lookup(Account)

A Warranty Claim should be linked to an Account.

---

## 3. Permission Configuration

Create a new permission set:

**Permission Set Name:** Warranty_Claim_User

The permission set should provide:

Object access:

Warranty Claim:

* Read
* Create
* Edit

Field access:

All custom fields:

* Read
* Edit

---

## 4. Lightning Web Component

Create a Lightning Web Component:

**Component Name:** warrantyClaimSummary

The component should display:

* Total number of warranty claims
* Number of Approved claims
* Number of Pending/In Progress claims

The component should include:

* Refresh button to reload claim statistics
* Salesforce Lightning Design System styling

The component should be available on:

* Lightning App Page
* Record Page

---

## 5. Apex Controller

Create an Apex controller:

**Class Name:** WarrantyClaimSummaryController

Responsibilities:

* Query Warranty Claim records
* Calculate summary statistics
* Return data to the LWC component

Implementation requirements:

* Follow Apex security best practices
* Respect object and field permissions where applicable
* Use cacheable methods where suitable

---

## 6. Apex Test

Create test class:

**Class Name:** WarrantyClaimSummaryControllerTest

Test requirements:

* Create required test data
* Verify summary calculation logic
* Verify Apex methods execute successfully
* Achieve required Salesforce code coverage

---

## 7. Deployment Package

Update the deployment manifest.

The package should include:

* Custom Object
* Custom Fields
* Custom Tab
* Permission Set
* Lightning Web Component
* Apex Controller
* Apex Test Class

---

## 8. Validation

Before delivery:

Run:

* Salesforce deployment validation
* Apex test execution

Confirm:

* Metadata deploys successfully
* Apex tests pass
* LWC loads successfully
* Permission set provides required access

---

# Expected Result

A complete Salesforce feature bundle is generated from the requirement, including:

* Metadata configuration
* Custom development
* Security configuration
* Test coverage
* Deployment package

