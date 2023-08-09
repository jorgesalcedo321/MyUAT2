import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from "lightning/platformResourceLoader";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import LBL_RISK_NAME from '@salesforce/label/c.LBL_RISK_NAME';
import LBL_DESCRIPTION from '@salesforce/label/c.LBL_DESCRIPTION';
import LBL_CATEGORY from '@salesforce/label/c.LBL_CATEGORY';
import LBL_RISK_VALUE from '@salesforce/label/c.LBL_RISK_VALUE';
import LBL_RISK_IMPACT from '@salesforce/label/c.LBL_RISK_IMPACT';
import LBL_RISK_PROBABILITY from '@salesforce/label/c.LBL_RISK_PROBABILITY';
import LBL_SAFETY_SECURITY_RISK from '@salesforce/label/c.LBL_SAFETY_SECURITY_RISK';
import LBL_EDIT from '@salesforce/label/c.LBL_EDIT';
import LBL_DELETE from '@salesforce/label/c.LBL_DELETE';
import LBL_NEW from '@salesforce/label/c.LBL_NEW';
import LBL_RISKS from '@salesforce/label/c.LBL_RISKS';

import WrappedHeaderTable from "@salesforce/resourceUrl/WrappedHeaderTable";

import isInternal from '@salesforce/apex/customRelatedLists.isInternal';
import getProjectGeographicAreaByProjectId from '@salesforce/apex/customRelatedLists.getProjectGeographicAreaByProjectId';
import getGeographicAreaByAccountId from '@salesforce/apex/customRelatedLists.getGeographicAreaByAccountId';
import getProjectsByOrganisationId  from '@salesforce/apex/customRelatedLists.getProjectsByOrganisationId';
import getRisksByProgrammeId from '@salesforce/apex/customRelatedLists.getRisksByProgrammeId';
import getRisksByRiskRegisterId from '@salesforce/apex/customRelatedLists.getRisksByRiskRegisterId';
import getNumberRisksByProgrammeId from '@salesforce/apex/customRelatedLists.getNumberRisksByProgrammeId';
import getNumberOfRiskRegisterByProgrammeId from '@salesforce/apex/customRelatedLists.getNumberOfRiskRegisterByProgrammeId';
import getNumberOfRiskAssessmentByMAId from '@salesforce/apex/customRelatedLists.getNumberOfRiskAssessmentByMAId';
import getNumberOfRisksByRiskRegisterId from '@salesforce/apex/customRelatedLists.getNumberOfRisksByRiskRegisterId';
import getOrganisationIdByProgrammeId from '@salesforce/apex/customRelatedLists.getOrganisationIdByProgrammeId';

import getMAName from '@salesforce/apex/customRelatedLists.getMAName';
import getRecordTypeIdByName from '@salesforce/apex/customRelatedLists.getRecordTypeIdByName';
import getDescriptionRiskDatafieldName from '@salesforce/apex/customRelatedLists.getDescriptionRiskDatafieldName';
import getRiskApproverAndReviewerByOrganisationId from '@salesforce/apex/customRelatedLists.getRiskApproverAndReviewerByOrganisationId';
import getRiskRegisterByProgrammeId from '@salesforce/apex/customRelatedLists.getRiskRegisterByProgrammeId';
import getRiskAssessmentByMAId from '@salesforce/apex/customRelatedLists.getRiskAssessmentByMAId';
import checkIfUserCanEditObject from '@salesforce/apex/RiskController.checkIfUserCanEditObject';
import checkIfUserCanCreateObject from '@salesforce/apex/RiskController.checkIfUserCanCreateObject';
import checkIfUserCanAccessObject from '@salesforce/apex/RiskController.checkIfUserCanAccessObject';
import checkIfUserCanDeleteObject from '@salesforce/apex/RiskController.checkIfUserCanDeleteObject';

//import RISK_OBJECT from '@salesforce/schema/ampi__Risk__c';
//import { getObjectInfo } from 'lightning/uiObjectInfoApi';

