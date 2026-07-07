/**
 * Tests WarrantyClaimSummaryController summary calculations and error handling.
 */
@IsTest
private class WarrantyClaimSummaryControllerTest {
    private static final String PRIMARY_ACCOUNT_NAME = 'Warranty Account A';
    private static final String SECONDARY_ACCOUNT_NAME = 'Warranty Account B';
    private static final String NO_CLAIMS_ACCOUNT_NAME = 'No Claims Account';
    private static final String SERVICE_USER_LAST_NAME = 'WarrantySummaryUser';
    private static final String WARRANTY_PERMISSION_SET_NAME = 'Warranty_Claim_User';

    @TestSetup
    static void setupTestData() {
        Account primaryAccount = TestDataFactory.createAccount(
            new Map<String, Object>{
                'Name' => PRIMARY_ACCOUNT_NAME,
                'Industry' => 'Manufacturing'
            },
            true
        );
        Account secondaryAccount = TestDataFactory.createAccount(
            new Map<String, Object>{
                'Name' => SECONDARY_ACCOUNT_NAME,
                'Industry' => 'Retail'
            },
            true
        );
        Account noClaimsAccount = TestDataFactory.createAccount(
            new Map<String, Object>{
                'Name' => NO_CLAIMS_ACCOUNT_NAME
            },
            true
        );

        WarrantyClaimTestDataFactory.createClaims(
            primaryAccount,
            new List<String>{ 'Approved', 'New', 'In Progress', 'Rejected' }
        );
        WarrantyClaimTestDataFactory.createClaims(
            secondaryAccount,
            new List<String>{ 'Approved' }
        );
        TestDataFactory.createContacts(new List<Account>{ primaryAccount }, 1, true);
    }

    @IsTest
    static void shouldReturnGlobalSummaryWhenClaimsExistAcrossAccounts() {
        User serviceUser = createServiceUser();
        WarrantyClaimSummaryController.WarrantyClaimSummaryData result;

        System.runAs(serviceUser) {
            Test.startTest();
            result = WarrantyClaimSummaryController.getWarrantyClaimSummary(null);
            Test.stopTest();
        }

        Assert.areEqual(5, result.totalClaims, 'The global summary should include every accessible claim.');
        Assert.areEqual(2, result.approvedClaims, 'The approved summary should include both approved claims.');
        Assert.areEqual(2, result.pendingClaims, 'Pending claims should include New and In Progress statuses.');
    }

    @IsTest
    static void shouldReturnScopedSummaryWhenAccountIdIsProvided() {
        Account primaryAccount = [
            SELECT Id
            FROM Account
            WHERE Name = :PRIMARY_ACCOUNT_NAME
            LIMIT 1
        ];
        User serviceUser = createServiceUser();
        WarrantyClaimSummaryController.WarrantyClaimSummaryData result;

        System.runAs(serviceUser) {
            Test.startTest();
            result = WarrantyClaimSummaryController.getWarrantyClaimSummary(primaryAccount.Id);
            Test.stopTest();
        }

        Assert.areEqual(4, result.totalClaims, 'The scoped summary should only include claims for the requested account.');
        Assert.areEqual(1, result.approvedClaims, 'Only one scoped claim should be approved.');
        Assert.areEqual(2, result.pendingClaims, 'Scoped pending claims should include New and In Progress records.');
    }

    @IsTest
    static void shouldReturnZeroesWhenAccountHasNoClaims() {
        Account noClaimsAccount = TestDataFactory.createAccount(
            new Map<String, Object>{ 'Name' => NO_CLAIMS_ACCOUNT_NAME },
            false
        );
        noClaimsAccount = [
            SELECT Id
            FROM Account
            WHERE Name = :noClaimsAccount.Name
            LIMIT 1
        ];
        User serviceUser = createServiceUser();
        WarrantyClaimSummaryController.WarrantyClaimSummaryData result;

        System.runAs(serviceUser) {
            Test.startTest();
            result = WarrantyClaimSummaryController.getWarrantyClaimSummary(noClaimsAccount.Id);
            Test.stopTest();
        }

        Assert.areEqual(0, result.totalClaims, 'Accounts without claims should return zero totals.');
        Assert.areEqual(0, result.approvedClaims, 'Accounts without claims should return zero approved claims.');
        Assert.areEqual(0, result.pendingClaims, 'Accounts without claims should return zero pending claims.');
    }

    @IsTest
    static void shouldThrowAuraHandledExceptionWhenRecordScopeIsNotAccount() {
        Contact scopedContact = [
            SELECT Id
            FROM Contact
            WHERE Account.Name = :PRIMARY_ACCOUNT_NAME
            LIMIT 1
        ];
        User serviceUser = createServiceUser();

        System.runAs(serviceUser) {
            Test.startTest();
            try {
                WarrantyClaimSummaryController.getWarrantyClaimSummary(scopedContact.Id);
                Assert.fail('Expected an AuraHandledException when a non-Account Id is supplied.');
            } catch (AuraHandledException e) {
                Assert.isTrue(
                    String.isNotBlank(e.getMessage()),
                    'A sanitized AuraHandledException message should be returned.'
                );
            }
            Test.stopTest();
        }
    }

    private static User createServiceUser() {
        String uniqueSuffix = String.valueOf(DateTime.now().getTime()) + String.valueOf(Crypto.getRandomInteger());
        User serviceUser = new User(
            Alias = 'wclaim',
            Email = 'warranty.summary@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName = SERVICE_USER_LAST_NAME,
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'warranty.summary.' + uniqueSuffix + '@example.com'
        );
        insert serviceUser;

        PermissionSet warrantyClaimPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :WARRANTY_PERMISSION_SET_NAME
            LIMIT 1
        ];

        insert new PermissionSetAssignment(
            AssigneeId = serviceUser.Id,
            PermissionSetId = warrantyClaimPermissionSet.Id
        );

        return serviceUser;
    }
}
