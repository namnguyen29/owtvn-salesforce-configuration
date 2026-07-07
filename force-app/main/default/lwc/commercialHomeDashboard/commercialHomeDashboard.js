import { refreshApex } from "@salesforce/apex";
import { LightningElement, wire } from "lwc";
import { getListUi } from "lightning/uiListApi";

const DEFAULT_SORT_BY = "name";
const DEFAULT_SORT_DIRECTION = "asc";

const PANEL_CONFIG = {
  account: {
    key: "account",
    label: "Accounts",
    objectApiName: "Account",
    listViewApiName: "AllAccounts",
    emptyMessage: "No accounts are available.",
    columns: [
      {
        label: "Name",
        fieldName: "recordUrl",
        type: "url",
        sortable: true,
        typeAttributes: {
          label: { fieldName: "name" },
          target: "_self"
        }
      },
      { label: "Industry", fieldName: "industry", type: "text", sortable: true },
      { label: "Phone", fieldName: "phone", type: "phone", sortable: true },
      { label: "Type", fieldName: "type", type: "text", sortable: true }
    ]
  },
  contact: {
    key: "contact",
    label: "Contacts",
    objectApiName: "Contact",
    listViewApiName: "AllContacts",
    emptyMessage: "No contacts are available.",
    columns: [
      {
        label: "Name",
        fieldName: "recordUrl",
        type: "url",
        sortable: true,
        typeAttributes: {
          label: { fieldName: "name" },
          target: "_self"
        }
      },
      { label: "Title", fieldName: "title", type: "text", sortable: true },
      { label: "Email", fieldName: "email", type: "email", sortable: true },
      { label: "Phone", fieldName: "phone", type: "phone", sortable: true }
    ]
  },
  asset: {
    key: "asset",
    label: "Assets",
    objectApiName: "Asset",
    listViewApiName: "AllAssets",
    emptyMessage: "No assets are available.",
    columns: [
      {
        label: "Name",
        fieldName: "recordUrl",
        type: "url",
        sortable: true,
        typeAttributes: {
          label: { fieldName: "name" },
          target: "_self"
        }
      },
      { label: "Serial Number", fieldName: "serialNumber", type: "text", sortable: true },
      { label: "Status", fieldName: "status", type: "text", sortable: true },
      { label: "Install Date", fieldName: "installDate", type: "date", sortable: true }
    ]
  },
  campaign: {
    key: "campaign",
    label: "Campaigns",
    objectApiName: "Campaign",
    listViewApiName: "AllActiveCampaigns",
    emptyMessage: "No campaigns are available.",
    columns: [
      {
        label: "Name",
        fieldName: "recordUrl",
        type: "url",
        sortable: true,
        typeAttributes: {
          label: { fieldName: "name" },
          target: "_self"
        }
      },
      { label: "Type", fieldName: "type", type: "text", sortable: true },
      { label: "Status", fieldName: "status", type: "text", sortable: true },
      { label: "Start Date", fieldName: "startDate", type: "date", sortable: true }
    ]
  }
};

export default class CommercialHomeDashboard extends LightningElement {
  panelState = this.createInitialPanelState();

  get panels() {
    return Object.values(PANEL_CONFIG).map((panel) => {
      const state = this.panelState[panel.key];

      return {
        ...panel,
        count: state.count,
        rows: state.rows,
        sortBy: state.sortBy,
        sortDirection: state.sortDirection,
        hasRows: state.rows.length > 0,
        isLoading: state.isLoading,
        hasError: Boolean(state.errorMessage),
        errorMessage: state.errorMessage,
        showEmpty: !state.isLoading && !state.errorMessage && state.rows.length === 0,
        headingId: `${panel.key}-heading`,
        summaryText: `${panel.label}: ${state.count} record${state.count === 1 ? "" : "s"} loaded.`
      };
    });
  }

  @wire(getListUi, {
    objectApiName: PANEL_CONFIG.account.objectApiName,
    listViewApiName: PANEL_CONFIG.account.listViewApiName,
    pageSize: 5
  })
  wiredAccounts(result) {
    this.handleListUiResult("account", result, (record) => ({
      id: this.getRecordId(record),
      recordUrl: `/${this.getRecordId(record)}`,
      name: this.getFieldValue(record, "Name"),
      industry: this.getFieldValue(record, "Industry"),
      phone: this.getFieldValue(record, "Phone"),
      type: this.getFieldValue(record, "Type")
    }));
  }

  @wire(getListUi, {
    objectApiName: PANEL_CONFIG.contact.objectApiName,
    listViewApiName: PANEL_CONFIG.contact.listViewApiName,
    pageSize: 5
  })
  wiredContacts(result) {
    this.handleListUiResult("contact", result, (record) => ({
      id: this.getRecordId(record),
      recordUrl: `/${this.getRecordId(record)}`,
      name: this.getFieldValue(record, "Name"),
      title: this.getFieldValue(record, "Title"),
      email: this.getFieldValue(record, "Email"),
      phone: this.getFieldValue(record, "Phone")
    }));
  }

