import { LightningElement } from 'lwc';
import searchInjectable from '@salesforce/apex/SEC_AccountService_Dynamic.searchInjectable';
import searchBindVariable from '@salesforce/apex/SEC_AccountService_Dynamic.searchBindVariable';
import searchEscaped from '@salesforce/apex/SEC_AccountService_Dynamic.searchEscaped';
import searchUserMode from '@salesforce/apex/SEC_AccountService_Dynamic.searchUserMode';
import searchSoslUserMode from '@salesforce/apex/SEC_AccountService_Dynamic.searchSoslUserMode';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency' },
    { label: 'Industry', fieldName: 'Industry' }
];

export default class Sec_BlockD extends LightningElement {
    columns = COLUMNS;
    searchTerm = "' OR Name != '";
    results = [];
    isLoading = false;

    handleTermChange(event) {
        this.searchTerm = event.target.value;
    }

    async runAll() {
        this.isLoading = true;

        const calls = [
            {
                label: '1. Injectable (string concatenation)',
                risk: 'VULNERABLE — try the default term above to see the breakout.',
                fn: searchInjectable
            },
            {
                label: '2. Bind variable (:likeTerm)',
                risk: 'Safe — the term is always treated as a literal value.',
                fn: searchBindVariable
            },
            {
                label: '3. String.escapeSingleQuotes',
                risk: 'Safe — quotes are escaped before concatenation.',
                fn: searchEscaped
            },
            {
                label: '4. Dynamic SOQL + AccessLevel.USER_MODE',
                risk: 'Safe from injection AND enforces CRUD/FLS/sharing.',
                fn: searchUserMode
            },
            {
                label: '5. SOSL + AccessLevel.USER_MODE',
                risk: 'Same enforcement, via Search.query instead of SOQL.',
                fn: searchSoslUserMode
            }
        ];

        this.results = await Promise.all(
            calls.map(async ({ label, risk, fn }) => {
                try {
                    const records = await fn({ term: this.searchTerm });
                    return { label, risk, count: records.length, records, error: null };
                } catch (e) {
                    return {
                        label,
                        risk,
                        count: 0,
                        records: [],
                        error: (e && e.body && e.body.message) || e.message || 'Unknown error'
                    };
                }
            })
        );

        this.isLoading = false;
    }
}