import { NavigationMixin } from 'lightning/navigation';
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue, updateRecord, createRecord } from 'lightning/uiRecordApi';
import isInternal from '@salesforce/apex/customRelatedLists.isInternal';
import getAddressFromOrganisation from '@salesforce/apex/RiskController.getAddressFromOrganisation';
import updateAddressFromOrganisation from '@salesforce/apex/RiskController.updateAddressFromOrganisation';
import getAddressFromPUs from '@salesforce/apex/RiskController.getAddressFromPUs';
import getCountryNameFromAddress from '@salesforce/apex/RiskController.getCountryNameFromAddress';
import updateAddressFromPUs from '@salesforce/apex/RiskController.updateAddressFromPUs';
import insertAddress from '@salesforce/apex/RiskController.insertAddress';
import updateAddress from '@salesforce/apex/RiskController.updateAddress';
import checkIfUserCanEditDatafield from '@salesforce/apex/RiskController.checkIfUserCanEditDatafield';
import checkIfUserCanCreateObject from '@salesforce/apex/RiskController.checkIfUserCanCreateObject';

export default class AddressForm extends NavigationMixin(LightningElement) {
	@api recordId;
	@api objectType;
	@api isAdditional;
	@api showMaps;
	@track isReadonly = false;
	@track objectLabel = 'Address';
	@api objectApiName;
	@api errorText = '';
	@api errorExist = false;
	@api allDataContainer = [];

	@track recordContainer = [];
	@track countryName = '';
	@api isQuickAction = false;
	@track dictValues = [];
	@track isLoading = true;
	@api showContentInSection;
	@api sectionLabel; //'Address';
	@track newLabel = 'New Address:';
	@track isInternalUrl = false;

	@track isNew = true;
	@track viewEditFormVisible = false;
	@track viewCreateFormVisible = false;
	@api createFormVisible = false;
	@api editFormVisible = false;

	@track ClassForm = '';
	@track labelClass = 'slds-form-element__label leftNewFormLabelSpace';
	@track datafieldClass = 'slds-col slds-size_1-of-2 common-component';
	@api currentRecord;
	@track addressObjectName = 'Address__c';
	@track mapMarkersAvailable = false;
	@track mapMarkers = [];
	@track zoomLevel = 5;
	@track mapMessage = 'Street, City and Country datafields should be filled to see the map.';
	@track openSection = true;
	@track hasPermissionsToCreate = false;

	//https://www.excel-exercise.com/excel-address-to-google-maps/
	//https://developer.salesforce.com/docs/component-library/bundle/lightning-map/documentation
	async connectedCallback() {
		this.hasPermissionsToCreate = await checkIfUserCanCreateObject({objectName: this.addressObjectName});

		if (!this.hasPermissionsToCreate) {
			this.newLabel = 'User does not have permission to create address';
		}

		this.allDataContainer = [];
		const inputFields = this.template.querySelectorAll(
			'lightning-input-field'
		);
		if (inputFields) {
			inputFields.forEach(field => {
				field.reset();
			});
		}
		
		// if (this.sectionLabel !== '' && this.sectionLabel !== undefined) {
		// 	this.showContentInSection = true;
		// }
		this.isInternalUrl = await isInternal();
		this.ClassForm = 'slds-grid coloring-form-style';
		if (!this.isInternalUrl) {
			this.ClassForm = 'slds-grid coloring-form-style community-site-form';
		}
		var fields = {};
		if (this.objectType === 'Organisations') {
			fields = await getAddressFromOrganisation({ accountId: this.recordId });
			// console.log('this.currentRecord Organisations:' + JSON.stringify(fields[0]));			
			console.log('this.currentRecord Organisations:' + fields);
		} else {
			this.labelClass = 'slds-form-element__label leftNewFormLabelContainerSpace';
			this.datafieldClass = 'slds-col slds-size_1-of-2 common-container-component';
			if (!this.isAdditional)
				this.isReadonly = true;
			fields = await getAddressFromPUs({ puId: this.recordId, isAdditional: this.isAdditional });

			if (!this.isAdditional && (fields == null || fields.length === 0)) {
				this.newLabel = 'There is no address registered on the Parent MA';
			}
			// console.log('this.currentRecord Not Organisations:' + JSON.stringify(fields[0]));
			console.log('this.currentRecord Not Organisations:' + fields);
		}
		if (fields !== null && fields !== undefined && fields.length > 0) {
			console.log('this.currentRecord:' + fields);
			this.currentRecord = fields[0];
			// this.addressRecordId = currentRecord.Id;
		}
		await this.loadDatafieldValues();
		for (var item = 0; item < this.allDataContainer.length; item++) {
			if (this.allDataContainer[item]['showDateField']) {
				if (fields[this.allDataContainer[item]['dateField']] !== undefined) {
					this.allDataContainer[item]['dateField'] = fields[this.allDataContainer[item]['dateField']]['value'];
				}
			}
		}

		if (fields == null || fields == undefined) {
			this.isLoading = false;
			return;
		}
		this.isLoading = false;
		this.getViewMode();
	}

