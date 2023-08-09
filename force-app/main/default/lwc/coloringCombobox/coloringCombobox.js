import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
//import { getPicklistValues } from 'lightning/uiObjectInfoApi'; //get picklist values https://salesforce.stackexchange.com/questions/260959/lwc-get-pick-list-field-values
import getPickListValuesFromDatafield from '@salesforce/apex/RiskController.getPickListValuesFromDatafield';
import getLabelFromDatafield from '@salesforce/apex/RiskController.getLabelFromDatafield';
import getHelpTextFromDatafield from '@salesforce/apex/RiskController.getHelpTextFromDatafield';
import checkIfUserCanEditDatafield from '@salesforce/apex/RiskController.checkIfUserCanEditDatafield';
//import TYPE_FIELD from '@salesforce/schema/ampi__Geographical_Area__c.ampi__Type__c';
//import POTENTIAL_IMPACT_FIELD from '@salesforce/schema/ampi__Risk__c.ampi__Potential_Impact__c';
//import ID_FIELD from '@salesforce/schema/ampi__Risk__c.Id';
//import My_Resources from '@salesforce/resourceUrl/myResources';

export default class ColoringCombobox extends LightningElement {
	//backgroundColors = My_Resources + '/images/Colors.png';
	@api oldOptionIndex = -1;
	@api newOptionIndex = -1;
	@api includingNoneItem = false;
	@api recordId;
	@api objectName;
	@api picklistDatafield; // = 'ampi__Potential_Impact__c';
	@api colorCodes;
	@api userCannotEditField;
	@api labelDatafield;
	@api selectedOptionOldValue;
	@api selectedOptionColor;
	@api helpTextDescription;
	@api showHelpText;
	@api isInForm = false;
	@api editMode = false;
	@api coloringClass = 'slds-grid slds-wrap coloring-style';
	@track isLoading = true;
	@track picklistVisible;
	@track changesOnPicklist = false;
	@track selectedOptionValue;
	@track coloringDefault = ['#009900','#33cc00','#ffcc66','#ff9900','#ff0000'];
	@api picklistClass = 'slds-select';
	@api coloringContainer = 'slds-col slds-size_1-of-2';
	@track statusOptions = [];
		
