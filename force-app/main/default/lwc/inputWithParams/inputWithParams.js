import {LightningElement, api, track, wire} from 'lwc';
export default class InputWithParams extends LightningElement {
    @api value;
    @api id;
    @api category;
    @api piga;
    @api pirp;
    @api pi;
    @api endperioddate;
    @api tracked;
    @api type;
    @api decimalnumber;
    @track showdecimals;
    @track notShowdecimals;

    // @track isNumber = false;
    // @track isPercentage = false;
    @track isLabel = false;
    decimalCommaSeparator = ',';
    dotSeparator = '.';
    
    async connectedCallback() {
        this.isLabel = (this.type == 'Label');
        this.showdecimals = !this.isLabel && this.decimalnumber > 0;
        this.notShowdecimals = !this.isLabel && !this.showdecimals;
        
        // this.isNumber = (this.type == 'Number');
        // this.isPercentage = (this.type == 'Percentage');
        
        // console.log('####child value:' + this.value);
        // console.log('####child id:' + this.id);
        // console.log('####child category:' + this.category);
        // console.log('####child PIRP:' + this.pirp);
        // console.log('####child PI:' + this.pi);
        // console.log('####child PIGA:' + this.piga);
        // console.log('####child type:' + this.type);
        // console.log('####child endperioddate:' + this.endperioddate);
        // console.log('####child tracked:' + this.tracked);
    }

    handleValueChanged(event) {
        console.log('enter handleValueChanged');
        if (this.value === event.target.value) {
            return;
        }

        const fieldsToUpdate = {};		
		this.value = event.target.value;
		fieldsToUpdate['id'] = this.id;
        fieldsToUpdate['value'] = this.value;
        fieldsToUpdate['pirp'] = this.pirp;
        fieldsToUpdate['piga'] = this.piga;
        fieldsToUpdate['pi'] = this.pi;
        fieldsToUpdate['endperioddate'] = this.endperioddate;
        fieldsToUpdate['tracked'] = this.tracked;

		const selectedEvent = new CustomEvent("inputchanged", {
		  detail: fieldsToUpdate
		});

		this.dispatchEvent(selectedEvent);
        console.log('event:' + selectedEvent);
    }

    
    limitDecimalPlaces(event) {
        var regEx = /^\d*\,?\d{0,2}$/;
        if(!regEx.test(event.target.value)) {
             event.target.value = '0' + this.decimalCommaSeparator + '00';
            //  console.log('not number');
             return;    
        }

        // console.log(event);
        // console.log(event.target.value);
        var count = 2;
        if (event.target.value === undefined || event.target.value === null || event.target.value.indexOf(this.decimalCommaSeparator) == -1) { return; }
        if ((event.target.value.length - event.target.value.indexOf(this.decimalCommaSeparator)) > count) {
            event.target.value = (parseFloat(event.target.value.replace(this.decimalCommaSeparator,this.dotSeparator)).toFixed(count)).replace(this.dotSeparator,this.decimalCommaSeparator);
        }
    }
}