	async loadDatafieldValues() {
		// var json = '{"datafields": [{"name": "Id", "type": "standard", "colors": ""}, {"name": "Country__c", "type": "standard", "colors": ""},{"name": "District__c", "type": "standard", "colors": ""},{"name": "Street_House_Number__c", "type": "standard", "colors": ""},{"name": "Additional_address__c", "type": "standard", "colors": ""}, {"name": "Name", "type": "standard", "colors": ""},  {"name": "City__c", "type": "standard", "colors": ""},{"name": "Post_Box__c", "type": "standard", "colors": ""},{"name": "Post_Box_City__c", "type": "standard", "colors": ""},{"name": "Post_Box_Country__c", "type": "standard", "colors": ""},{"name": "Post_Box_Postal_Code__c", "type": "standard", "colors": ""},{"name": "Postal_Code__c", "type": "standard", "colors": ""},{"name": "Region__c", "type": "standard", "colors": ""},{"name": "Sponsorship_name__c", "type": "standard", "colors": ""},{"name": "State_Province_District__c", "type": "standard", "colors": ""}]}';
		// var json = '{"datafields": [{"name": "Id", "type": "standard", "colors": ""}, {"name": "Country__c", "type": "standard", "colors": ""},{"name": "District__c", "type": "standard", "colors": ""},{"name": "Street_House_Number__c", "type": "standard", "colors": ""},{"name": "Additional_Address__c", "type": "standard", "colors": ""},{"name": "Phone__c", "type": "standard", "colors": ""}, {"name": "Fax__c", "type": "standard", "colors": ""},  {"name": "City__c", "type": "standard", "colors": ""},{"name": "Post_Box__c", "type": "standard", "colors": ""},{"name": "Post_Box_City__c", "type": "standard", "colors": ""},{"name": "Post_Box_Country__c", "type": "standard", "colors": ""},{"name": "Post_Box_Postal_Code__c", "type": "standard", "colors": ""},{"name": "Postal_Code__c", "type": "standard", "colors": ""},{"name": "Region_Coiuntry__c", "type": "standard", "colors": ""},{"name": "Sponsorship_name_org_legal_entity__c", "type": "standard", "colors": ""}]}';
		var json = '{"datafields": [{"name": "Id", "type": "standard", "colors": ""},{"name": "Additional_Address__c", "type": "standard", "colors": ""},{"name": "District__c", "type": "standard", "colors": ""}, {"name": "Street_House_Number__c", "type": "standard", "colors": ""},{"name": "Phone__c", "type": "standard", "colors": ""},{"name": "Fax__c", "type": "standard", "colors": ""},{"name": "City__c", "type": "standard", "colors": ""},{"name": "Post_Box__c", "type": "standard", "colors": ""},{"name": "Post_Box_City__c", "type": "standard", "colors": ""},{"name": "Post_Box_Country__c", "type": "standard", "colors": ""},{"name": "Post_Box_Postal_Code__c", "type": "standard", "colors": ""},{"name": "Postal_Code__c", "type": "standard", "colors": ""}, {"name": "Region_Coiuntry__c", "type": "standard", "colors": ""},{"name": "Sponsorship_name_org_legal_entity__c", "type": "standard", "colors": ""},{"name": "Country__c", "type": "standard", "colors": ""}]}';
		
		const obj = JSON.parse(json);
		var isFirstOnTheRight = false;

		if (obj !== undefined) {
			var value = obj['datafields'];

			if (this.recordId !== undefined) {
				this.isNew = false;
			}

			this.allDataContainer = [];
			this.mapMarkers = [];

			if (this.currentRecord === undefined) {
				this.isNew = true;
				this.viewCreateFormVisible = true;
			}

			for (var i = 0; i < value.length; i++) {
				// console.log('####value[i][name]:' + value[i]['name']);
				if (this.recordId === undefined && value[i]['name'] === 'RecordTypeId') {
					continue;
				}

				var isColorComponent = value[i]['type'] === 'coloringComponent' ? true : false;
				var isRequired = (value[i]['required'] === undefined || value[i]['required'] === null) ? false : value[i]['required'];
				var isReadonly = (value[i]['readonly'] === undefined || value[i]['readonly'] === null) ? false : value[i]['readonly'];
				var isAvatar = (value[i]['avatar'] === undefined || value[i]['avatar'] === null) ? false : value[i]['avatar'];
				var showDateField = (value[i]['showDate'] === undefined || value[i]['showDate'] === null) ? '' : value[i]['showDate'];

				//TODO: Recheck If this datafield is read-only 
				if (isReadonly == false) {
					var result = await checkIfUserCanEditDatafield({ objectName: this.addressObjectName, datafield: value[i]['name'] });
					isReadonly = !result;
				}

				if (this.isNew == false && this.readonlyFieldsInEdit !== undefined) {
					var readonlyEditFields = (this.readonlyFieldsInEdit + '').split(',');
					readonlyEditFields.forEach(s => {
						if (s.trim() === value[i]['name']) {
							isReadonly = true;
						}
					});
				}

				if (showDateField !== '' && this.recordId !== undefined) {
					var systemInfo = await getSystemInfoFromObject({ objectName: this.addressObjectName, recordId: this.recordId });
					if (systemInfo.length > 0) {
						showDateField = systemInfo[0][showDateField];
					}
				}

				// console.log('####value[i][name]:' + value[i]['name']);
				if (value[i]['name'] === 'Id' && this.currentRecord !== undefined) {
					var params = '';
					var link = '';
					var urlGoogle = 'https://www.google.com/maps/search/?api=1&query=';
					this.countryName = await getCountryNameFromAddress({Id: this.currentRecord['Id']});

					if (this.stringHasValue(this.currentRecord.Street_House_Number__c)) {
						params = this.currentRecord.Street_House_Number__c;
					}
					if (this.stringHasValue(this.currentRecord.District__c)) {
						params = params + ',' + this.currentRecord.District__c;
					}
					if (this.stringHasValue(this.countryName)) {
						params = params + ',' + this.countryName;
					}
					if (params != '') {
						link = urlGoogle + params;
					}

					console.log('###link:' + link);
					var sectionLeft = false;
					var sectionRight = false;

					if (this.isReadonly)
						isReadonly = true;

					var newDataContainer = new DataContainer(i, value[i]['name'], value[i]['type'], value[i]['colors'], isColorComponent, isRequired, isReadonly, isAvatar, showDateField, sectionLeft, sectionRight, link, this.stringHasValue(link), true);

					if (this.stringHasValue(this.currentRecord.Street_House_Number__c) && this.stringHasValue(this.currentRecord.District__c) && this.stringHasValue(this.countryName) && this.showMaps) {
						this.mapMarkersAvailable = true;
						this.mapMarkers = [
							{
								location: {
									Street: this.currentRecord.Street_House_Number__c,
									City: this.currentRecord.District__c,
									Country: this.countryName,
								},
								title: 'Organisation Address',
								description: 'Organisation Address',
								icon: 'standard:account'
							},
						];
					}
					// console.log('####this.mapMarkersAvailable:' + this.mapMarkersAvailable);
					// console.log('####this.mapMarkers:' + JSON.stringify(this.mapMarkers));
					this.allDataContainer.push(newDataContainer);
				}
				else {
					var sectionLeft = this.allDataContainer.length < (this.mapMarkersAvailable && this.showMaps ? 6 : 8);
					var sectionRight = !sectionLeft;
					var extraClass = false;

					if (sectionRight && !isFirstOnTheRight) {
						isFirstOnTheRight = true;
						extraClass = true;
					}

					if (this.isReadonly)
						isReadonly = true;
						
					var newDataContainer = new DataContainer(i, value[i]['name'], value[i]['type'], value[i]['colors'], isColorComponent, isRequired, isReadonly, isAvatar, showDateField, sectionLeft, sectionRight, '', false, false, extraClass);
					this.allDataContainer.push(newDataContainer);
				}
			}
		}
		console.log(JSON.stringify(this.allDataContainer));
		this.getViewMode();
	}

