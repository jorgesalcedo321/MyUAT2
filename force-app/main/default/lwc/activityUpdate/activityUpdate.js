import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import getStatusesFromActivity from '@salesforce/apex/activityExtension.getStatusesFromActivity';
import getProjectResultStatementFromProject from '@salesforce/apex/activityExtension.getProjectResultStatementFromProject';
import getActivitiesFromYearAndResultAndProject from '@salesforce/apex/activityExtension.getActivitiesFromYearAndResultAndProject';
import getMainActivitiesFromYearAndNewStatus from '@salesforce/apex/activityExtension.getMainActivitiesFromYearAndNewStatus';
import getLateStartDateFromActivity from '@salesforce/apex/activityExtension.getLateStartDateFromActivity';
import getEarlyStartDateFromActivity from '@salesforce/apex/activityExtension.getEarlyStartDateFromActivity';
import updateMainActivitiesFromYearAndNewStatusToPlanning from '@salesforce/apex/activityExtension.updateMainActivitiesFromYearAndNewStatusToPlanning';
import getProjectInfoStatus from '@salesforce/apex/activityExtension.getProjectInfoStatus';
import LightningConfirm from 'lightning/confirm';

export default class ActivityUpdate extends LightningElement {
    @api recordId;
	@api objectName;
    @track buttonName;
    @track noteTitle;
    @track noteDescription;
    @track headerTitle;
    @track noteWarning;
    @track isLoading = false;
    @track labelResult = '';
    @track labelYear = '';
    @track resultOptions = [];
    @track yearOptions = [];
    @track statusOptions = [];
    @track selectedOptionYear;
    @track selectedOptionStatus;
    @track selectedOptionResult;
    @track activitiesFound = [];
    @track pageHeadersData = [];
    @track pageDetailsData = [];
    @track isModalOpen = false;
    @track buttonClass = 'slds-button slds-button_brand space-left';
    @track showModal = false;
    @track showNegativeButton;
    @track showPositiveButton = true;
    @track positiveButtonLabel = 'Close';
    @track checkAllActivities = false;
    @track noActivitiesAvailable = true;
    @track jsonstatus = '';
    @track valuesToSave = [];
    @track saveButton = 'Update all Activity Status To "Planning"';
    @track searchButton = 'Search';
    question = 'Do you want to continue?';
    closeModal() {
        this.showModal = false;
    }

    showModalPopup() {
        this.showModal = true;
    }

    async connectedCallback() {
        this.buttonName = 'Send Activities for budgeting';
        this.headerTitle = 'Send activities for annual budgeting';
        this.noteWarning = 'Please Note:';
        this.noteTitle = 'Changing the status of activities from "new" to "planning", will trigger a synchronization to D365 if the activity belongs to either the following (budgeting) year or to current year.';
        this.noteDescription = 'Select a result statement which you would like to change activities for:';
        this.labelResult = 'Result Statement';
        this.labelYear = 'Year';
		this.objectApiName = this.objectName;
		this.isLoading = false;		
		this.coloringClass = 'slds-grid slds-wrap coloring-in-form-style';
		this.coloringContainer = 'slds-col';
        await this.getProjectInfo();
        await this.getStatusOptions();
        await this.getResultOptions();
        await this.getYearOptions();
	}

    async getProjectInfo() {
        var projs = await getProjectInfoStatus({projectId : this.recordId});

        if (projs.length > 0) {
            console.log('####projs[0]:' + JSON.stringify(projs[0]));
            console.log('####projs[0].Phase__c:' + projs[0].Phase__c);
            if (projs[0].Phase__c !== 'Formulation' && projs[0].Phase__c !== 'Implementation') {
                this.buttonClass = this.buttonClass + ' hideComponent';
            }
        } else {
            this.buttonClass = this.buttonClass + ' hideComponent';
        }
    }

