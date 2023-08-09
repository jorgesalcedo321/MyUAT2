import {LightningElement, api, track, wire} from 'lwc';
import CheckIfCanUpdateResultByProject from '@salesforce/apex/ExtraCreateObjects.CheckIfCanUpdateResultByProject';
export default class ShowTargetResultErrorMesage extends LightningElement {
    @api recordId;
    @track showMessage = false;
    @track message;   

     async connectedCallback() {
        console.log('####this.recordId: ' + this.recordId);
        this.message = await CheckIfCanUpdateResultByProject({projectId : this.recordId});
        console.log('####this.message: ' + this.message);
        
        this.showMessage = this.message != '';
    }
}