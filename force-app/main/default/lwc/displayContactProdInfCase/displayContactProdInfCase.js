import { LightningElement, api } from 'lwc';
import getContactProdInfDetails from '@salesforce/apex/DisplayContactProdInfCaseController.getContactProdInfDetails';

const columns = [
    { label: 'Type', fieldName: 'type', type: 'text' },
    { label: 'Value', fieldName: 'value', type: 'text' }
];

export default class DisplayContactProdInfCase extends LightningElement {
    @api recordId;
    columns = columns;
    data = [];
    error;

    // we bring the data on load
    connectedCallback() {
        getContactProdInfDetails({ caseId: this.recordId })
            .then(result => {
                if (result.errorMessage && result.errorMessage !== '') {
                    this.error = result.errorMessage;
                    this.data = [];
                } else {
                    this.error = null;
                    this.data = result.productInfoList;
                }
            })
            .catch(err => {
                this.error = 'Unexpected error: ' + err.body?.message;
                this.data = [];
            });
    }
}