    async getStatusOptions() {
        var results = await getStatusesFromActivity({});
        console.log('####getStatusOptions results:' + JSON.stringify(results));
        if (results === null) 
            return;

        for(var i = 0; i < results.length; i++) {
            this.statusOptions.push({value: results[i].value, label: results[i].label, checked: false});
        }
        this.jsonstatus = JSON.stringify(this.statusOptions);

        if (results.length > 0) {
            this.selectedOptionStatus = results[0].value;
        }
        // console.log('####getStatusOptions this.statusOptions:' + JSON.stringify(this.statusOptions));
    }

    async getResultOptions() {
        var results = await getProjectResultStatementFromProject({projectId : this.recordId});
        console.log('####getResultOptions results:' + JSON.stringify(results));
        if (results === null) 
            return;

        // this.resultOptions.push({value: null, label: 'Please Select'});
        for(var i = 0; i < results.length; i++) {
            this.resultOptions.push({value: results[i].Id, label: results[i].ampi__Label__c  + ' ' + results[i].ampi__Description__c});
        }

        if (results.length > 0) {
            this.selectedOptionResult = results[0].Id;
        }
    }

    async getYearOptions() {
        var initial = await getEarlyStartDateFromActivity({projectId: this.recordId});
        var ending = await getLateStartDateFromActivity({projectId: this.recordId});
        var currentYear = (new Date()).getFullYear();

        console.log('###initial:' + initial);
        console.log('###ending:' + ending);
        if (initial === 0 || ending === 0) 
            return;

        // this.yearOptions.push({value: null, label: 'Please Select'});
        for(var i = initial; i <= ending; i++) {
            if (currentYear == i || (currentYear + 1) == i) {
                this.yearOptions.push({value: i, label: i});
            }
        }

        if (this.yearOptions.length > 0) {
            this.selectedOptionYear = this.yearOptions[0].value;
        }
    }

    yearChangeHandler(event) {
		const field = event.target.name;
		const value = event.target.value;
        console.log('### yearChangeHandler field:' + field);
        console.log('### yearChangeHandler value:' + value);
		if (field === 'yearSelect' && event != undefined) {
			this.selectedOptionYear = value;		
        }
    }

    resultChangeHandler(event) {
		const field = event.target.name;
        const value = event.target.value;
        console.log('### resultChangeHandler field:' + field);
        console.log('### resultChangeHandler value:' + value);
		if (field === 'resultSelect' && event != undefined) {
			this.selectedOptionResult = value;		
        }		
    }

    markAllActivities(event) {
        this.checkAllActivities = event.target.checked;

        if (this.checkAllActivities) {
            this.template.querySelector('c-input-for-activity').changeMessage(event.target.checked);
        }
    }

    checkChangeHandler(event) {

    }

    statusChangeHandler(event) {

    }

