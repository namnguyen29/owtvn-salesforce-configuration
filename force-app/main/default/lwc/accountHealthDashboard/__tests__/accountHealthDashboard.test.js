import { refreshApex } from '@salesforce/apex';
import { createElement } from 'lwc';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import AccountHealthDashboard from 'c/accountHealthDashboard';
import getAccountHealth from '@salesforce/apex/AccountHealthDashboardController.getAccountHealth';

jest.mock(
  '@salesforce/apex',
  () => ({
    refreshApex: jest.fn(() => Promise.resolve())
  }),
  { virtual: true }
);

const getAccountHealthAdapter = registerApexTestWireAdapter(getAccountHealth);

const MOCK_GREEN_DATA = {
  accountId: '001000000000001AAA',
  accountName: 'Acme Media',
  industry: 'Media',
  annualRevenue: 1500000,
  contactCount: 5,
  opportunityCount: 3,
  healthStatus: 'Green'
};

const MOCK_ERROR = {
  body: {
    message: 'Unable to load account health data.'
  }
};

const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

function createComponent(recordId = '001000000000001AAA') {
  const element = createElement('c-account-health-dashboard', {
    is: AccountHealthDashboard
  });
  element.recordId = recordId;
  document.body.appendChild(element);
  return element;
}

describe('c-account-health-dashboard', () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it('shows a loading spinner before wire data resolves', () => {
    const element = createComponent();

    const spinner = element.shadowRoot.querySelector('lightning-spinner');

    expect(spinner).not.toBeNull();
    expect(spinner.alternativeText).toBe('Loading account health');
  });

  it('renders account details, counts, and green status when wire data loads', async () => {
    const element = createComponent();
    getAccountHealthAdapter.emit(MOCK_GREEN_DATA);
    await flushPromises();

    const heading = element.shadowRoot.querySelector('h2');
    const badge = element.shadowRoot.querySelector('.health-badge');
    const countValues = [...element.shadowRoot.querySelectorAll('.count-value')].map((node) => node.textContent.trim());

    expect(heading.textContent).toBe('Acme Media');
    expect(badge.textContent.trim()).toBe('Green');
    expect(badge.className).toContain('health-badge_green');
    expect(countValues).toEqual(['5', '3']);
    expect(element.shadowRoot.querySelector('.status-summary').textContent).toContain('Revenue exceeds $1M');
  });

  it('renders the error state when the wire emits an error', async () => {
    const element = createComponent();
    getAccountHealthAdapter.error(MOCK_ERROR);
    await flushPromises();

    const errorPanel = element.shadowRoot.querySelector('.state-panel_error');

    expect(errorPanel).not.toBeNull();
    expect(errorPanel.textContent).toContain('Unable to load account health data.');
  });

  it('calls refreshApex when the refresh button is clicked', async () => {
    const element = createComponent();
    getAccountHealthAdapter.emit(MOCK_GREEN_DATA);
    await flushPromises();

    const refreshButton = element.shadowRoot.querySelector('lightning-button');
    refreshButton.dispatchEvent(new CustomEvent('click'));
    await flushPromises();

    expect(refreshApex).toHaveBeenCalledTimes(1);
  });
});
