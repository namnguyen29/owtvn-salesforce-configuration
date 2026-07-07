/**
 * Tests AccountHealthDashboardController health calculation and error handling.
 */
@isTest
private class AccountHealthDashboardControllerTest {
    private static final Decimal GREEN_REVENUE = 1500000;
    private static final Decimal YELLOW_REVENUE = 250000;
    private static final Decimal RED_REVENUE = 50000;

    @isTest
    static void shouldReturnGreenStatus_WhenRevenueExceedsOneMillionAndFiveContactsExist() {
        Account accountRecord = TestDataFactory.createAccount(
            new Map<String, Object>{
                'Name' => 'Green Account',
                'AnnualRevenue' => GREEN_REVENUE,
                'Industry' => 'Media'
            },
            true
        );
        TestDataFactory.createContacts(new List<Account>{ accountRecord }, 5, true);
        TestDataFactory.createOpportunities(new List<Account>{ accountRecord }, 2, true);

        Test.startTest();
        AccountHealthDashboardController.AccountHealthDashboardData result =
            AccountHealthDashboardController.getAccountHealth(accountRecord.Id);
        Test.stopTest();

        Assert.areEqual(accountRecord.Id, result.accountId, 'The account Id should match the requested record.');
        Assert.areEqual('Green Account', result.accountName, 'The Account name should be returned.');
        Assert.areEqual('Media', result.industry, 'The Industry should be returned.');
        Assert.areEqual(GREEN_REVENUE, result.annualRevenue, 'The Annual Revenue should be returned.');
        Assert.areEqual(5, result.contactCount, 'The Contact count should be returned.');
        Assert.areEqual(2, result.opportunityCount, 'The Opportunity count should be returned.');
        Assert.areEqual('Green', result.healthStatus, 'The health status should be Green.');
    }

    @isTest
    static void shouldReturnYellowStatus_WhenRevenueExceedsOneHundredThousand() {
        Account accountRecord = TestDataFactory.createAccount(
            new Map<String, Object>{
                'Name' => 'Yellow Account',
                'AnnualRevenue' => YELLOW_REVENUE
            },
            true
        );
        TestDataFactory.createContacts(new List<Account>{ accountRecord }, 2, true);
        TestDataFactory.createOpportunities(new List<Account>{ accountRecord }, 1, true);

        Test.startTest();
        AccountHealthDashboardController.AccountHealthDashboardData result =
            AccountHealthDashboardController.getAccountHealth(accountRecord.Id);
        Test.stopTest();

        Assert.areEqual('Yellow', result.healthStatus, 'The health status should be Yellow.');
        Assert.areEqual(2, result.contactCount, 'The Contact count should be returned.');
        Assert.areEqual(1, result.opportunityCount, 'The Opportunity count should be returned.');
    }

    @isTest
    static void shouldReturnRedStatus_WhenRevenueDoesNotMeetThreshold() {
        Account accountRecord = TestDataFactory.createAccount(
            new Map<String, Object>{
                'Name' => 'Red Account',
                'AnnualRevenue' => RED_REVENUE
            },
            true
        );
        TestDataFactory.createContacts(new List<Account>{ accountRecord }, 1, true);

        Test.startTest();
        AccountHealthDashboardController.AccountHealthDashboardData result =
            AccountHealthDashboardController.getAccountHealth(accountRecord.Id);
        Test.stopTest();

        Assert.areEqual('Red', result.healthStatus, 'The health status should be Red.');
        Assert.areEqual(1, result.contactCount, 'The Contact count should be returned.');
        Assert.areEqual(0, result.opportunityCount, 'The Opportunity count should default to zero.');
    }

    @isTest
    static void shouldThrowAuraHandledException_WhenAccountIdIsNull() {
        Test.startTest();
        try {
            AccountHealthDashboardController.getAccountHealth(null);
            Assert.fail('Expected AuraHandledException for a missing Account Id.');
        } catch (AuraHandledException e) {
            Assert.isTrue(
                String.isNotBlank(e.getMessage()),
                'A sanitized AuraHandledException message should be returned.'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void shouldThrowAuraHandledException_WhenAccountIsNotAccessible() {
        Account accountRecord = TestDataFactory.createAccount(
            new Map<String, Object>{
                'Name' => 'Deleted Account',
                'AnnualRevenue' => YELLOW_REVENUE
            },
            true
        );
        delete accountRecord;

        Test.startTest();
        try {
            AccountHealthDashboardController.getAccountHealth(accountRecord.Id);
            Assert.fail('Expected AuraHandledException when the Account is not accessible.');
        } catch (AuraHandledException e) {
            Assert.isTrue(
                String.isNotBlank(e.getMessage()),
                'A sanitized AuraHandledException message should be returned for inaccessible Accounts.'
            );
        }
        Test.stopTest();
    }
}