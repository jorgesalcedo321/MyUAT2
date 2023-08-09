import {LightningElement, api, track, wire} from 'lwc';
import getAgreementFromProjectId from '@salesforce/apex/agreementQueries.getAgreementFromProjectId';
export default class GetDatafieldFromObject extends LightningElement {
    @api recordId;
    @api objectName;
    @api fieldName;
    @track relatedRecordId;
    @track fields = [];
    @track showFields = false;
    async connectedCallback() {
        console.log('####this.recordId:' + this.recordId);
        var agreement = await getAgreementFromProjectId({projectId : this.recordId });
        console.log('####agreement:' + agreement);

        if (agreement != null) {
            this.fields.push(this.fieldName);
            console.log('####this.fields:' + this.fields);
            this.relatedRecordId = agreement['Id'];
            console.log('####this.relatedRecordId:' + this.relatedRecordId);
            this.showFields = true;
        }
    }
}