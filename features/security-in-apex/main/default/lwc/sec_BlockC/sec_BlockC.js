import { LightningElement } from 'lwc';
import getAccounts from '@salesforce/apex/SEC_AccountService_DML.getAccounts';
import updateNoCheck from '@salesforce/apex/SEC_AccountService_DML.updateAccountNoCheck';
import updateFieldCheck from '@salesforce/apex/SEC_AccountService_DML.updateAccountFieldCheck';
import updateObjectCheck from '@salesforce/apex/SEC_AccountService_DML.updateAccountObjectCheck';
import updateAsUser from '@salesforce/apex/SEC_AccountService_DML.updateAccountAsUser';
import updateUserModeDb from '@salesforce/apex/SEC_AccountService_DML.updateAccountUserModeDb';
import updateStripInaccessible from '@salesforce/apex/SEC_AccountService_DML.updateAccountStripInaccessible';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency' }
];

export default class Sec_BlockC extends LightningElement {
    accountId = '';
    newName = '';
    annualRevenue = null;
    accounts = [];
    columns = COLUMNS;
    log = []; // newest first: { id, method, message, isError, timestamp }

    connectedCallback() {
        this.fetchAccounts();
    }

    async fetchAccounts() {
        try {
            this.accounts = await getAccounts();
        } catch (e) {
            console.error('Error fetching accounts: ', e);
        }
    }

    handleAccountSelect(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            this.accountId = selectedRows[0].Id;
            this.newName = selectedRows[0].Name;
            this.annualRevenue = selectedRows[0].AnnualRevenue;
        } else {
            this.accountId = '';
            this.newName = '';
            this.annualRevenue = null;
        }
    }

    handleAccountIdChange(event) {
        this.accountId = event.target.value;
    }

    handleNewNameChange(event) {
        this.newName = event.target.value;
    }

    handleAnnualRevenueChange(event) {
        this.annualRevenue = event.target.value;
    }

    get canRun() {
        return this.accountId && (this.newName || this.annualRevenue);
    }

    async runMethod(label, apexFn) {
        if (!this.accountId) {
            this.addLogEntry(label, 'Enter an Account Id first.', true);
            return;
        }

        if (!this.newName && !this.annualRevenue) {
            this.addLogEntry(label, 'Name and Annual Revenue cannot both be empty.', true);
            return;
        }

        if (this.annualRevenue && Number(this.annualRevenue) < 0) {
            this.addLogEntry(label, 'Annual Revenue cannot be negative.', true);
            return;
        }

        if (this.newName && !isNaN(this.newName) && this.newName.trim() !== '') {
            this.addLogEntry(label, 'Name cannot be entirely numeric.', true);
            return;
        }

        try {
            const result = await apexFn({ acctId: this.accountId, newName: this.newName, annualRev: this.annualRevenue });
            const isBlocked = typeof result === 'string' && result.startsWith('BLOCKED');
            this.addLogEntry(label, result, isBlocked);
            if (!isBlocked) {
                await this.fetchAccounts();
            }
        } catch (e) {
            const message = (e && e.body && e.body.message) || e.message || 'Unknown error';
            this.addLogEntry(label, `Thrown exception — ${message}`, true);
        }
    }

    addLogEntry(method, message, isError) {
        this.log = [
            {
                id: `${Date.now()}-${Math.random()}`,
                method,
                message,
                isError,
                cssClass: isError
                    ? 'slds-box slds-theme_error slds-m-bottom_x-small'
                    : 'slds-box slds-theme_success slds-m-bottom_x-small'
            },
            ...this.log
        ];
    }

    run1NoCheck() {
        this.runMethod('1. No check at all', updateNoCheck);
    }
    run2FieldCheck() {
        this.runMethod('2. Manual field-level check', updateFieldCheck);
    }
    run3ObjectCheck() {
        this.runMethod('3. Manual object-level check', updateObjectCheck);
    }
    run4AsUser() {
        this.runMethod('4. "as user" DML', updateAsUser);
    }
    run5UserModeDb() {
        this.runMethod('5. Database.update + AccessLevel.USER_MODE', updateUserModeDb);
    }
    run6StripInaccessible() {
        this.runMethod('6. Security.stripInaccessible', updateStripInaccessible);
    }

    clearLog() {
        this.log = [];
    }
}