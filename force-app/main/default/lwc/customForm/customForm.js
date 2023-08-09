import {LightningElement, api, track, wire} from 'lwc';
import RiskReviewer from '@salesforce/schema/Account.NA_Risk_Reviewer__c';
import RiskApprover from '@salesforce/schema/Account.NA_Director__c';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import isSOSOrganisationMA from '@salesforce/apex/RiskController.isSOSOrganisationMA';
import { getRecord, updateRecord  } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

export default class CustomForm extends LightningElement {
	@api recordId;
	@api objectName;
	@api labelDatafield;
	@api showFields;	
	@track fields = [RiskReviewer, RiskApprover];

	@wire(isSOSOrganisationMA, {objectName: '$objectApiName', accountId: '$recordId'})
	areEditFieldsShown({ error, data }) {
		if (data) {    
			if (data != null && data != undefined) {
				this.showFields = data;
			} else {
				this.showFields = false;
			}
		} else if (error) {
			this.showFields = false;
		}
	}

    connectedCallback() {
		this.objectApiName = this.objectName;
	}

	//STEPS FROM => https://www.youtube.com/watch?v=e12EYkkpK1s
	// AND https://www.youtube.com/watch?v=DeLkHw7iEbg
	/*handleError(){
		const toastMsg = new ShowToastEvent({
			title: 'Error!',
			message: 'Data Error occurred',
			variant: 'error',
			mode: 'dissmissable'
		});
		this.dispatchEvent(toastMsg);
	}

	handleLoad(event){
		const toastMsg = new ShowToastEvent({
			title: 'Loaded',
			message: 'Data Loaded',
			variant: 'Info',
			mode: 'dissmissable'
		});
		this.dispatchEvent(toastMsg);
	}

	handleSuccess(event){
		const toastMsg = new ShowToastEvent({
			title: 'Success',
			message: 'Data Saved Successfully',
			variant: 'success',
			mode: 'dissmissable'
		});
		this.dispatchEvent(toastMsg);
	}*/
}