    async saveActivities() {
        const result = await LightningConfirm.open({
            message: this.noteTitle + ' ' + this.question,
            variant: 'headerless',
            label: 'this is the aria-label value',
            // setting theme would have no effect
        });
        // https://developer.salesforce.com/docs/component-library/bundle/lightning-confirm/documentation
        // Confirm has been closed result is true if OK was clicked and false if cancel was clicked
        if (result === false) {
            return;
        }

        var errorMessage = await updateMainActivitiesFromYearAndNewStatusToPlanning({year: this.selectedOptionYear, projectId : this.recordId, });

        if (errorMessage != '') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error'
                })
            );
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Activities were updated to "Planning" status successfully',
                    variant: 'success'
                })
            );
            await this.searchActivities();
        }        
    }

    async searchActivities() {
        this.activitiesFound = [];
        if (this.selectedOptionYear === null || this.selectedOptionResult === null) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Year and Result information are mandatory',
                    variant: 'error'
                })
            );
            return;
        }

        this.fillActivitiesTable();
        console.log('###this.selectedOptionYear:' + this.selectedOptionYear);
        console.log('###this.selectedOptionResult:' + this.selectedOptionResult);
        console.log('####this.activitiesFound:' + JSON.stringify(this.activitiesFound));
    }

    async fillActivitiesTable() {
        // this.activitiesFound = await getActivitiesFromYearAndResultAndProject({year: this.selectedOptionYear, result: this.selectedOptionResult, projectId : this.recordId, });
        this.activitiesFound = await getMainActivitiesFromYearAndNewStatus({year: this.selectedOptionYear, projectId : this.recordId, });
        console.log('###this.activitiesFound:' + JSON.stringify(this.activitiesFound));
        this.pageHeadersData = [];
        this.pageDetailsData = [];
        var mpValues = [];
        // this.pageHeadersData.push({label: 'Check', check: true});
        this.pageHeadersData.push({label: 'Activity', check: false});
        this.pageHeadersData.push({label: 'Activity Name', check: false});
        this.pageHeadersData.push({label: 'Service Type', check: false});
        // this.pageHeadersData.push({label: 'Activity Status', check: false});

        for(var i=0; i < this.activitiesFound.length; i++) {
            mpValues = [];
            // console.log(this.activitiesFound[i].Thematic_Area__r.Name);
            // console.log(this.activitiesFound[i].Thematic_Area__r['Name']);
            // console.log(this.activitiesFound[i]['Thematic_Area__r'].Name);
            // mpValues.push({name: 'check' + i, isid: false, ischeckbox: true, islabel: false, islistbox: false, value: this.activitiesFound[i].Id, id: this.activitiesFound[i].Id});
            mpValues.push({name: 'activityid' + i, isid: false, ischeckbox: false, islabel: true, islistbox: false, value: this.activitiesFound[i].Activity_ID__c, id: this.activitiesFound[i].Id});
            mpValues.push({name: 'name' + i, isid: false, ischeckbox: false, islabel: true, islistbox: false, value: this.activitiesFound[i].Name, id: this.activitiesFound[i].Id});
            mpValues.push({name: 'servicetype' + i, isid: false, islistbox: false, islabel: true, value: (this.activitiesFound[i].Thematic_Area__r === undefined ? '' : this.activitiesFound[i].Thematic_Area__r.Name), id: this.activitiesFound[i].Id});
            // mpValues.push({name: 'status' + i, isid: false, islistbox: true, islabel: false, value: this.activitiesFound[i].ampi__Status__c, id: this.activitiesFound[i].Id});
            this.pageDetailsData.push({name: 'array' + i, Value:mpValues});
        }
        this.noActivitiesAvailable = !(this.pageDetailsData !== undefined && this.pageDetailsData.length > 0 && this.yearOptions.length > 0);

        console.log('####this.noActivitiesAvailable:' + this.noActivitiesAvailable);
        console.log('####this.pageHeadersData:' + JSON.stringify(this.pageHeadersData));
        console.log('####this.pageDetailsData:' + JSON.stringify(this.pageDetailsData));
        // Id, Name, ampi__Status__c, Activity_ID__c

        // console.log('this.monitoringPeriodOptions:' + JSON.stringify(this.monitoringPeriodOptions));
    }

    async handleInputValueChange(event) {
        console.log('###event handleInputValueChange:' + JSON.stringify(event));
        var checked = event.detail['checked'];

        if (checked === true) {
            this.valuesToSave.push({sObjectType: 'ampi__activity__c', 
                                    Id: event.detail['id'], 
                                    status: event.detail['status']});
        }
        await this.handleSaveClick({});
	}

    async handleListboxValueChange(event) {
        console.log('###event handleInputValueChange:' + JSON.stringify(event));
        var checked = event.detail['checked'];

        if (checked === true) {
            this.valuesToSave.push({sObjectType: 'ampi__activity__c', 
                                    Id: event.detail['id'], 
                                    status: event.detail['status']});
        }
        await this.handleSaveClick({});
	}

    async handleSaveClick() {
        
    }

    async handleListBoxValueChange(event) {
        console.log('###event handleListBoxValueChange:' + JSON.stringify(event));        
    }

    /*openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    submitChanges() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }*/
}