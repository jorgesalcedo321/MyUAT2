import { NavigationMixin } from 'lightning/navigation';
import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import getSystemInfoFromObject from '@salesforce/apex/RiskController.getSystemInfoFromObject';
import checkIfUserCanEditDatafield from '@salesforce/apex/RiskController.checkIfUserCanEditDatafield';
import isInternal from '@salesforce/apex/customRelatedLists.isInternal';
export default class CustomFormContainer extends NavigationMixin(LightningElement) {
	@api recordId;
	@api relatedId;
	@api objectLabel;
	@api objectApiName;
	@api objectName;
	@api jsonStructure;
	@api readonlyFieldsInEdit;
	@api errorText = '';
	@api errorExist = false;
	@api allDataContainer = [];
	@api editFormVisible = false;
	@api isQuickAction;
	@track dictValues = [];
	@track isLoading = true;
	@api openSection;
    @api sectionLabel;
	@api showContentInSection = false;
	@api removeMarginTop;
	@track isInternalUrl = false;
	@track isNew = true;
	recordData;
	
	@wire(getRecord, {
		recordId: "$recordId", layoutTypes: ['Full'], modes: ['View']
	})
	wiredRecord({ error, data }) {
	  if (data) {
			this.recordData = data;
			var fields = this.recordData['fields'];
			for(var item = 0; item < this.allDataContainer.length; item++) {
				if (this.allDataContainer[item]['showDateField']) {
					if (fields[this.allDataContainer[item]['dateField']] !== undefined) {
						this.allDataContainer[item]['dateField'] = fields[this.allDataContainer[item]['dateField']]['value'];
					}
				}
			}
		} 
	}
	
	get sectionClass() {
		var style = this.openSection ? 'slds-section slds-is-open' : 'slds-section';
		if (this.removeMarginTop === false) {
			style = style + ' space-sections';
		} else {
			style = style + ' space-minor-sections';
		}

        return style;
    }
	
	async connectedCallback() {
		//alert(this.recordId);
		if (this.sectionLabel !== '' && this.sectionLabel !== undefined) {
			this.showContentInSection = true;
		}
		if (typeof this.openSection === 'undefined') this.openSection = true;
		this.isInternalUrl = await isInternal();
		this.ClassForm = 'slds-grid coloring-form-style';
		if (!this.isInternalUrl) {
			this.ClassForm = 'slds-grid coloring-form-style community-site-form';
		}
		//console.log('connectedCallback this.isLoading 1:' + this.isLoading);
		await this.loadDatafieldValues();		
		this.isLoading = false;
		this.editFormVisible = this.isQuickAction;
		//console.log('connectedCallback this.isLoading 2:' + this.isLoading);
	} 

	handleClick() {
        this.openSection = !this.openSection;
    }

	@api
	saveFromDialog() {
		this.template.querySelector('[data-id="Save_Button"]').click();            
	}
	
	async loadDatafieldValues() { 
		var json = this.jsonStructure; 
		//{"datafields": [      {"name": "Name", "type": "standard", "colors": ""}, {"name": "ampi__Description__c", "type": "standard", "colors": ""},  {"name": "ampi__Identification_Date__c", "type": "standard", "colors": ""},     {"name": "ampi__Category__c", "type": "coloringComponent", "colors": "#009900,#33cc00,#ffcc66,#ff9900,#ff0000"}    ]}
		const obj = JSON.parse(json);
		if (obj !== undefined) {
		  var value = obj['datafields'];

		  if (this.recordId !== undefined) {
		  	this.isNew = false;
	      }

		  for(var i=0; i<value.length; i++){
			if (this.recordId === undefined && value[i]['name'] === 'RecordTypeId') {
				continue;
			}
			
			var isColorComponent = value[i]['type'] === 'coloringComponent' ? true : false;
			var isRelatedComponent = value[i]['type'] === 'related' ? true : false;
			var isRequired = (value[i]['required'] === undefined || value[i]['required'] === null) ? false : value[i]['required'];
			var isReadonly = (value[i]['readonly'] === undefined || value[i]['readonly'] === null) ? false : value[i]['readonly'];
			//var isReadonlyOnEdit = (value[i]['readonly-edit'] === undefined || value[i]['readonly-edit'] === null) ? false : value[i]['readonly-edit'];
			var isAvatar = (value[i]['avatar'] === undefined || value[i]['avatar'] === null) ? false : value[i]['avatar'];
			var showDateField = (value[i]['showDate'] === undefined || value[i]['showDate'] === null) ? '' : value[i]['showDate'];
			
			//TODO: Recheck If this datafield is read-only 
			if (isReadonly == false) {
				var result = await checkIfUserCanEditDatafield({objectName: this.objectApiName, datafield : value[i]['name']});
				isReadonly = !result;
			}

			//console.log('this.objectApiName: ' + this.objectApiName);
			//console.log('this.isNew: ' + this.isNew);
			//console.log('this.readonlyFieldsInEdit: ' + this.readonlyFieldsInEdit);
			
			// console.log('this.readonlyFieldsInEdit:' + this.readonlyFieldsInEdit);
			if (this.isNew == false && this.readonlyFieldsInEdit !== undefined) {
				var readonlyEditFields = (this.readonlyFieldsInEdit + '').split(',');
				// console.log('value[i][name]:' + value[i]['name']);
				readonlyEditFields.forEach(s => {
					if (s.trim() === value[i]['name']) {
						isReadonly = true;	
					}
				});
			}

			//TODO: Field date value
			//https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_get_field_value
			
			  if (showDateField !== '' && this.recordId !== undefined) {
				  var systemInfo = await getSystemInfoFromObject({objectName: this.objectApiName, recordId : this.recordId});
		  		  //console.log('systemInfo');
				  //console.log(systemInfo.length);
				  //console.log(JSON.stringify(systemInfo));
				  if (systemInfo.length > 0) {
					showDateField = systemInfo[0][showDateField];
				  }
			  }
			var newDataContainer = new DataContainer(i, value[i]['name'], value[i]['type'], value[i]['colors'], isColorComponent, isRequired, isReadonly, isAvatar, showDateField, isRelatedComponent);
			//console.log('STEP: loadDatafieldValues');
			this.allDataContainer.push(newDataContainer);
		  }
		}
	}

