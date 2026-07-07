/**
 * Provides Account health data for the accountHealthDashboard Lightning Web Component.
 */
public with sharing class AccountHealthDashboardController {
    private static final Decimal GREEN_REVENUE_THRESHOLD = 1000000;
    private static final Decimal YELLOW_REVENUE_THRESHOLD = 100000;
    private static final Integer GREEN_CONTACT_THRESHOLD = 5;
    private static final String COUNT_ALIAS = 'totalCount';
    private static final String STATUS_GREEN = 'Green';
    private static final String STATUS_YELLOW = 'Yellow';
    private static final String STATUS_RED = 'Red';
    private static final String ERROR_ACCOUNT_ID_REQUIRED = 'Account ID is required.';
    private static final String ERROR_ACCOUNT_NOT_FOUND = 'Account not found or inaccessible.';
    private static final String ERROR_LOAD_FAILED = 'Unable to load account health data.';

    /**
     * Returns account details, related record counts, and a computed health status for one Account.
     * @param accountId The Account Id from the record page context
     * @return AccountHealthDashboardData DTO for the UI
     * @throws AuraHandledException When the Account cannot be loaded
     * @example
     * AccountHealthDashboardController.AccountHealthDashboardData data =
     *     AccountHealthDashboardController.getAccountHealth(accountId);
     */
    @AuraEnabled(cacheable=true)
    public static AccountHealthDashboardData getAccountHealth(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException(ERROR_ACCOUNT_ID_REQUIRED);
        }

        try {
            Account accountRecord = getAccount(accountId);
            Integer contactCount = getContactCount(accountId);
            Integer opportunityCount = getOpportunityCount(accountId);
            String healthStatus = determineHealthStatus(accountRecord.AnnualRevenue, contactCount);

            return new AccountHealthDashboardData(
                accountRecord,
                contactCount,
                opportunityCount,
                healthStatus
            );
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(ERROR_LOAD_FAILED);
        }
    }

    /**
     * Queries the Account record for the dashboard.
     * @param accountId The Account Id to load
     * @return The requested Account
     * @throws AuraHandledException When no accessible Account is found
     */
    private static Account getAccount(Id accountId) {
        List<Account> accounts = [
            SELECT Id, Name, Industry, AnnualRevenue
            FROM Account
            WHERE Id = :accountId
            WITH USER_MODE
            LIMIT 1
        ];

        if (accounts.isEmpty()) {
            throw new AuraHandledException(ERROR_ACCOUNT_NOT_FOUND);
        }

        return accounts[0];
    }

    /**
     * Counts related Contacts for an Account.
     * @param accountId The Account Id to count against
     * @return Number of related Contacts
     */
    private static Integer getContactCount(Id accountId) {
        List<AggregateResult> results = [
            SELECT COUNT(Id) totalCount
            FROM Contact
            WHERE AccountId = :accountId
            WITH USER_MODE
        ];
        return extractCount(results);
    }

    /**
     * Counts related Opportunities for an Account.
     * @param accountId The Account Id to count against
     * @return Number of related Opportunities
     */
    private static Integer getOpportunityCount(Id accountId) {
        List<AggregateResult> results = [
            SELECT COUNT(Id) totalCount
            FROM Opportunity
            WHERE AccountId = :accountId
            WITH USER_MODE
        ];
        return extractCount(results);
    }

    /**
     * Converts an aggregate COUNT result into an Integer.
     * @param results Aggregate query results
     * @return Parsed count value
     */
    private static Integer extractCount(List<AggregateResult> results) {
        if (results.isEmpty()) {
            return 0;
        }

        Object countValue = results[0].get(COUNT_ALIAS);
        return countValue == null ? 0 : Integer.valueOf(String.valueOf(countValue));
    }

    /**
     * Applies the business rules for dashboard health status.
     * @param annualRevenue The Account annual revenue
     * @param contactCount The total number of related Contacts
     * @return Green, Yellow, or Red
     */
    private static String determineHealthStatus(Decimal annualRevenue, Integer contactCount) {
        Decimal normalizedRevenue = annualRevenue == null ? 0 : annualRevenue;
        Integer normalizedContactCount = contactCount == null ? 0 : contactCount;

        if (normalizedRevenue > GREEN_REVENUE_THRESHOLD && normalizedContactCount >= GREEN_CONTACT_THRESHOLD) {
            return STATUS_GREEN;
        }

        if (normalizedRevenue > YELLOW_REVENUE_THRESHOLD) {
            return STATUS_YELLOW;
        }

        return STATUS_RED;
    }

    /**
     * DTO returned to the LWC wire adapter.
     */
    public class AccountHealthDashboardData {
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public String industry { get; set; }
        @AuraEnabled public Decimal annualRevenue { get; set; }
        @AuraEnabled public Integer contactCount { get; set; }
        @AuraEnabled public Integer opportunityCount { get; set; }
        @AuraEnabled public String healthStatus { get; set; }

        /**
         * Initializes the dashboard response payload.
         * @param accountRecord The source Account record
         * @param contactCount The number of related Contacts
         * @param opportunityCount The number of related Opportunities
         * @param healthStatus The calculated health status
         */
        public AccountHealthDashboardData(
            Account accountRecord,
            Integer contactCount,
            Integer opportunityCount,
            String healthStatus
        ) {
            this.accountId = accountRecord.Id;
            this.accountName = accountRecord.Name;
            this.industry = accountRecord.Industry;
            this.annualRevenue = accountRecord.AnnualRevenue;
            this.contactCount = contactCount;
            this.opportunityCount = opportunityCount;
            this.healthStatus = healthStatus;
        }
    }
}