  @wire(getListUi, {
    objectApiName: PANEL_CONFIG.asset.objectApiName,
    listViewApiName: PANEL_CONFIG.asset.listViewApiName,
    pageSize: 5
  })
  wiredAssets(result) {
    this.handleListUiResult("asset", result, (record) => ({
      id: this.getRecordId(record),
      recordUrl: `/${this.getRecordId(record)}`,
      name: this.getFieldValue(record, "Name"),
      serialNumber: this.getFieldValue(record, "SerialNumber"),
      status: this.getFieldValue(record, "Status"),
      installDate: this.getFieldValue(record, "InstallDate") || null
    }));
  }

  @wire(getListUi, {
    objectApiName: PANEL_CONFIG.campaign.objectApiName,
    listViewApiName: PANEL_CONFIG.campaign.listViewApiName,
    pageSize: 5
  })
  wiredCampaigns(result) {
    this.handleListUiResult("campaign", result, (record) => ({
      id: this.getRecordId(record),
      recordUrl: `/${this.getRecordId(record)}`,
      name: this.getFieldValue(record, "Name"),
      type: this.getFieldValue(record, "Type"),
      status: this.getFieldValue(record, "Status"),
      startDate: this.getFieldValue(record, "StartDate") || null
    }));
  }

  handleSort(event) {
    const panelKey = event.currentTarget.dataset.panelKey;
    const { fieldName, sortDirection } = event.detail;
    const state = this.panelState[panelKey];

    this.setPanelState(panelKey, {
      ...state,
      sortBy: fieldName,
      sortDirection,
      rows: this.sortRows(state.rawRows, fieldName, sortDirection)
    });
  }

  async handleReset(event) {
    const panelKey = event.currentTarget.dataset.panelKey;
    const state = this.panelState[panelKey];
    const resetState = {
      ...state,
      isLoading: Boolean(state.wiredResult),
      errorMessage: "",
      sortBy: DEFAULT_SORT_BY,
      sortDirection: DEFAULT_SORT_DIRECTION,
      rows: this.sortRows(state.rawRows, DEFAULT_SORT_BY, DEFAULT_SORT_DIRECTION)
    };

    this.setPanelState(panelKey, resetState);

    if (!state.wiredResult) {
      return;
    }

    try {
      await refreshApex(state.wiredResult);
    } catch (error) {
      this.setPanelState(panelKey, {
        ...this.panelState[panelKey],
        errorMessage: this.reduceErrors(error)
      });
    } finally {
      const refreshedState = this.panelState[panelKey];

      if (refreshedState.isLoading) {
        this.setPanelState(panelKey, {
          ...refreshedState,
          isLoading: false
        });
      }
    }
  }

  createInitialPanelState() {
    return {
      account: this.createPanelState(),
      contact: this.createPanelState(),
      asset: this.createPanelState(),
      campaign: this.createPanelState()
    };
  }

  createPanelState() {
    return {
      count: 0,
      rawRows: [],
      rows: [],
      isLoading: true,
      errorMessage: "",
      sortBy: DEFAULT_SORT_BY,
      sortDirection: DEFAULT_SORT_DIRECTION,
      wiredResult: undefined
    };
  }

  handleListUiResult(panelKey, result, transformRow) {
    const { data, error } = result;
    const currentState = this.panelState[panelKey];

    if (data) {
      const listRecords = data.records?.records ?? [];
      const rawRows = listRecords.map(transformRow);

      this.setPanelState(panelKey, {
        ...currentState,
        wiredResult: result,
        count: data.records?.count ?? rawRows.length,
        rawRows,
        rows: this.sortRows(rawRows, currentState.sortBy, currentState.sortDirection),
        isLoading: false,
        errorMessage: ""
      });
      return;
    }

    if (error) {
      this.setPanelState(panelKey, {
        ...currentState,
        wiredResult: result,
        rawRows: [],
        rows: [],
        count: 0,
        isLoading: false,
        errorMessage: this.reduceErrors(error)
      });
      return;
    }

    this.setPanelState(panelKey, {
      ...currentState,
      wiredResult: result,
      isLoading: true
    });
  }

  setPanelState(panelKey, nextState) {
    this.panelState = {
      ...this.panelState,
      [panelKey]: nextState
    };
  }

  sortRows(rows, sortBy, sortDirection) {
    const direction = sortDirection === "desc" ? -1 : 1;

    return [...rows].sort((leftRecord, rightRecord) => {
      const leftValue = this.normalizeSortValue(leftRecord[sortBy]);
      const rightValue = this.normalizeSortValue(rightRecord[sortBy]);

      if (leftValue > rightValue) {
        return direction;
      }

      if (leftValue < rightValue) {
        return -direction;
      }

      return 0;
    });
  }

  normalizeSortValue(value) {
    if (value === null || value === undefined) {
      return "";
    }

    if (typeof value === "string") {
      return value.toLowerCase();
    }

    return value;
  }

  getRecordId(record) {
    return record.id ?? record.fields?.Id?.value ?? "";
  }

  getFieldValue(record, fieldApiName) {
    const field = record.fields?.[fieldApiName];

    return field?.displayValue ?? field?.value ?? "";
  }

  reduceErrors(errors) {
    const normalizedErrors = Array.isArray(errors) ? errors : [errors];

    return normalizedErrors
      .filter(Boolean)
      .map((error) => {
        if (typeof error === "string") {
          return error;
        }

        if (error.message) {
          return error.message;
        }

        return "Unable to load records.";
      })
      .join("; ");
  }
}