	@wire(checkIfUserCanEditDatafield, { objectName: '$objectApiName', datafield: '$picklistDatafield'})
    userCanEdit({ error, data }) {
		if (data) {    
			if (data != null && data != undefined) {
				this.userCannotEditField = !data;
			} else {
				this.userCannotEditField = true;
			} 
		} else if (error) {
			this.userCannotEditField = true;
			this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Error: cant get permission to Edit field',
                    variant: 'error'
                })
             );
		}
	}

	//get backgroundStyle() {
    //    return `background-image:url(${backgroundColors}) !important`;
    //}

	//@wire(getRecord, { recordId: '$recordId', fields: [POTENTIAL_IMPACT_FIELD]})
	@wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View']})
    risk({ error, data }) {
		if (data) {    
			if (data != null && data != undefined) {
				if (data.fields[this.picklistDatafield] != undefined && data.fields[this.picklistDatafield].value != undefined) {
					this.selectedOptionValue = data.fields[this.picklistDatafield].value;				
					this.selectedOptionOldValue = data.fields[this.picklistDatafield].value;				
				} 	
			} 
		}
		else if (error) {
			this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Error: cant access to risk',
                    variant: 'error'
                })
             );
		}
	}

	@wire(getLabelFromDatafield, {objectName: '$objectApiName', datafield: '$picklistDatafield'})
	getLabelFromDatafield({ error, data }) {
		if (data) {    
			if (data != null && data != undefined) {
				this.labelDatafield = data;
			} 
		} else if (error) {
			this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Error: cant get label from datafield',
                    variant: 'error'
                })
             );			
		} 
	}

	@wire(getHelpTextFromDatafield, {objectName: '$objectApiName', datafield: '$picklistDatafield'})
	getHelpTextFromDatafield({ error, data }) {
		this.showHelpText = false;
		if (data) {    
			if (data != null && data != undefined && data != '') {
				this.helpTextDescription = data;
				this.showHelpText = true;		
			} 
		} else if (error) {
			this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Error: cant get helpTextDescription from datafield',
                    variant: 'error'
                })
             );			
		} 
	}

	@wire(getPickListValuesFromDatafield, {objectName: '$objectApiName', picklistDatafield: '$picklistDatafield'})
	getPickListValuesFromDatafield({ error, data }) {
		if (data) {    
			if (data != null && data != undefined) {
				this.oldData = data;
				this.fillComboboxItems(data);
			} 
		} else if (error) {
			this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Error: cant get potential impact values.',
                    variant: 'error'
                })
             );
		} 
	}

	fillComboboxItems(data) {
		this.statusOptions = [];
		this.includingNoneItem = true;

		if (this.includingNoneItem) {
			this.statusOptions.push({	
					value: '', 
					label: '--None--',
					checked: this.selectedOptionValue == '',
					colorstyle: 'color_image_none'
					//colorstyle: 'background-Color: white !important; width: 95%;'
			});
		}

		for(let i=0; i<data.length; i++) {
			if (this.selectedOptionValue == data[i]) {
				this.oldOptionIndex = i;
				if (this.includingNoneItem) {
					this.oldOptionIndex = this.oldOptionIndex + 1;
				}
			}
			this.statusOptions.push({	
				value: data[i], 
				// label: i + ' ' + data[i],
				label: data[i],
				checked: this.selectedOptionValue == data[i],
				//colorstyle: 'background-Color: ' + this.coloringDefault[i] + ' !important; width: 95%;'
				colorstyle: 'color_image_' + (i + 1)
			});
		}
		this.changeOptionHandler(this.selectedOptionValue, false);
	}
	

	/*@wire(updateDynamicObject, {objectName: '$objectRiskName', riskId: '$recordIdRisk', datafield: '$picklistDatafield', value: '$selectedOptionValue'})
	updateDynamicObject({error, data}) {		
	}*/

	refreshComponent() {
		this.selectedOptionValue = this.selectedOptionOldValue;
		this.changesOnPicklist = false;
		this.picklistVisible = false;
		this.fillComboboxItems(this.oldData);
		const lwcInputFields = this.template.querySelector("select");
		if (lwcInputFields != null && lwcInputFields != undefined) {
			lwcInputFields.selectedIndex = this.oldOptionIndex;
		}
	}

	showPicklist() {
		this.picklistVisible = true; 
	}

	updateRisk() {
        // Create the recordInput object
        this.isLoading = true;
		const fieldsToUpdate = {};
		fieldsToUpdate['Id'] = this.recordId;
        fieldsToUpdate[this.picklistDatafield] = this.selectedOptionValue;
		const recordInput = { fields: fieldsToUpdate };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Risk updated',
                        variant: 'success'
                    })
                );
				this.selectedOptionOldValue = this.selectedOptionValue;
				this.refreshComponent();
				this.isLoading = false;
                // Display fresh data in the form
                // return refreshApex(this.recordId);
            })
            .catch(error => {
				var errorText = '';
				if(error.body == undefined || error.body == null) {
					errorText = error;
				} else {
					var output = error.body.output.errors;
					if (Array.isArray(output)) {
						if (output.length > 0) {
							for(var i=0; i<output.length; i++) {
								errorText += output[i]['message'] + "\n";
							}
						}
					}

					if (errorText == '') {
						errorText = error.body.message;
					}
				}

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating risk record',
                        message: errorText,
                        variant: 'error'
                    })
                );
				this.isLoading = false;
        });
    }

	sendFormInfo() {
		const fieldsToUpdate = {};		
		fieldsToUpdate['datafield'] = this.picklistDatafield;
        fieldsToUpdate['value'] = this.selectedOptionValue;
		fieldsToUpdate['valueChanged'] = (this.selectedOptionValue !== this.selectedOptionOldValue);
		
		const selectedEvent = new CustomEvent("colorvalue", {
		  detail: fieldsToUpdate
		});
		this.dispatchEvent(selectedEvent);
	}

    connectedCallback() {
		/*console.log('this.objectName:' + this.objectName);
		console.log('this.recordId:' + this.recordId);
		console.log('this.picklistDatafield:' + this.picklistDatafield);
		console.log('this.colorCodes:' + this.colorCodes);*/
		
		this.objectApiName = this.objectName;
		this.isLoading = false;
		
		if (this.isInForm) {
			this.coloringClass = 'slds-grid slds-wrap coloring-in-form-style';
			this.coloringContainer = 'slds-col';
		}
	}

	processColorCodes() {
		var codes = this.colorCodes.split(',');

		if (codes.length > 0) {
			this.coloringDefault = [];
			for (var i = 0; i < codes.length; i++) {
				this.coloringDefault.push(codes[i]);
			}
		}
	}

    changeHandler(event) {
		const field = event.target.name;
		if (field === 'optionSelect' && event != undefined) {
			this.changeOptionHandler(event.target.value, true);			
        }
		this.picklistVisible = false;
    }

	changeOptionHandler(value, showActions) {
		
		if (!this.isInForm) {
			this.changesOnPicklist = showActions;
		}
		this.selectedOptionValue = value;
		this.selectedOptionColor = 'background-color: transparent !important; width: 95%;';
		for (let i=0; i<this.statusOptions.length; i++) {
			if (this.statusOptions[i].value == this.selectedOptionValue) {
				this.selectedOptionColor = this.statusOptions[i].colorstyle;
				this.selectedOptionValue = this.statusOptions[i].value;
				//this.picklistClass = 'slds-select ' + this.selectedOptionColor;
				this.newOptionIndex = i;
			} 
		}		
		if (this.isInForm) {
			this.sendFormInfo();
		}
	}
}