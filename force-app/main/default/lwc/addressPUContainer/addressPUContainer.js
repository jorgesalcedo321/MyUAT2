import { NavigationMixin } from 'lightning/navigation';
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue, updateRecord, createRecord } from 'lightning/uiRecordApi';
import getPickListValuesFromDatafield from '@salesforce/apex/RiskController.getPickListValuesFromDatafield';
import updateCorrespondanceAddressFromPU from '@salesforce/apex/RiskController.updateCorrespondanceAddressFromPU';
import getCorrespondanceAddressFromPU from '@salesforce/apex/RiskController.getCorrespondanceAddressFromPU';

export default class AddressPUContainer extends NavigationMixin(LightningElement) {
    @track correspondingAddressChecked = false;
    @api recordId;
    @api objectApiName;
    @track viewEditFormVisible;
    @track correspondanceLabel = 'Corresponding address different';
    @track picklistDatafield = 'Corresponding_address_different__c';
    @track selectedOptionValue;
    @track options = [];
    @track showSection = true;
    @track notShowSection = false;    
    @track additional = true;
    @track noAdditional = false;
    @track openSection = true;

    isLoading = false;
    objectLabel = 'P&PU';
    sectionLabel = 'Basic Information';

    handleSectionClick() {
        this.openSection = !this.openSection;
    }

    async connectedCallback() {
        this.isLoading = true;
        console.log('####this.recordId:' + this.recordId);
        console.log('####this.selectedOptionValue:' + this.selectedOptionValue);
        var record = await getCorrespondanceAddressFromPU({puId: this.recordId});
        console.log('###record:' + JSON.stringify(record));
        if (record !== null) {
            this.selectedOptionValue = record[this.picklistDatafield];
            this.correspondingAddressChecked = this.selectedOptionValue === 'Yes';
        }
        this.isLoading = false;
    }
    
    @wire(getPickListValuesFromDatafield, { objectName: '$objectApiName', picklistDatafield: '$picklistDatafield' })
    getPickListValuesFromDatafield({ error, data }) {
        if (data) {
            if (data != null && data != undefined) {
                this.fillComboboxItems(data);
            }
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Error: cant get correspondance address diferent values.',
                    variant: 'error'
                })
            );
        }
    }

    fillComboboxItems(data) {
        this.options = [];

        for (let i = 0; i < data.length; i++) {
            this.options.push({
                value: data[i],
                label: data[i],
                checked: this.selectedOptionValue == data[i],
            });
        }
        this.changeOptionHandler(this.selectedOptionValue);
    }

    changeHandler(event) {
        const field = event.target.name;
        if (field === 'optionSelect' && event != undefined) {
            this.changeOptionHandler(event.target.value, true);
        }
    }

    changeOptionHandler(value) {
        this.selectedOptionValue = value;
        for (let i = 0; i < this.options.length; i++) {
            if (this.options[i].value == this.selectedOptionValue) {
                this.selectedOptionValue = this.options[i].value;
            }
        }
    }

    async correspondingAddressChanged(event) {
        console.log('event.target.value:' + event.target.value);
        this.selectedOptionValue = event.target.value;
        this.correspondingAddressChecked = (this.selectedOptionValue === 'Yes');        
        await this.handleSuccess({});
    }
    
    async handleSuccess(event) {
        console.log('####handleSuccess');
        this.errorExist = false;
        // const fieldsToUpdate = {};
        // fieldsToUpdate['Id'] = this.recordId;
        // fieldsToUpdate[picklistDatafield] = this.selectedOptionValue;
        // var recordInput = { fields: fieldsToUpdate };

        this.correspondingAddressChecked = this.selectedOptionValue === 'Yes';
        this.isLoading = true;

        console.log('####this.recordId:' + this.recordId);
        console.log('####this.selectedOptionValue:' + this.selectedOptionValue);
        var error = await updateCorrespondanceAddressFromPU({puId: this.recordId, correspondanceAddress: this.selectedOptionValue});
        // console.log('####recordInput Update:' + JSON.stringify(recordInput));
        // updateRecord(recordInput).then(() => {
        if (error === '') {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: this.objectLabel + ' updated',
                    variant: 'success'
                })
            );
        // }).catch(error => {
        } else {
            this.errorExist = true;
            this.errorText = error;
            this.isLoading = false;
            // var output = error.body.output.errors;
            // if (Array.isArray(output)) {
            //     if (output.length > 0) {
            //         for (var i = 0; i < output.length; i++) {
            //             this.errorText += output[i]['message'] + "\n";
            //         }
            //     }
            // }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating ' + this.objectLabel + ' record',
                    message: this.errorText,
                    variant: 'error'
                })
            );
        // });
        }

        await this.connectedCallback();
        this.isLoading = false;
    }


    handleError(event) {
        console.log('onerror event recordEditForm', event);
        console.log('onerror event recordEditForm JSON', JSON.stringify(event));
        this.isLoading = false;
    }
}