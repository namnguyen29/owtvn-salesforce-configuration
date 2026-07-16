# Use Case: Unified Loyalty Re-engagement Campaign

## 1. Overview

A retail company stores customer information in Salesforce CRM and loyalty membership data in an external loyalty system.

The marketing team wants to identify loyalty members who have not made a purchase recently and send them a personalized re-engagement email. The email content should be based on the customer’s loyalty tier, loyalty points, and most recent purchase.

The solution will use Marketing Cloud Next and Data 360 to ingest data from multiple sources, unify customer profiles, create a target audience, and send personalized emails through a marketing campaign flow.

## 2. Business Objective

The objective is to create an automated re-engagement campaign that:

- Combines Salesforce CRM data with external loyalty data.
- Identifies records belonging to the same customer.
- Excludes customers who have not provided promotional email consent.
- Excludes customers who have purchased recently.
- Personalizes email content based on loyalty tier and purchase history.
- Reuses the same brand, email template, and content blocks across different customer segments.
- Tracks email delivery and engagement results.

## 3. Business Scenario

The company wants to contact loyalty members who have not made a purchase within the last 30 days.

Eligible customers receive different promotional content depending on their loyalty tier:

| Loyalty Tier | Example Offer                                       |
| ------------ | --------------------------------------------------- |
| Gold         | Exclusive discount or early access to a new product |
| Silver       | Medium-value discount or bonus loyalty points       |
| Bronze       | Entry-level discount or points multiplier           |
| Unknown      | Generic fallback promotion                          |

Customers with invalid email consent or a recent purchase must not receive the campaign email.

Create Purchase__c object!!

| Field           | Example             |
| --------------- | ------------------- |
| Contact         | Anna                |
| Product Name    | Wireless Headphones |
| Purchase Date   | 45 days ago         |
| Purchase Amount | 250                 |

## 4. Data Sources

| Data Source             | Object or Dataset      | Main Fields                                                        |
| ----------------------- | ---------------------- | ------------------------------------------------------------------ |
| Salesforce CRM          | Contact                | First Name, Last Name, Email                                       |
| Salesforce CRM          | `Purchase__c`          | Contact, Product Name, Purchase Date, Purchase Amount              |
| External loyalty source | Loyalty Member dataset | Loyalty ID, Email, Loyalty Tier, Loyalty Points, Join Date         |
| Marketing consent       | Consent records        | Contact Point, Communication Channel, Subscription, Consent Status |

For the training scenario, the external loyalty source can be simulated using a CSV file or a Salesforce custom object such as `Loyalty_Member__c`.

`Purchase__c` is used instead of Asset because it is easier to simulate purchase history, purchase dates, product names, and transaction amounts without configuring the complete Salesforce order management data model.

## 5. Customer Unification

Customer records from Salesforce CRM and the loyalty source are unified using the normalized email address.

The Identity Resolution ruleset should contain:

| Rule Type                     | Proposed Configuration                  |
| ----------------------------- | --------------------------------------- |
| Match Rule                    | Normalized Exact Email                  |
| First Name Reconciliation     | Most Recently Updated                   |
| Email Reconciliation          | Salesforce CRM or Most Recently Updated |
| Loyalty Tier Reconciliation   | Loyalty Source                          |
| Loyalty Points Reconciliation | Loyalty Source                          |

Fuzzy name matching is not required for the initial training use case. Exact email matching makes it easier to understand and validate why records are matched or remain separate.

## 6. Target Audience

The campaign audience should meet all the following conditions:

- The customer has a valid email address.
- The customer has provided promotional email consent.
- The customer has an active loyalty membership.
- The customer has more than zero loyalty points.
- The loyalty tier is Gold, Silver, or Bronze.
- The most recent purchase occurred more than 30 days ago.

Example audience rule:

```text
Email Address is not empty
AND Promotional Email Consent is valid
AND Loyalty Points > 0
AND Loyalty Tier is Gold, Silver, or Bronze
AND Latest Purchase Date is older than 30 days
```

## 7. Data Graph and Personalization

A Data Graph based on Unified Individual will provide the attributes required by the email content.

The Data Graph should include:

| Attribute             | Purpose                          |
| --------------------- | -------------------------------- |
| Unified Individual ID | Root customer profile            |
| First Name            | Email greeting                   |
| Email Address         | Message recipient                |
| Loyalty Tier          | Dynamic content condition        |
| Loyalty Points        | Personalized merge field         |
| Latest Product Name   | Purchase history personalization |
| Latest Purchase Date  | Purchase history personalization |
| Consent Status        | Audience eligibility             |

Example personalized content:

```text
Hi Anna,

You currently have 2,500 loyalty points as a Gold member.

It has been a while since your last purchase of the Wireless Headphones.
Here is an exclusive offer prepared for you.
```

## 8. Reusable Marketing Content

The email should be built using reusable Marketing Cloud Next content instead of creating a completely separate email for each loyalty tier.

The content structure should include:

