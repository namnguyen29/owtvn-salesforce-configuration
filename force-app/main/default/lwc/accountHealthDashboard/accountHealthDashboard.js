import { refreshApex } from '@salesforce/apex';
import { api, LightningElement, wire } from 'lwc';
import getAccountHealth from '@salesforce/apex/AccountHealthDashboardController.getAccountHealth';

const HEALTH_PRESENTATION = {
  Neutral: {
    badgeClass: 'health-badge health-badge_neutral',
    summary: ''
  },
  Green: {
    badgeClass: 'health-badge health-badge_green',
    summary: 'Revenue exceeds $1M and the account has at least five contacts.'
  },
  Yellow: {
    badgeClass: 'health-badge health-badge_yellow',
    summary: 'Revenue exceeds $100K, but the account has not reached the green threshold.'
  },
  Red: {
    badgeClass: 'health-badge health-badge_red',
    summary: 'Revenue and engagement are below the configured health thresholds.'
  }
};

export default class AccountHealthDashboard extends LightningElement {
  _recordId;

  accountHealth;
  errorMessage = '';
  isLoading = false;
  isRefreshing = false;
  wiredAccountHealthResult;

  @api
  get recordId() {
    return this._recordId;
  }

  set recordId(value) {
    if (this._recordId === value) {
      return;
    }

    this._recordId = value;
    this.accountHealth = undefined;
    this.errorMessage = '';
    this.isLoading = Boolean(value);
    this.isRefreshing = false;
  }

  @wire(getAccountHealth, { accountId: '$recordId' })
  wiredAccountHealth(result) {
    this.wiredAccountHealthResult = result;
    const { data, error } = result;

    if (data) {
      this.accountHealth = data;
      this.errorMessage = '';
      this.isLoading = false;
      this.isRefreshing = false;
    } else if (error) {
      this.accountHealth = undefined;
      this.errorMessage = this.reduceErrors(error);
      this.isLoading = false;
      this.isRefreshing = false;
    } else if (!this.recordId) {
      this.isLoading = false;
    }
  }

  get isInitialLoading() {
    return this.isLoading && !this.isRefreshing;
  }

  get hasError() {
    return this.errorMessage.length > 0;
  }

  get hasData() {
    return Boolean(this.accountHealth);
  }

  get accountName() {
    return this.accountHealth?.accountName ?? 'Account health';
  }

  get industryValue() {
    return this.accountHealth?.industry ?? 'Unspecified';
  }

  get annualRevenueValue() {
    return this.accountHealth?.annualRevenue;
  }

  get contactCountValue() {
    return this.accountHealth?.contactCount ?? 0;
  }

  get opportunityCountValue() {
    return this.accountHealth?.opportunityCount ?? 0;
  }

  get healthStatus() {
    return this.accountHealth?.healthStatus ?? 'Red';
  }

  get displayHealthStatus() {
    if (this.isInitialLoading || this.isRefreshing) {
      return 'Loading';
    }

    if (this.hasError) {
      return 'Unavailable';
    }

    return this.healthStatus;
  }

  get healthBadgeClass() {
    return this.healthPresentation.badgeClass;
  }

  get healthSummary() {
    return this.healthPresentation.summary;
  }

  get refreshButtonLabel() {
    return this.isRefreshing ? 'Refreshing' : 'Refresh';
  }

  get isRefreshDisabled() {
    return !this.recordId || this.isInitialLoading || this.isRefreshing;
  }

  get annualRevenueLabel() {
    return this.annualRevenueValue === null || this.annualRevenueValue === undefined ? 'Not available' : '';
  }

  get healthPresentation() {
    if (!this.hasData) {
      return HEALTH_PRESENTATION.Neutral;
    }

    return HEALTH_PRESENTATION[this.healthStatus] ?? HEALTH_PRESENTATION.Red;
  }

  async handleRefresh() {
    if (!this.wiredAccountHealthResult || !this.recordId || this.isRefreshing) {
      return;
    }

    // this.isRefreshing = true;
    this.errorMessage = '';

    try {
      await refreshApex(this.wiredAccountHealthResult);
    } catch (error) {
      this.errorMessage = this.reduceErrors(error);
    } finally {
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

        return 'Unable to load account health data.';
      })
      .join('; ');
  }
}