import { LightningElement } from 'lwc';
import getNoCheck from '@salesforce/apex/SEC_AccountService_CRUDFLS.getAccountsNoCheck';
import getObjectCheck from '@salesforce/apex/SEC_AccountService_CRUDFLS.getAccountsObjectCheck';
import getFieldCheck from '@salesforce/apex/SEC_AccountService_CRUDFLS.getAccountsFieldCheck';
import getSecurityEnforced from '@salesforce/apex/SEC_AccountService_CRUDFLS.getAccountsSecurityEnforced';
import getUserMode from '@salesforce/apex/SEC_AccountService_CRUDFLS.getAccountsUserMode';
import getStripInaccessible from '@salesforce/apex/SEC_AccountService_CRUDFLS.getAccountsStripInaccessible';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency' },
    { label: 'Industry', fieldName: 'Industry' }
];

export default class Sec_BlockB extends LightningElement {
    columns = COLUMNS;
    results = [];
    isLoading = false;

    connectedCallback() {
        this.runAll();
    }

    async runAll() {
        this.isLoading = true;

        const calls = [
            {
                label: '1. No check at all',
                explanation: 'System mode ignores object/field permissions — returns everything.',
                fn: getNoCheck
            },
            {
                label: '2. Manual object-level check',
                explanation: 'Schema.sObjectType.Account.isAccessible() — empty list if object is not readable.',
                fn: getObjectCheck
            },
            {
                label: '3. Manual field-level check (Name, AnnualRevenue, Industry only)',
                explanation: 'Only checks Name, AnnualRevenue, Industry, if you include any other field in query it will leak through if unchecked.',
                fn: getFieldCheck
            },
            {
                label: '4. WITH SECURITY_ENFORCED',
                explanation: 'Throws if ANY selected field is inaccessible. Does not affect sharing.',
                fn: getSecurityEnforced
            },
            {
                label: '5. WITH USER_MODE',
                explanation: 'Enforces object + field + sharing, overriding the class\u2019s own sharing keyword.',
                fn: getUserMode
            },
            {
                label: '6. Security.stripInaccessible',
                explanation: 'Not throw — silently nulls out fields the user cannot see, Throws - If no access to Object itself.',
                fn: getStripInaccessible
            }
        ];

        this.results = await Promise.all(
            calls.map(async ({ label, explanation, fn }) => {
                try {
                    const records = await fn();
                    return { label, explanation, count: records.length, records, error: null };
                } catch (e) {
                    return {
                        label,
                        explanation,
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