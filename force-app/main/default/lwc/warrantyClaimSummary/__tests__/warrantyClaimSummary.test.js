import { refreshApex } from '@salesforce/apex';
import { createElement } from 'lwc';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import WarrantyClaimSummary from 'c/warrantyClaimSummary';
import getWarrantyClaimSummary from '@salesforce/apex/WarrantyClaimSummaryController.getWarrantyClaimSummary';

jest.mock(
  '@salesforce/apex',
  () => ({
    refreshApex: jest.fn(() => Promise.resolve())
  }),
  { virtual: true }
);

const getWarrantyClaimSummaryAdapter = registerApexTestWireAdapter(getWarrantyClaimSummary);

const MOCK_SUMMARY = {
  totalClaims: 8,
  approvedClaims: 3,
  pendingClaims: 4
};

const MOCK_ERROR = {
  body: {
    message: 'Unable to load warranty claim summary data.'
  }
};

const flushPromises = () => new Promise((resolve) => setTimeout(resolve, 0));

function createComponent(recordId) {
  const element = createElement('c-warranty-claim-summary', {
    is: WarrantyClaimSummary
  });

  if (recordId) {
    element.recordId = recordId;
  }

  document.body.appendChild(element);
  return element;
}

describe('c-warranty-claim-summary', () => {
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
    expect(spinner.alternativeText).toBe('Loading warranty claim summary');
  });

  it('renders summary counts when wire data loads', async () => {
    const element = createComponent();
    getWarrantyClaimSummaryAdapter.emit(MOCK_SUMMARY);
    await flushPromises();

    expect(element.shadowRoot.querySelector('[data-metric="total"]').textContent).toBe('8');
    expect(element.shadowRoot.querySelector('[data-metric="approved"]').textContent).toBe('3');
    expect(element.shadowRoot.querySelector('[data-metric="pending"]').textContent).toBe('4');
  });

  it('renders the error state when the wire emits an error', async () => {
    const element = createComponent();
    getWarrantyClaimSummaryAdapter.error(MOCK_ERROR);
    await flushPromises();

    const errorPanel = element.shadowRoot.querySelector('.state-panel_error');

    expect(errorPanel).not.toBeNull();
    expect(errorPanel.textContent).toContain('Unable to load warranty claim summary data.');
  });

  it('calls refreshApex when the refresh button is clicked', async () => {
    const element = createComponent('001000000000001AAA');
    getWarrantyClaimSummaryAdapter.emit(MOCK_SUMMARY);
    await flushPromises();

    const refreshButton = element.shadowRoot.querySelector('lightning-button');
    refreshButton.dispatchEvent(new CustomEvent('click'));
    await flushPromises();

    expect(refreshApex).toHaveBeenCalledTimes(1);
  });
});