| Content Item            | Purpose                                                                |
| ----------------------- | ---------------------------------------------------------------------- |
| Brand                   | Defines the logo, colors, typography, and button styles                |
| Reusable Email Template | Provides the standard email structure                                  |
| Header Block            | Displays the company logo and navigation                               |
| Loyalty Summary Block   | Displays the customer’s tier and points                                |
| Latest Purchase Block   | Displays the most recent purchased product                             |
| Promotion Block         | Displays tier-specific promotional content                             |
| Footer Block            | Displays business information, preference links, and unsubscribe links |

The Promotion Block should contain separate content variations for Gold, Silver, and Bronze customers, together with a default fallback variation.

## 9. Campaign Automation

The campaign will use a published audience segment as the entry source.

The expected campaign flow is:

```text
Published Audience Segment
          ↓
Marketing Campaign Flow
          ↓
Validate Eligible Customer Data
          ↓
Send Personalized Email
          ↓
Track Sent, Opened, Clicked, or Not Sent Results
```

The same email template is used for all eligible customers. Dynamic content and merge fields determine which information and offer each customer sees.

## 10. Test Personas

| Persona                | Loyalty Information | Latest Purchase        | Consent   | Expected Result                                       |
| ---------------------- | ------------------- | ---------------------- | --------- | ----------------------------------------------------- |
| Anna                   | Gold, 2,500 points  | 45 days ago            | Opted in  | Receives Gold promotion                               |
| Ben                    | Silver, 900 points  | 35 days ago            | Opted in  | Receives Silver promotion                             |
| Chris                  | Bronze, 150 points  | 70 days ago            | Opted in  | Receives Bronze promotion                             |
| David                  | Gold, 3,000 points  | 50 days ago            | Opted out | Does not receive an email                             |
| Emma                   | Silver, 700 points  | 5 days ago             | Opted in  | Excluded because of recent purchase                   |
| Unknown Loyalty Member | Gold, 2,000 points  | No matching CRM record | Unknown   | Does not receive an email                             |
| Duplicate Customer     | Silver, 800 points  | 40 days ago            | Opted in  | Records are unified into the correct customer profile |

## 11. Core Training Scope — 32 Hours

The main 32-hour implementation covers:

- Marketing Cloud Next and Data 360 environment validation.
- Test data preparation.
- CRM and loyalty data ingestion.
- Data model mapping and relationships.
- Identity Resolution configuration.
- Unified Individual validation.
- Audience segment creation.
- Data Graph creation.
- Brand configuration.
- Reusable email template and content blocks.
- Dynamic content variations.
- Campaign Flow configuration.
- End-to-end testing and demonstration.

At the end of the 32-hour scope, the trainee should be able to demonstrate the complete process from source customer data to a personalized campaign email.

## 12. Add-on Scope — 8 Hours

The optional eight-hour extension adds Salesforce Case data to the customer profile.

The purpose is to prevent the company from sending a normal promotion to a customer who currently has an unresolved service problem.

The additional business rules are:

| Customer Condition                                | Campaign Action                                           |
| ------------------------------------------------- | --------------------------------------------------------- |
| No recent serious Case                            | Send the loyalty promotion                                |
| High-priority Case closed within the last 14 days | Send a service recovery email                             |
| Open Case exists                                  | Do not send a promotional email                           |
| Case data is unavailable or stale                 | Stop processing and investigate the data refresh pipeline |

The add-on includes:

- Adding Case data to the Data 360 data model.
- Extending the Data Graph with the latest Case information.
- Creating a reusable service recovery content block.
- Adding decision logic to the campaign flow.
- Testing Data Stream, Identity Resolution, Segment, and Data Graph refresh behavior.
- Creating a troubleshooting checklist for stale customer data.

## 13. Expected Final Demo

The final demonstration should show:

1. Customer data stored in Salesforce CRM.
2. Loyalty data stored in an external or simulated source.
3. CRM and loyalty records unified using email.
4. The resulting Unified Individual profile.
5. Eligible and excluded customers in the audience segment.
6. Loyalty and purchase data available through the Data Graph.
7. A reusable brand, email template, and content blocks.
8. Different email content for Gold, Silver, and Bronze customers.
9. An opted-out customer being excluded from the campaign.
10. A recent buyer being excluded from the campaign.
11. An open or high-priority Case changing the campaign outcome.
12. The troubleshooting process when updated data does not immediately appear in the Data Graph.

## 14. Definition of Done

The use case is considered complete when:

- Salesforce CRM and loyalty data are successfully ingested.
- Required source fields are mapped to the correct data model objects.
- At least three CRM Contacts are correctly matched with loyalty records.
- Incorrect or unrelated records are not matched.
- The audience segment includes only eligible customers.
- The Data Graph provides loyalty and latest purchase information.
- The email uses reusable brand, template, and content blocks.
- Gold, Silver, and Bronze customers receive different content variations.
- Customers without valid consent do not receive the promotional email.
- Campaign email delivery and engagement results can be reviewed.
- The Case-aware add-on changes or suppresses the promotion when appropriate.
- A documented troubleshooting process exists for stale or missing data.
