import { LightningElement } from 'lwc';
import getWithSharing from '@salesforce/apex/SEC_SharingDemoController.runWithSharing';
import getWithoutSharing from '@salesforce/apex/SEC_SharingDemoController.runWithoutSharing';
import getNoKeyword from '@salesforce/apex/SEC_SharingDemoController.runNoKeyword';
import getInheritedDirect from '@salesforce/apex/SEC_SharingDemoController.runInheritedDirectly';
import getInheritedViaWrapper from '@salesforce/apex/SEC_SharingDemoController.runInheritedViaWrapper';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency' },
    { label: 'Industry', fieldName: 'Industry' }
];

export default class Sec_BlockA extends LightningElement {
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
                label: 'with sharing',
                explanation: 'Sharing enforced — only shared records visible.',
                fn: getWithSharing
            },
            {
                label: 'without sharing',
                explanation: 'Sharing bypassed — all records visible.',
                fn: getWithoutSharing
            },
            {
                label: 'no keyword (called directly)',
                explanation: 'No declaration + top of call stack = defaults to WITH SHARING(called from lwc).',
                fn: getNoKeyword
            },
            {
                label: 'inherited sharing (called directly)',
                explanation: 'Same top-of-stack default as "no keyword" above, defaults to "WITH SHARING"',
                fn: getInheritedDirect
            },
            {
                label: 'inherited sharing (via a "without sharing" wrapper)',
                explanation: 'Same class as above — but now inherits WITHOUT SHARING from its caller.',
                fn: getInheritedViaWrapper
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