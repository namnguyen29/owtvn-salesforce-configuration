/**
 * Centralized factory for test data creation.
 */
@isTest
public class TestDataFactory {
    /**
     * Creates one or more Account records with optional insert behavior.
     * @param count Number of Accounts to create
     * @param doInsert Whether to insert the records before returning them
     * @return The created Account records
     */
    public static List<Account> createAccounts(Integer count, Boolean doInsert) {
        List<Account> accounts = new List<Account>();

        for (Integer indexValue = 0; indexValue < count; indexValue++) {
            accounts.add(new Account(
                Name = 'Test Account ' + indexValue,
                Industry = 'Technology',
                AnnualRevenue = 50000 + (indexValue * 1000)
            ));
        }

        if (doInsert) {
            insert accounts;
        }

        return accounts;
    }

    /**
     * Creates a single Account with optional field overrides.
     * @param fieldOverrides Field values to override on the Account
     * @param doInsert Whether to insert the record before returning it
     * @return The created Account record
     */
    public static Account createAccount(Map<String, Object> fieldOverrides, Boolean doInsert) {
        Account accountRecord = new Account(
            Name = 'Test Account',
            Industry = 'Technology',
            AnnualRevenue = 50000
        );

        for (String fieldName : fieldOverrides.keySet()) {
            accountRecord.put(fieldName, fieldOverrides.get(fieldName));
        }

        if (doInsert) {
            insert accountRecord;
        }

        return accountRecord;
    }

    /**
     * Creates Contacts for the provided Accounts.
     * @param accounts Parent Accounts
     * @param countPerAccount Number of Contacts per Account
     * @param doInsert Whether to insert the records before returning them
     * @return The created Contact records
     */
    public static List<Contact> createContacts(List<Account> accounts, Integer countPerAccount, Boolean doInsert) {
        List<Contact> contacts = new List<Contact>();
        Integer indexValue = 0;

        for (Account accountRecord : accounts) {
            for (Integer countValue = 0; countValue < countPerAccount; countValue++) {
                contacts.add(new Contact(
                    FirstName = 'Test',
                    LastName = 'Contact ' + indexValue,
                    Email = 'contact' + indexValue + '@example.com',
                    AccountId = accountRecord.Id
                ));
                indexValue++;
            }
        }

        if (doInsert) {
            insert contacts;
        }

        return contacts;
    }

    /**
     * Creates Opportunities for the provided Accounts.
     * @param accounts Parent Accounts
     * @param countPerAccount Number of Opportunities per Account
     * @param doInsert Whether to insert the records before returning them
     * @return The created Opportunity records
     */
    public static List<Opportunity> createOpportunities(
        List<Account> accounts,
        Integer countPerAccount,
        Boolean doInsert
    ) {
        List<Opportunity> opportunities = new List<Opportunity>();
        Integer indexValue = 0;

        for (Account accountRecord : accounts) {
            for (Integer countValue = 0; countValue < countPerAccount; countValue++) {
                opportunities.add(new Opportunity(
                    Name = 'Test Opportunity ' + indexValue,
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addDays(30),
                    Amount = 10000 + (indexValue * 1000),
                    AccountId = accountRecord.Id
                ));
                indexValue++;
            }
        }

        if (doInsert) {
            insert opportunities;
        }

        return opportunities;
    }
}