//only for standar objects
//https://www.infallibletechie.com/2020/04/reusable-related-list-using-lwc-in.html 
//datatable
//https://developer.salesforce.com/docs/component-library/bundle/lightning-datatable/example
//TODO: USE CUSTOM LABELS FOR TRANSLATE LABELS IN LWC AS COLUMNS
//https://developer.salesforce.com/docs/component-library/documentation/en/lwc/create_labels
//TODO: separate javascript functionallity
		//https://salesforce.stackexchange.com/questions/252826/feasibility-to-import-entire-lwc-classes-to-access-api-methods
		//TODO: dynamic template columns for coloring 
		//https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.data_table_custom_types
		//https://developer.salesforce.com/docs/component-library/bundle/lightning-datatable/documentation
		//TODO: PAGINATION ON DATATABLE https://inevitableyogendra.blogspot.com/2021/05/infinite-loading-in-lightning-datatable.html
		
export default class CustomRelatedLists extends NavigationMixin(LightningElement) {
  @api recordId;
  @api filter;
  @api title;
  @api customObjectNamePic;
  @api showNumberOfRecords;
  @api showRowNumber;
  @api showParentPath;
  @api showNewRowAction;
  @api showLinks;
  @api recordTypeNameByDefault;
  @api editButtonEnabled = false;
  @api deleteButtonEnabled = false;
  @track showDatatable = false;
  @track customHeightClass = 'customHeight border-gray';
  @track url = '';
  @track titleToShow = '';
  @track error;
  @track data = [];
  @track columns = [];
  @track parentMAName = '';
  @track parentMAUrl = '';
  @track CustomObjectUrlLink = '';
  @track customObjectName = '';
  @track countRecords = -1;  
  @track icon = 'custom:custom61';
  @track iconBackground = '';
  @track isInternalUrl = false;
  @track textCountRecords;
  @track textDisplayedRecords;
  @track sortBy;
  @track sortDirection;
  @track showNewRowActionAfterEvaluation = false;
  @api actions = [];

  linkTypeAttrFieldsInput = [];
  offSetCount = 0;
  maxRecords = 20;
  loadMoreStatus;
  targetDatatable;

