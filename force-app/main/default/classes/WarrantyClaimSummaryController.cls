/**
 * Provides aggregated Warranty Claim counts for Lightning Web Components.
 */
public with sharing class WarrantyClaimSummaryController {
    private static final String STATUS_APPROVED = 'Approved';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String STATUS_NEW = 'New';
    private static final String COUNT_ALIAS = 'claimCount';
    private static final String STATUS_ALIAS = 'claimStatus';
    private static final String ERROR_INVALID_SCOPE = 'Warranty claim summaries can only be filtered by Account records.';
    private static final String ERROR_LOAD_FAILED = 'Unable to load warranty claim summary data.';

    /**
     * Returns warranty claim summary counts globally or for a specific Account.
     * @param accountId Optional Account Id used to scope the summary to one customer
     * @return Summary counts for total, approved, and pending claims
     * @throws AuraHandledException When the summary cannot be loaded securely
     * @example
     * WarrantyClaimSummaryController.WarrantyClaimSummaryData summary =
     *     WarrantyClaimSummaryController.getWarrantyClaimSummary(accountId);
     */
    @AuraEnabled(cacheable=true)
    public static WarrantyClaimSummaryData getWarrantyClaimSummary(Id accountId) {
        try {
            validateScope(accountId);
            return buildSummary(getGroupedClaimCounts(accountId));
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(ERROR_LOAD_FAILED);
        }
    }

    /**
     * Ensures that record page requests only scope by Account.
     * @param accountId Optional Account Id from the component context
     * @throws AuraHandledException When a non-Account Id is supplied
     */
    private static void validateScope(Id accountId) {
        if (accountId != null && accountId.getSObjectType() != Account.SObjectType) {
            throw new AuraHandledException(ERROR_INVALID_SCOPE);
        }
    }

    /**
     * Queries grouped Warranty Claim counts by status.
     * @param accountId Optional Account Id filter
     * @return Grouped aggregate results
     */
    private static List<AggregateResult> getGroupedClaimCounts(Id accountId) {
        if (accountId == null) {
            return [
                SELECT Status__c claimStatus, COUNT(Id) claimCount
                FROM Warranty_Claim__c
                WITH USER_MODE
                GROUP BY Status__c
            ];
        }

        return [
            SELECT Status__c claimStatus, COUNT(Id) claimCount
            FROM Warranty_Claim__c
            WHERE Customer__c = :accountId
            WITH USER_MODE
            GROUP BY Status__c
        ];
    }

    /**
     * Transforms grouped aggregate results into the LWC DTO.
     * @param groupedClaimCounts Aggregate query results by status
     * @return Summary DTO for the component
     */
    private static WarrantyClaimSummaryData buildSummary(List<AggregateResult> groupedClaimCounts) {
        Integer totalClaims = 0;
        Integer approvedClaims = 0;
        Integer pendingClaims = 0;

        for (AggregateResult groupedClaimCount : groupedClaimCounts) {
            String claimStatus = (String) groupedClaimCount.get(STATUS_ALIAS);
            Integer claimCount = Integer.valueOf(String.valueOf(groupedClaimCount.get(COUNT_ALIAS)));

            totalClaims += claimCount;

            if (claimStatus == STATUS_APPROVED) {
                approvedClaims += claimCount;
            }

            if (claimStatus == STATUS_NEW || claimStatus == STATUS_IN_PROGRESS) {
                pendingClaims += claimCount;
            }
        }

        return new WarrantyClaimSummaryData(totalClaims, approvedClaims, pendingClaims);
    }

    /**
     * DTO returned to the LWC wire adapter.
     */
    public class WarrantyClaimSummaryData {
        @AuraEnabled public Integer totalClaims { get; set; }
        @AuraEnabled public Integer approvedClaims { get; set; }
        @AuraEnabled public Integer pendingClaims { get; set; }

        /**
         * Initializes the warranty claim summary payload.
         * @param totalClaims Total accessible claims
         * @param approvedClaims Total approved claims
         * @param pendingClaims Total new and in-progress claims
         */
        public WarrantyClaimSummaryData(Integer totalClaims, Integer approvedClaims, Integer pendingClaims) {
            this.totalClaims = totalClaims;
            this.approvedClaims = approvedClaims;
            this.pendingClaims = pendingClaims;
        }
    }
}
