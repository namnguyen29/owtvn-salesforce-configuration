import { refreshApex } from '@salesforce/apex';
import { api, LightningElement, wire } from 'lwc';
import getWarrantyClaimSummary from '@salesforce/apex/WarrantyClaimSummaryController.getWarrantyClaimSummary';

const DEFAULT_ERROR_MESSAGE = 'Unable to load warranty claim summary data.';

export default class WarrantyClaimSummary extends LightningElement {
  @api recordId;

  errorMessage = '';
  isLoading = true;
  isRefreshing = false;
  summaryData;
  wiredSummaryResult;

  @wire(getWarrantyClaimSummary, { accountId: '$resolvedAccountId' })
  wiredSummary(result) {
    this.wiredSummaryResult = result;
    const { data, error } = result;

    if (data) {
      this.summaryData = data;
      this.errorMessage = '';
      this.isLoading = false;
      this.isRefreshing = false;
    } else if (error) {
      this.summaryData = undefined;
      this.errorMessage = this.reduceErrors(error);
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  get resolvedAccountId() {
    return this.recordId ?? null;
  }

  get hasData() {
    return Boolean(this.summaryData);
  }

  get hasError() {
    return this.errorMessage.length > 0;
  }

  get totalClaims() {
    return this.summaryData?.totalClaims ?? 0;
  }

  get approvedClaims() {
    return this.summaryData?.approvedClaims ?? 0;
  }

  get pendingClaims() {
    return this.summaryData?.pendingClaims ?? 0;
  }

  get scopeCopy() {
    return this.recordId
      ? 'Counts reflect warranty claims linked to the current account.'
      : 'Counts reflect all warranty claims the current user can access.';
  }

  get refreshLabel() {
    return this.isRefreshing ? 'Refreshing' : 'Refresh';
  }

  get isRefreshDisabled() {
    return this.isLoading || this.isRefreshing;
  }

  async handleRefresh() {
    if (!this.wiredSummaryResult || this.isRefreshing) {
      return;
    }

    this.isRefreshing = true;
    this.errorMessage = '';

    try {
      await refreshApex(this.wiredSummaryResult);
    } catch (error) {
      this.errorMessage = this.reduceErrors(error);
      this.isRefreshing = false;
    }
  }

  reduceErrors(errors) {
    const normalizedErrors = Array.isArray(errors) ? errors : [errors];

    return normalizedErrors
      .filter(Boolean)
      .map((error) => {
        if (Array.isArray(error.body)) {
          return error.body.map((entry) => entry.message).join(', ');
        }

        if (typeof error.body?.message === 'string') {
          return error.body.message;
        }

        if (typeof error.message === 'string') {
          return error.message;
        }

        return DEFAULT_ERROR_MESSAGE;
      })
      .join('; ');
  }
}