	stringHasValue(value) {
		return (value != null && value != '');
	}

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
		this.getViewMode();
		this.isLoading = false;
	}

	async handleSubmit(event) {
		this.isLoading = true;
		event.preventDefault();       // stop the form from submitting
		var inputFields = event.detail.fields;
		console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
		this.dictValues = inputFields;
		// event.stopPropagation();
		// this.template.querySelector('lightning-record-edit-form').submit(inputFields);		
		
		//ADDED FROM HANDLESUCCESS
		console.log('onsubmit new event recordEditForm', event.detail.id);
		if (this.recordId == undefined && event.detail.id !== undefined) {
			this.recordId = event.detail.id;
		}

		this.errorText = ''; 
		this.errorExist = false;

		if (this.dictValues !== undefined) {
			// var recordInput = { fields: this.getFieldsToUpdate() };
			this.isLoading = true;

			if (this.isNew) {
				this.errorText = await this.processInsert();
			} else {				
				await this.processUpdate(event);
			}
		}

		if (this.isNew) {
			await this.handleSuccess(event);
		}
	}

	async handleSuccess(event) {
		event.preventDefault();
		console.log('onsuccess');
		// event.stopPropagation();

		if (this.dictValues === undefined) {
			this.showToasterNotification('Success', this.objectLabel + ' updated', 'success');
		} else {
			this.isLoading = true;

			if (this.isNew) {
				if (this.errorText === '') {
					this.showToasterNotification('Success', this.objectLabel + ' inserted', 'success');
				} else {
					this.showToasterNotification("Error creating address record or updating organisation", this.errorText, "error");
				}
			} else {				
				if (this.errorText === '') {
					this.showToasterNotification('Success', this.objectLabel + ' updated', 'success'); //'sticky'
				} else {
					this.showToasterNotification('Error updating ' + this.objectLabel + ' record', this.errorText, 'error');
				}
			}

			this.isLoading = false;	
			if (this.errorText !== '') {
				this.errorExist = true;
			} else {
				await this.connectedCallback();
			}

			// var timeToLoad = (success && !this.isNew) ? 5000 : 1000;
			// setTimeout(async() => {
			// }, timeToLoad);
		}

		if (this.isQuickAction) {
			const valueChangeEvent = new CustomEvent("valuechange", {
				detail: { errorExist: this.errorExist, id: (this.currentRecord !== null ? this.currentRecord['Id'] : null)}
			});
			// Fire the custom event
			this.dispatchEvent(valueChangeEvent);
		}
	}
	
	async processInsert() {
		var fieldsToUpdate = this.getFieldsToUpdate();
		for (var item = 0; item < this.allDataContainer.length; item++) {
			var datafieldName = this.allDataContainer[item]['name'];
			var value = this.dictValues[datafieldName];

			if (value !== undefined && value !== '') {
				fieldsToUpdate[datafieldName] = value;
			}
		}
		// var recordInput = { apiName: this.addressObjectName, fields: this.getFieldsToUpdate() };

		var results = await insertAddress({ City: fieldsToUpdate['City__c'], Country: fieldsToUpdate['Country__c'], District: fieldsToUpdate['District__c'], Phone: fieldsToUpdate['Phone__c'], Fax: fieldsToUpdate['Fax__c'], Name: fieldsToUpdate['Name'], Post_Box: fieldsToUpdate['Post_Box__c'], Post_Box_City: fieldsToUpdate['Post_Box_City__c'], Post_Box_Country: fieldsToUpdate['Post_Box_Country__c'], Post_Box_Postal_Code: fieldsToUpdate['Post_Box_Postal_Code__c'], Postal_Code: fieldsToUpdate['Postal_Code__c'], Sponsorship_name: fieldsToUpdate['Sponsorship_name_org_legal_entity__c'], Street_House_Number: fieldsToUpdate['Street_House_Number__c'], additional_address: fieldsToUpdate['additional_address__c'] });

		if (!results.includes(' ')) {
			this.currentRecord = { 'Id': results };
			if (this.objectType === 'Organisations') {
				results = await updateAddressFromOrganisation({ accountId: this.recordId, addressId: this.currentRecord['Id'] });
			} else if (this.objectType === 'PUs' && this.isAdditional) {
				results = await updateAddressFromPUs({ puId: this.recordId, addressId: this.currentRecord['Id'], isAdditional: this.isAdditional });
			}
		}

		if (!results.includes(' ')) {
			this.getViewMode();
		} else {
			return JSON.stringify(results);
		}
		return '';
	}

	async processUpdate(event) {
		var fieldsToUpdate = this.dictValues;

		if (this.currentRecord !== undefined && this.currentRecord !== null) {
			fieldsToUpdate['Id'] = this.currentRecord.Id;
		}

		console.log('####recordInput Update:' + JSON.stringify(fieldsToUpdate));
		// var results = await updateAddress({ Id: this.currentRecord['Id'], City: fieldsToUpdate['City__c'], Country: fieldsToUpdate['Country__c'], District: fieldsToUpdate['District__c'], Phone: fieldsToUpdate['Phone__c'], Fax: fieldsToUpdate['Fax__c'], Name: fieldsToUpdate['Name'], Post_Box: fieldsToUpdate['Post_Box__c'], Post_Box_City: fieldsToUpdate['Post_Box_City__c'], Post_Box_Country: fieldsToUpdate['Post_Box_Country__c'], Post_Box_Postal_Code: fieldsToUpdate['Post_Box_Postal_Code__c'], Postal_Code: fieldsToUpdate['Postal_Code__c'], Region: fieldsToUpdate['Region__c'], Sponsorship_name: fieldsToUpdate['Sponsorship_name__c'], Street_House_Number: fieldsToUpdate['Street_House_Number__c'] });
		var recordInput = { fields: fieldsToUpdate };


		updateRecord(recordInput).then(async() => {
			this.errorText = '';
			await this.handleSuccess(event);
		}).catch(error => {
			this.errorText = this.reduceErrors(error);					
			this.handleSuccess(event);
		});
	}

	getFieldsToUpdate() {
		var fieldsToUpdate = {};
		if (this.currentRecord !== undefined) {
			fieldsToUpdate['Id'] = this.currentRecord.Id;
		}

		for (var i = 0; i < this.dictValues.length; i++) {
			var json = JSON.parse(this.dictValues[i]);
			if (json['value'] === undefined)
				continue;

			fieldsToUpdate[json['datafield']] = json['value'];
		}
		return fieldsToUpdate;
	}

	handleError(event) {
		console.log('onerror event recordEditForm', event);
		console.log('onerror event recordEditForm JSON', JSON.stringify(event));
		this.isLoading = false;
	}

	showToasterNotification(title, message, variant, mode = 'pester'){
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: JSON.stringify(message),
				variant: variant,
				mode: mode
			})
		);
	}
	// getEditForm() {
	// 	this.editFormVisible = (!this.isNew && this.viewEditFormVisible);
	// 	this.createFormVisible = (this.isNew && this.createFormVisible);
	// }

	getViewMode() {
		this.editFormVisible = false;
		this.createFormVisible = false;
		this.viewEditFormVisible = !this.isNew;
		this.viewCreateFormVisible = this.isNew;
	}

	showEditForm() {
		if (this.isNew) {
			this.editFormVisible = false;
			this.createFormVisible = true;
			this.viewEditFormVisible = false;
			this.viewCreateFormVisible = false;
		} else {
			this.editFormVisible = true;
			this.createFormVisible = false;
			this.viewEditFormVisible = false;
			this.viewCreateFormVisible = false;
		}
		// this.getEditForm();
	}

	phoneFormatChanged(event) {
		console.log('####phoneFormatChanged:');
	}

	//validate Phone format: https://jsfiddle.net/rafj3md0/
	isNumericInput(event) {
		const key = event.keyCode;
		return ((key >= 48 && key <= 57) || // Allow number line
			(key >= 96 && key <= 105) // Allow number pad
		);
	}

	isModifierKey(event) {
		const key = event.keyCode;
		console.log(key);
		return (event.shiftKey === true || key === 35 || key === 36) || // Allow Shift, Home, End
			(key === 8 || key === 9 || key === 13 || key === 46 || key === 32 || key === 187 || key === 189) || // Allow Backspace, Tab, Enter, Delete, Space, Add, Substract
			(key > 36 && key < 41) || // Allow left, up, right, down
			(
				// Allow Ctrl/Command + A,C,V,X,Z
				(event.ctrlKey === true || event.metaKey === true) &&
				(key === 65 || key === 67 || key === 86 || key === 88 || key === 90)
			)
	}

	enforceFormat(event) {
		// Input must be of a valid number format or a modifier key, and not longer than ten digits
		if (!this.isNumericInput(event) && !this.isModifierKey(event)) {
			event.preventDefault();
		}
	};

	formatToPhone(event) {
		return;
		if (this.isModifierKey(event)) { return; }

		// I am lazy and don't like to type things more than once
		const target = event.target;

		if (event.target.value === undefined || event.target.value === null) {
			return;
		}
		const maxnumber = 12;
		const input = event.target.value.replace(/\D/g, '').substring(0, maxnumber); // First ten digits of input only
		const zip = input.substring(0, 2);
		const middle = input.substring(2, 3);
		const last = input.substring(3, maxnumber);

		// if(input.length > 6){target.value = `(${zip}) ${middle} - ${last}`;}
		// else if(input.length > 3){target.value = `(${zip}) ${middle}`;}
		// else if(input.length > 0){target.value = `(${zip}`;}

		if (input.length > 3) { target.value = `+${zip} ${middle} ${last}`; }
		else if (input.length > 2) { target.value = `+${zip} ${middle}`; }
		else if (input.length > 0) { target.value = `+${zip}`; }
	}

	handleSectionClick() {
		this.openSection = !this.openSection;
	}

	reduceErrors(errors) {
		console.log('####Array.isArray(errors):' + Array.isArray(errors));
		if (!Array.isArray(errors)) {
			errors = [errors];
		}

		return (
			errors
				// Remove null/undefined items
				.filter((error) => !!error)
				// Extract an error message
				.map((error) => {
					// UI API read errors
					// console.log('####error.body.fieldErrors:' + error.body.fieldErrors);
					// console.log('####Array.isArray(error.body.fieldErrors):' + Array.isArray(error.body.fieldErrors));

					if (error.body.duplicateResults && error.body.duplicateResults.length > 0) {
						console.log('1');
						return error.body.duplicateResults.map((e) => e.message);
					}
					else if (error.body.fieldErrors) {
						console.log('2');
						if (error.body.fieldErrors.length > 0 && Array.isArray(error.body.fieldErrors)) {
							return error.body.fieldErrors.map((e) => e.message);
						} else {
							var errorText = '';
							for (const item in error.body.fieldErrors) {
								if (Array.isArray(error.body.fieldErrors[item])) {
									var subitems = error.body.fieldErrors[item];
									for (var i = 0; i < subitems.length; i++) {
										errorText += subitems[i].statusCode + ': ' + subitems[i].message;
									}
								}
							}
							return errorText;
						}
					}
					else if (error.body.pageErrors && error.body.pageErrors.length > 0 && Array.isArray(error.body.pageErrors)) {
						console.log('3');
						return error.body.pageErrors.map((e) => e.message);
					}
					else if (Array.isArray(error.body)) {
						console.log('4');
						return error.body.map((e) => e.message);
					}
					// UI API DML, Apex and network errors
					else if (error.body && typeof error.body.message === 'string') {
						console.log('5');
						return error.body.message;
					}
					// JS errors
					else if (typeof error.message === 'string') {
						console.log('6');
						return error.message;
					}
					// Unknown error shape so try HTTP status text
					console.log('7');
					return error.statusText;
				})
				// Flatten
				.reduce((prev, curr) => prev.concat(curr), [])
				// Remove empty strings
				.filter((message) => !!message)
		);
	}
}

class DataContainer {
	constructor(index, name, type, colors, isColorComponent, required, readonly, avatar, dateField, sectionLeft, sectionRight, link = '', hasLink = false, isMapped = false, isFirstOnTheRight = false) {
		this.formIndex = 'Form' + index;
		this.index = index;
		this.name = name;
		this.type = type;
		this.colors = colors;
		this.isColorComponent = isColorComponent;
		this.required = required;
		this.readonly = readonly;
		this.avatar = avatar;
		this.dateField = dateField;
		this.link = link;
		this.hasLink = hasLink;
		this.isMapped = isMapped;
		this.showDateField = (dateField !== undefined && dateField !== '');
		this.className = 'textFancy slds-size_1-of-2';
		this.sectionLeft = sectionLeft;
		this.sectionRight = sectionRight;
		this.isId = (this.name == 'Id');
		this.isPhone = (this.name.toLowerCase().includes('phone') || this.name.toLowerCase().includes('fax'));
		if (this.sectionRight) {
			this.extraClass = !isFirstOnTheRight ? 'textFancy' : 'extraHeightTextFancy';
		} else {
			this.extraClass = this.name.toLowerCase().includes('fax') ? 'leftSize extraHeight' : 'leftSize';
		}

	}
}