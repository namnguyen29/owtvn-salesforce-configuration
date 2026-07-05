## Ticket: Create OWD Commercial Custom Lightning App

### Objective

Create a new Salesforce Lightning App named **OWD Commercial** with a custom home page and dedicated record pages for key commercial objects.

### Requirements

#### 1. Custom Lightning App

Create a new Lightning App named **OWD Commercial**.

The app should include the following tabs:

- Home
- Accounts
- Contacts
- Assets
- Campaigns

#### 2. App Visibility

The **OWD Commercial** app should be visible **only** to users with the following profiles:

- OWTVN System Administrator
- OWTVN Minimum Access

No other profiles should have access to this app.

Additionally, configure the app as the **default landing app** for users assigned to these two profiles so that **OWD Commercial** is the first app displayed after they log in to the org.

#### 3. Custom Home Page

Create a custom Lightning Home Page for the **OWD Commercial** app.

The home page should display four separate lists:

- Accounts
- Contacts
- Assets
- Campaigns

Above each list, add a component displaying the total record count for that object.

Each count component should include a **Reset** button.

If Salesforce does not provide a standard component capable of supporting the required count and reset functionality, implement a custom Lightning Web Component (LWC).

#### 4. Lightning Record Pages

Create dedicated Lightning Record Pages for the following objects:

- Contact

Assign these record pages to the **OWD Commercial** app.

#### 5. Contact Related List

On the **Contact Lightning Record Page**, add the **Assets** related list so users can view associated Asset records directly from the Contact record.

### Acceptance Criteria

- A Lightning App named **OWD Commercial** is created.
- The app contains the following tabs:

  - Home
  - Accounts
  - Contacts
  - Assets
  - Campaigns

- The app is visible only to the following profiles:

  - OWTVN System Administrator
  - OWTVN Minimum Access

- **OWD Commercial** is configured as the default app for users with these two profiles upon login.
- A custom Home Page is created and assigned to the app.
- The Home Page displays four object lists (Accounts, Contacts, Assets, and Campaigns).
- Each list has a record count component displayed above it.
- Each record count component includes a Reset button.
- A custom LWC is implemented if the standard Salesforce components cannot meet the record count and reset requirements.
- Dedicated Lightning Record Pages are created and assigned for Contact.
- The Contact Lightning Record Page displays the Assets related list.