  label = {
	LBL_RISK_NAME,
	LBL_DESCRIPTION, 
	LBL_CATEGORY, 
	LBL_RISK_VALUE, 
	LBL_SAFETY_SECURITY_RISK, 
	LBL_NEW, 
	LBL_RISKS, 
	LBL_RISK_PROBABILITY,
	LBL_RISK_IMPACT
  }
  
  
   doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
   }

   sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
		
		if (fieldname == 'NameUrl') {
			if (this.linkTypeAttrFieldsInput.length > 0) {
				fieldname = this.linkTypeAttrFieldsInput[0];
			}
			else {
				fieldname = 'Name';
			}
		}
		//console.log('#fieldname:' + fieldname);
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
  }   

  getParentData() {
	getMAName({accountId : this.recordId}).then(result => { 
			this.parentMAName = result;
			this.parentMAUrl = '/s/account/' + this.recordId + '/' + this.parentMAName;
			this.CustomObjectUrlLink = 's/account/Account/Default';

			if (this.customObjectNamePic == 'ampi__Geographical_Area__c') {
				this.customObjectName = 'Organisations';
			}
	})
	.catch(error => {
			console.log('ERROR:' + error);
			this.error = error;
			this.data = undefined;

	});
  }

  // Event to handle onloadmore on lightning datatable markup
  async handleLoadMore(event) {
        event.preventDefault();
        this.offSetCount = this.offSetCount + 20;
        event.target.isLoading = true;
        this.targetDatatable = event.target;
        this.loadMoreStatus = 'Loading';
        await this.loadData();
  }

  async getColumnsDynamically(objectName) {
		var columns = new Array();
		var labelsInput = new Array('Short Name', 'Long Name', 'Type', 'Pillar');
		var fieldsInput = new Array('Name', 'LongName', 'Type', 'Pillar');
		var linkLabelsInput = new Array('Name');
		var linkFieldsInput = new Array();
		this.linkTypeAttrFieldsInput = new Array();
		var actionInput = true;
		var textSize = 100;
		var linkSize = 200;
		var colorSize = 30;
		var wrappingAllCells = false;
		if (objectName == 'ampi__Geographical_Area__c') 	//getColumnsForGA
		{
			//TODO: ICONS https://www.lightningdesignsystem.com/icons/#standard
			this.icon = 'custom:custom61';
			labelsInput = new Array('Record Type');
			fieldsInput = new Array('Type');
			linkLabelsInput = new Array('Name','Parent Geographic Area');
			linkFieldsInput = new Array('NameUrl','ParentNameUrl');
			this.linkTypeAttrFieldsInput = new Array('Name','ParentName');
		}
		else if (this.customObjectNamePic == 'ampi__Risk_Register__c') {
			this.icon = 'custom:custom55';
			this.iconBackground = 'icon-risk-register'
			labelsInput = new Array('Status');
			fieldsInput = new Array('Status__c');
			linkLabelsInput = new Array('Security Assessment Name');
			linkFieldsInput = new Array('NameUrl');
			this.linkTypeAttrFieldsInput = new Array('Name');
			wrappingAllCells = true;
		}
		else if (this.customObjectNamePic == 'ampi__Risk_Assessment__c') {
			this.icon = 'custom:custom78';
			this.iconBackground = 'icon-risk-assessment'
			labelsInput = new Array('Status');
			fieldsInput = new Array('Status__c');
			linkLabelsInput = new Array('National Security Context');
			linkFieldsInput = new Array('NameUrl');
			this.linkTypeAttrFieldsInput = new Array('Name');
			wrappingAllCells = true;
		}
		else if (this.customObjectNamePic == 'ampi__Project__c') //getColumnsForProject
		{	
			this.icon = 'custom:custom74';
			labelsInput = new Array('Project Description','Project Start Date');
			fieldsInput = new Array('Description','ProjectStartDate');
			linkLabelsInput = new Array('Name');
			linkFieldsInput = new Array('NameUrl');
			this.linkTypeAttrFieldsInput = new Array('Name');
		}
		else if (this.customObjectNamePic == 'ampi__Risk__c') //getColumnsForProject
		{	
			this.icon = 'custom:custom60';
			var description = await getDescriptionRiskDatafieldName();
			//console.log('description:' + description);
			if (this.loadFilterByName('onRiskRegister') == false) {
				labelsInput = new Array(this.label.LBL_DESCRIPTION, this.label.LBL_CATEGORY, this.label.LBL_RISK_VALUE);
				fieldsInput = new Array(description, 'ampi__Category__c', 'Risk_Value__c');
			} else {
				//if (this.loadFilterByName('addColoringTest')) {
						// labelsInput = new Array(this.label.LBL_DESCRIPTION, 'Value_Color', this.label.LBL_RISK_VALUE, 'Probability_Color', this.label.LBL_RISK_PROBABILITY, 'Impact_Color', this.label.LBL_RISK_IMPACT);
						// fieldsInput = new Array(description, 'Value_Color', 'Risk_Value__c','Probability_Color', 'Probability_Value__c', 'Impact_Color', 'Impact_Value__c');
						labelsInput = new Array(this.label.LBL_DESCRIPTION, 'Probability_Color', this.label.LBL_RISK_PROBABILITY, 'Impact_Color', this.label.LBL_RISK_IMPACT, 'Value_Color', this.label.LBL_RISK_VALUE);
						fieldsInput = new Array(description,'Probability_Color', 'Probability_Value__c', 'Impact_Color', 'Impact_Value__c', 'Value_Color', 'Risk_Value__c');
						
				//} else {
				//		labelsInput = new Array(this.label.LBL_DESCRIPTION, this.label.LBL_RISK_VALUE, this.label.LBL_RISK_PROBABILITY, this.label.LBL_RISK_IMPACT);
				//		fieldsInput = new Array(description, 'Risk_Value__c', 'Probability_Value__c', 'Impact_Value__c');
				//}
			}
			linkLabelsInput = new Array(this.label.LBL_RISK_NAME);
			linkFieldsInput = new Array('NameUrl');
			this.linkTypeAttrFieldsInput = new Array('Risk_Name_Translated__c');
		}
			
		for (var i=0; i<linkLabelsInput.length;i++) {
			if (wrappingAllCells == true) {
				columns.push({
						label: linkLabelsInput[i],
						fieldName: linkFieldsInput[i],
						type: 'url',		
						wrapText: true,
						sortable: true,
						typeAttributes: {label: { fieldName: this.linkTypeAttrFieldsInput[i] }, 
						target: '_self'}
				});
			} else {
				columns.push({
						label: linkLabelsInput[i],
						fieldName: linkFieldsInput[i],
						type: 'url',					
						fixedWidth: linkSize,	
						sortable: true,
						typeAttributes: {label: { fieldName: this.linkTypeAttrFieldsInput[i] }, 
						target: '_self'}
				});		
			} 
		}

		for (var i=0; i<labelsInput.length;i++) {
			if (labelsInput[i].endsWith('_Color')) { //this.label.LBL_RISK_VALUE
				columns.push({ 
					label: labelsInput[i], 
					fieldName: labelsInput[i], 
					type: 'text',
					cellAttributes: {
							class: {fieldName: labelsInput[i]},
					},
					hideLabel: true,
					fixedWidth: colorSize,		
					sortable: true	
				});		
			} else if (labelsInput[i] == this.label.LBL_DESCRIPTION){
				columns.push({ 
					label: labelsInput[i], 
					fieldName: fieldsInput[i], 
					type: 'text',
					wrapText: true,
					sortable: true,
				});
			} else {
				var className = '';
				if (fieldsInput[i] === 'Risk_Value__c' ||
					fieldsInput[i] === 'Probability_Value__c' ||
					fieldsInput[i] === 'Impact_Value__c') {
						className = 'verticalTopAlign';
				}

				if (wrappingAllCells == true) {
					columns.push({ 
						label: labelsInput[i], 
						fieldName: fieldsInput[i], 
						type: 'text',
						sortable: true,
						wrapText: true,
						cellAttributes: {
								class: className,
						},		
					});	
				} else {
					columns.push({ 
						label: labelsInput[i], 
						fieldName: fieldsInput[i], 
						fixedWidth: textSize,	 
						type: 'text',
						sortable: true,
						cellAttributes: {
								class: className,
						},		
					});	
				}	
			}
		}

		//TODO: CHANGING DYNAMICALLY
		this.editButtonEnabled = true;
		var canCreate = await checkIfUserCanCreateObject({objectName : this.customObjectNamePic}); 
		var canEdit = await checkIfUserCanEditObject({objectName : this.customObjectNamePic}); 
		var canAccess = await checkIfUserCanAccessObject({objectName : this.customObjectNamePic}); 
		var canDelete = await checkIfUserCanDeleteObject({objectName : this.customObjectNamePic}); 

		if (canEdit && this.editButtonEnabled){
			this.actions.push({ label: LBL_EDIT, name: 'edit' });
		}
		if (canDelete && this.deleteButtonEnabled){
			this.actions.push({ label: LBL_DELETE, name: 'delete' });
		}
		if (actionInput == true && this.actions.length > 0) {
			columns.push({
					type: 'action',
					typeAttributes: { rowActions: this.actions }
			});
		}
		this.showNewRowActionAfterEvaluation = this.showNewRowAction && canCreate;

		return columns;
  }

  updateSettingsDatatable(defaultTitle, url) {
		this.url = url;		
		if (this.title == undefined || this.title == '') {
			this.title = defaultTitle;
		}
		this.titleToShow = this.title;
		
		var totalNumber = this.data.length;
		if (this.countRecords != -1) {
			totalNumber = this.countRecords;
		}
		if (this.showNumberOfRecords) {
			this.titleToShow = this.title + ' (' + totalNumber + ')';
		}

		this.showDatatable = this.data != undefined && totalNumber > 0;
		if (this.showDatatable) {
			this.customHeightClass = 'autoHeight border-gray';
		}
  }

  async connectedCallback() {
	await this.initializeDatatable();
	await this.loadData();
  } 

  async initializeDatatable() {
	if (!this.stylesLoaded) {
		Promise.all([loadStyle(this, WrappedHeaderTable)])
			.then(() => {
				this.stylesLoaded = true;
			})
			.catch((error) => {
				console.error("Error loading custom styles");
			});
	}
	
	if (this.showParentPath) {
		this.getParentData();
	}

	this.isInternalUrl = await isInternal();
	this.columns = await this.getColumnsDynamically(this.customObjectNamePic);
  }

  loadFilterByName(jsonAttributeName) { //, isBoolean
	const obj = JSON.parse(this.filter);
	var value = false;
	if (obj != undefined) {
		var value = obj[jsonAttributeName];
		if (value == undefined) {
			//if(isBoolean==true) {
			value = false;
			//}else {
			//	value = '';
			//}
		}
	 }
	 return value;
  }
		
	getValueFromFilterByName(jsonAttributeName) { //, isBoolean
			const obj = JSON.parse(this.filter);
			var value = '';
			if (obj != undefined) {
				var value = obj[jsonAttributeName];
				if (value == undefined) {
					//if(isBoolean==true) {
					value = '';
					//}else {
					//	value = '';
					//}
				}
			 }
			 return value;
	}

	checkRiskApproverAndReviewerByOrganisationId(organisationId) {
		getRiskApproverAndReviewerByOrganisationId({organisationId: organisationId, includeProfile: true}).then(riskApproverReviewer => {
					//riskApproverReviewer.includes('Approver') || 
					if (riskApproverReviewer.includes('Reviewer') || riskApproverReviewer.includes('System Administrator')) {
						this.showNewRowActionAfterEvaluation = true;
					} else {
						this.url = '#';
						this.showLinks = false;
					}
					console.log('riskApproverReviewer:' + riskApproverReviewer);
					console.log('this.showNewRowActionAfterEvaluation:' + this.showNewRowActionAfterEvaluation);
		});
	}

	async loadData() {
		if (this.customObjectNamePic == 'ampi__Project_Geographic_Area__c') {
			getProjectGeographicAreaByProjectId({projectId : this.recordId, maxRecords: this.maxRecords, offSetCount: this.offSetCount}).then(result => { 
				var url = '/s/project/' + this.recordId + '/related/ampi__Project_Geographic_Areas__r';
				
				if (this.isInternalUrl) {
					url = '/lightning/r/' + this.recordId + '/related/ampi__Project_Geographic_Areas__r/view';
				}
				this.setResults(result, undefined, url, this.title);
			})
			.catch(error => {
				this.setResults(undefined, error, '', this.title);
			});
			
		} else if (this.customObjectNamePic == 'ampi__Risk_Register__c') {
			this.countRecords = await getNumberOfRiskRegisterByProgrammeId({programmeId : this.recordId}); 
			var organisationId = await getOrganisationIdByProgrammeId({programmeId : this.recordId});
			getRiskRegisterByProgrammeId({programmeId : this.recordId, maxRecords: this.maxRecords, offSetCount: this.offSetCount}).then(result => { 
				var url = '/s/geographical-area/related/' + this.recordId + '/Risk_Registers__r';
				
				if (this.isInternalUrl) {
					url = '/lightning/r/' + this.recordId + '/related/Risk_Registers__r/view';
				}
				this.setResults(result, undefined, url, this.title);
				this.checkRiskApproverAndReviewerByOrganisationId(organisationId);
			})
			.catch(error => {
				this.setResults(undefined, error, '', this.title);
			});
		} else if (this.customObjectNamePic == 'ampi__Risk_Assessment__c') {
			this.countRecords = await getNumberOfRiskAssessmentByMAId({maId : this.recordId}); 
				
			getRiskAssessmentByMAId({maId : this.recordId, maxRecords: this.maxRecords, offSetCount: this.offSetCount}).then(result => { 
				var url = '/s/account/related/' + this.recordId + '/Risk_Reviews_National_Association__r';

				if (this.isInternalUrl) {
					url = '/lightning/r/' + this.recordId + '/related/Risk_Reviews_National_Association__r/view';
				}
				var organisationId = this.recordId;
				this.checkRiskApproverAndReviewerByOrganisationId(organisationId);
				this.setResults(result, undefined, url, this.title);
			})
			.catch(error => {
				this.setResults(undefined, error, '', this.title);
			});
		} else if (this.customObjectNamePic == 'ampi__Geographical_Area__c') {
			getGeographicAreaByAccountId({accountId : this.recordId, programmesVisible: this.loadFilterByName('showProgrammes'), programmeUnitsVisible: this.loadFilterByName('showProgrammeUnits'), nationalManagementUnitsVisible: this.loadFilterByName('showNationalManagementUnits'), maxRecords: this.maxRecords, offSetCount: this.offSetCount}).then(result => { 
				var url = '/s/account/related/' + this.recordId + '/Programmes__r';

				if(this.isInternalUrl){
					url = '/lightning/r/' + this.recordId + '/Programmes__r/view';
				}
				this.setResults(result, undefined, url, this.title);
			})
			.catch(error => {
				this.setResults(undefined, error, '', this.title);
			});
		/*} else if (this.customObjectNamePic == 'ampi__Risk_Register__c') {
			getProjectsByOrganisationId({organisationId : this.recordId, maxRecords: this.maxRecords, offSetCount: this.offSetCount}).then(result => { 
				var url = '/s/project/related/' + this.recordId + '/Projects4__r';
				this.setResults(result, undefined, url, this.title);
			})
			.catch(error => { 
				this.setResults(undefined, error, '', this.title);
			});*/
		} else if (this.customObjectNamePic == 'ampi__Project__c') {
			getProjectsByOrganisationId({organisationId : this.recordId, maxRecords: this.maxRecords, offSetCount: this.offSetCount}).then(result => { 
				var url = '/s/project/related/' + this.recordId + '/Projects4__r';
				if(this.isInternalUrl){
					url = '/lightning/r/' + this.recordId + '/Projects4__r/view';
				}

				this.setResults(result, undefined, url, this.title);
			})
			.catch(error => { 
				this.setResults(undefined, error, '', this.title);
			});
		} else if (this.customObjectNamePic == 'ampi__Risk__c') {
			var category = this.getValueFromFilterByName('category');
			this.title = this.loadFilterByName('includeCatalogueRiskIn') ? this.label.LBL_SAFETY_SECURITY_RISK : (category == '' ? this.label.LBL_RISKS : category);
			//console.log('category:' + category);
			//console.log('this.title:' + this.title);
			if (this.loadFilterByName('onRiskRegister') == false) {
				this.countRecords = await getNumberRisksByProgrammeId({programmeId : this.recordId, category : category, includeCatalogueRisk: this.loadFilterByName('includeCatalogueRiskIn')}); 
				getRisksByProgrammeId({programmeId : this.recordId, category : category, includeCatalogueRisk: this.loadFilterByName('includeCatalogueRiskIn'), maxRecords: this.maxRecords, offSetCount: this.offSetCount}).then(result => { 
					var url = '/s/geographical-area/related/' + this.recordId + '/Risks__r';
					if(this.isInternalUrl){
						url = '/lightning/r/' + this.recordId + '/related/Risks__r/view';
					}
					this.setResults(result, undefined, url, this.title);
				})
				.catch(error => { 
					this.setResults(undefined, error, '', this.title);
				});
			} else {
				this.countRecords = await getNumberOfRisksByRiskRegisterId({riskRegisterId : this.recordId, category : category}); 
				//alert(this.countRecords); 
				getRisksByRiskRegisterId({riskRegisterId: this.recordId, category : category, maxRecords: this.maxRecords, offSetCount: this.offSetCount}).then(result => { 
					var url = '/s/risk-register/related/' + this.recordId + '/ampi__Risks__r';
					if(this.isInternalUrl){
						url = '/lightning/r/' + this.recordId + '/related/ampi__Risks__r/view';
					}
					this.setResults(result, undefined, url, this.title);
				})
				.catch(error => { 
					this.setResults(undefined, error, '', this.title);
				});
			}
		} 
	}

  	setResults(result, error, url, title) {
		if (result != undefined) {
			var newData = result;
			//this.data = result;
			if (this.customObjectNamePic == 'ampi__Risk__c') {
				newData = result.map((record) => {

				  let Value_Color = (record.Risk_Value__c == 0 ? 'color_image_test_none': 
										(record.Risk_Value__c <= 5 ? 'color_image_test_1': 
											(record.Risk_Value__c <= 10 ? 'color_image_test_2' : 
												(record.Risk_Value__c <= 15 ? 'color_image_test_3' : 
													(record.Risk_Value__c <= 20 ? 'color_image_test_4' : 
														(record.Risk_Value__c <= 25 ? 'color_image_test_5' : 'color_image_test_none'))))));
					// let Value_Color = (record.Risk_Value__c == 0 ? 'color_image_test_none': 
					// 					(record.Risk_Value__c == 1 ? 'color_image_test_1': 
					// 						(record.Risk_Value__c <= 2? 'color_image_test_2' : 
					// 							(record.Risk_Value__c <= 3 ? 'color_image_test_3' : 
					// 								(record.Risk_Value__c <= 4 ? 'color_image_test_4' : 
					// 									(record.Risk_Value__c <= 5 ? 'color_image_test_5' : 'color_image_test_none'))))));

					let Probability_Color = (record.Probability_Value__c == 0 ? 'color_image_test_none':  
												(record.Probability_Value__c == 1 ? 'color_image_test_1': 
													(record.Probability_Value__c <= 2 ? 'color_image_test_2' : 
														(record.Probability_Value__c <= 3 ? 'color_image_test_3' : 
															(record.Probability_Value__c <= 4 ? 'color_image_test_4' : 
																(record.Probability_Value__c <= 5 ? 'color_image_test_5' : 'color_image_test_none'))))));


					let Impact_Color = (record.Impact_Value__c == 0 ? 'color_image_test_none': 
											(record.Impact_Value__c == 1 ? 'color_image_test_1': 
												(record.Impact_Value__c <= 2 ? 'color_image_test_2' : 
													(record.Impact_Value__c <= 3 ? 'color_image_test_3' : 
														(record.Impact_Value__c <= 4 ? 'color_image_test_4' : 
															(record.Impact_Value__c <= 5 ? 'color_image_test_5' : 'color_image_test_none'))))));	
				
				  let Name_Url = '/risk/' + record.Id;
					if (this.isInternalUrl == true) {
							
						 Name_Url = '/lightning/r/ampi__Risk__c/' + record.Id + '/view/';
						 
					}

					//let status = record.NumberOfEmployees > 10000 ? 'utility:ribbon' : '';
					return {...record, 
						'Value_Color': Value_Color,
						'Probability_Color': Probability_Color,
				 		'Impact_Color': Impact_Color,
				 		'NameUrl': Name_Url
						//'status': status
					}
				});
			} else if (this.customObjectNamePic == 'ampi__Risk_Register__c') {
				newData = result.map((record) => {

				  let Name_Url = '/risk-register/' + record.Id;
					if (this.isInternalUrl == true) {
							
						 Name_Url = '/lightning/r/ampi__Risk_Register__c/' + record.Id + '/view/';
					}

					return {...record, 
				 		'NameUrl': Name_Url
					}
				});
			} else if (this.customObjectNamePic == 'ampi__Risk_Assessment__c') {
				newData = result.map((record) => {

				  let Name_Url = '/risk-assessment/' + record.Id;
					if (this.isInternalUrl == true) {
							
						 Name_Url = '/lightning/r/ampi__Risk_Assessment__c/' + record.Id + '/view/';
					}

					return {...record, 
				 		'NameUrl': Name_Url
					}
				});
			}

			this.data = [...this.data, ...newData];
            this.loadMoreStatus = '';
            if (this.targetDatatable && this.data.length >= this.countRecords) {
                //stop Infinite Loading when threshold is reached
                this.targetDatatable.enableInfiniteLoading = false;
                //Display "No more data to load" when threshold is reached
                this.loadMoreStatus = 'No more data to load';
            }
            //Disable a spinner to signal that data has been loaded
			if (this.targetDatatable) this.targetDatatable.isLoading = false;
			this.textCountRecords = 'Total Records: ' + (this.countRecords == -1 ? this.data.length : this.countRecords);
			this.textDisplayedRecords = 'Displayed Records: ' + this.data.length;

		}
		this.error = error;

		if (error == undefined) {
			this.updateSettingsDatatable(title, url);
		}
  }
  
  changeHandler(event) {
    this.greeting = event.target.value;
  }

   handleRowAction(event) {
    	const actionName = event.detail.action.name;
    	const row = event.detail.row;
	    switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'edit':
                this.editRow(row);
                break;
            default:
        }
    }

	newRow() {
		if (this.recordTypeNameByDefault != undefined && this.recordTypeNameByDefault != '') {
			getRecordTypeIdByName({name : this.recordTypeNameByDefault}).then(recordTypeID => { 
				var defaultValues = defaultValues = encodeDefaultFieldValues({
						RecordTypeId: recordTypeID
					});
				if (this.customObjectNamePic == 'ampi__Risk_Register__c') {
					defaultValues = encodeDefaultFieldValues({
						RecordTypeId: recordTypeID,
						Programme__c: this.recordId
					});
				} else if (this.customObjectNamePic == 'ampi__Risk_Assessment__c') {
					defaultValues = encodeDefaultFieldValues({
						RecordTypeId: recordTypeID,
						National_Association__c: this.recordId
					});
				}

				console.log('defaultValues if:' + defaultValues);

				this[NavigationMixin.Navigate]({
					type: 'standard__objectPage',
					attributes: {
						objectApiName: this.customObjectNamePic,
						actionName: 'new',
						nooverride: '1',
					},
					 state: {
							defaultFieldValues: defaultValues
					}
				});
			})
			.catch(error => {
				this.setResults(undefined, error, '', '');
			});
		} else {
			var defaultValues = '';
			if (this.customObjectNamePic == 'ampi__Risk_Register__c') {
					defaultValues = encodeDefaultFieldValues({
						Programme__c: this.recordId
					});
			} else if (this.customObjectNamePic == 'ampi__Risk_Assessment__c') {
					defaultValues = encodeDefaultFieldValues({
						National_Association__c: this.recordId
					});
			}

			console.log('defaultValues else:' + defaultValues);

			this[NavigationMixin.Navigate]({
				type: 'standard__objectPage',
				attributes: {
					objectApiName: this.customObjectNamePic,
					actionName: 'new'
				},
				state: {
					useRecordTypeCheck: 1,
					defaultFieldValues: defaultValues
				 }
			});
		}
	}

    editRow(row) {
			this.actionMixingNavigation(row.Id, this.customObjectNamePic, 'edit');
			console.log('row.Id:' + row.Id);
    }

	 deleteRow(row) {
        deleteRecord(row.ID)
            .then(() => {
				this.callToaster('Success', 'Record has been deleted', 'success');
				this.actionMixingNavigation(row.ID, this.customObjectNamePic, 'view');
            })
            .catch(error => {
				this.callToaster('Error while deleting record', error.body.message, 'error');
            });
    }

	navigateToRelatedList() {
		// Navigation to Related list //EXAMPLE NOT IMPLEMENTED YET
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                relationshipApiName: 'Contacts',
                actionName: 'view'
            },
        });
    }
	
	callToaster(title, message, variant){
		this.dispatchEvent(
                    new ShowToastEvent({
                        title: title,
                        message: message,
                        variant: variant
                    })
                );
	} 

	actionMixingNavigation(rowID, objectName, action) {
		this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: rowID,
                        objectApiName: this.customObjectNamePic,
                        actionName: action
                    }
		});
	}
}