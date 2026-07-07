/**
 * Creates Warranty Claim test data for controller coverage.
 */
@IsTest
public class WarrantyClaimTestDataFactory {
    /**
     * Creates and inserts Warranty Claim records for the provided Account and statuses.
     * @param accountRecord Parent Account for the claims
     * @param statuses Status values to assign to the generated claims
     * @return The created Warranty Claim records
     */
    public static List<Warranty_Claim__c> createClaims(Account accountRecord, List<String> statuses) {
        List<Warranty_Claim__c> warrantyClaims = new List<Warranty_Claim__c>();
        Integer indexValue = 0;

        for (String statusValue : statuses) {
            warrantyClaims.add(new Warranty_Claim__c(
                Claim_Amount__c = 100 + (indexValue * 50),
                Claim_Date__c = Date.today().addDays(-indexValue),
                Customer__c = accountRecord.Id,
                Status__c = statusValue
            ));
            indexValue++;
        }

        insert warrantyClaims;
        return warrantyClaims;
    }
}