	handleSubmit(event) {
		this.isLoading = true;
		event.preventDefault();       // stop the form from submitting
		var inputFields = event.detail.fields;
        console.log('onsubmit event recordEditForm'+ JSON.stringify(event.detail.fields));
		this.template.querySelector('lightning-record-edit-form').submit(inputFields);		
    }
    handleSuccess(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
		if (this.recordId == undefined) {
			this.recordId = event.detail.id;
		}

		console.log('this.objectLabel:'+this.objectLabel);
		this.errorExist = false;
		const fieldsToUpdate = {};

		if (this.dictValues === undefined) {
			this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: this.objectLabel + ' updated',
                    variant: 'success'
                })
            );
		} else {
			fieldsToUpdate['Id'] = this.recordId;
			
			for (var i=0; i<this.dictValues.length;i++){
				var json = JSON.parse(this.dictValues[i]);
				if (json['value'] === undefined)
					continue;

				fieldsToUpdate[json['datafield']] = json['value'];
			}
			console.log('fieldsToUpdate:'+JSON.stringify(fieldsToUpdate));
			const recordInput = { fields: fieldsToUpdate };
			this.isLoading = true;
			updateRecord(recordInput).then(() => {
				//IN CASE OF SUCCESS
				this.editFormVisible = false;
				this.isLoading = false;
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Success',
						message: this.objectLabel + ' updated',
						variant: 'success'
					})
				);
			}).catch(error => {
				this.errorExist = true;
				this.errorText = '';
				this.isLoading = false;
				var output = error.body.output.errors;
				if (Array.isArray(output)) {
					if (output.length > 0) {
						for (var i = 0; i < output.length; i++) {
							this.errorText += output[i]['message'] + "\n";
						}
					}
				}
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Error updating ' + this.objectLabel + ' record',
						message: this.errorText,
						variant: 'error'
					})
				);
			});
		}
		this.isLoading = false;

		if (this.isQuickAction) {
			const valueChangeEvent = new CustomEvent("valuechange", {
			detail: { errorExist: this.errorExist, id: this.recordId }
			});
			// Fire the custom event
			this.dispatchEvent(valueChangeEvent);
		}		
    }
	handleError(event) {
	    console.log('onerror event recordEditForm', event);
	    console.log('onerror event recordEditForm JSON', JSON.stringify(event));
		this.isLoading = false;
	}

	/*updateObject(event) {
	    console.log('updateObject event recordEditForm'+ event);
	    console.log('updateObject event detail recordEditForm'+ event.detail);
	    console.log('updateObject event detail fields recordEditForm'+ event.detail.fields);
	    event.preventDefault();       // stop the form from submitting
	    const fields = event.detail.fields;
		const inputFields = this.template.querySelectorAll(
		   'lightning-input-field'
	    );
	    console.log('fields JSON:'+JSON.stringify(inputFields));
	    this.template.querySelector('lightning-record-edit-form').submit(inputFields);		
	}*/

	refreshComponent(event) {
		this.isLoading = true;
		console.log('refreshComponent this.isLoading 1:' + this.isLoading);
	    console.log('refreshComponent event recordEditForm'+ event.detail.fields);
		const inputFields = this.template.querySelectorAll(
		   'lightning-input-field'
	    );
	    if (inputFields) {
		   inputFields.forEach(field => {
			   field.reset();
		   });
	    }
		this.editFormVisible = false;
		this.isLoading = false;
		console.log('refreshComponent this.isLoading 2:' + this.isLoading);
		//MISSING RESET COLORING COMPONENT
		//https://salesforcediaries.com/2019/07/24/lwc-communication-part-1-passing-data-from-parent-to-child-component/
	}

	handleColorValueChange(event) {
		//PASS INFO FROM CHILD TO PARENT LWC
		//https://salesforcediaries.com/2019/08/07/lwc-communication-part-2-passing-data-from-child-to-parent-in-lwc/
		var dataToUpdate = JSON.stringify(event.detail);
		// {"datafield":"ampi__Probability__c","value":"Likely"}
		
		if (event.detail['valueChanged'] === true) {
			this.dictValues = this.dictValues.filter(s => JSON.parse(s)['datafield']!==event.detail['datafield']);
			this.dictValues.push(dataToUpdate);
			this.showEditForm();
		}
	}

	showEditForm() {
		this.editFormVisible = true;
	}
}

	class DataContainer {
	  constructor(index, name, type, colors, isColorComponent, required, readonly, avatar, dateField, isRelatedComponent) {
		this.formIndex = 'Form' + index;
		this.index = index;
		this.name = name;
		this.type = type;
		this.colors = colors;
		this.isColorComponent = isColorComponent;
		this.isRelatedComponent = isRelatedComponent;
		this.required = required;
		this.readonly = readonly;
		this.avatar = avatar;
		this.dateField = dateField;
		this.showDateField = (dateField !== undefined && dateField !== '');
		this.className = this.showDateField ? 'slds-size_2-of-5' : 'slds-size_4-of-5';
	  }
	}