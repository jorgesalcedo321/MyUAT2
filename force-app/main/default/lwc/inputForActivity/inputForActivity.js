import {LightningElement, api, track, wire} from 'lwc';
export default class InputForActivity extends LightningElement {
    @api id;
    @api value;
    @api islabel;
    @api ischeckbox;
    @api islistbox;
    @api ischecked;
    @api status;
    @track checked = false;
    @track statusOptions = [];

    @track Message;
    @api
    changeMessage(checked) {
        let childsTemplateList = this.template.querySelector('input');
        let childsList = this.getElementsByTagName('input');
        var checks = document.getElementById('id');
        
        console.log('####enter childsTemplateList:' + childsTemplateList);
        console.log('####enter checks:' + checks);
        console.log('####enter childsList:' + childsList.length);
        console.log('####enter childsList:' + childsList[0]);
        console.log('####enter changeMessage:' + checked);
        var checkboxes = this.template.querySelector('.input-number');
        console.log('####this.template:' + this.template);
        console.log('####checkboxes:' + checkboxes);
        checkboxes.forEach((v) => {
            console.log('####v:' + v);
            v.prop('checked', true);
        });
        
        // document.querySelector('input[name = "' + prop + '"]').value = prop; 
        //  this.Message = strString.toUpperCase();
    }

    async connectedCallback() {
        console.log('####connectedCallback:');
        if (this.ischecked) {
            this.checked = true;
        }

        if (this.islistbox) {
            var statusvalues = JSON.parse(this.status);
            var position = -1;
            for(var i=0; i<statusvalues.length; i++) {
                if (statusvalues[i].value == this.value) {
                    position = i;
                }
            }
            console.log('###position:' + position);
            
            for(var i=0; i<statusvalues.length; i++) {
                var ischecked = (position === i);
                this.statusOptions.push({label:statusvalues[i].label, value:statusvalues[i].value, checked: ischecked});
            }
            console.log('···this.statusOptions:' + JSON.stringify(this.statusOptions));
        }
    }

    checkChangeHandler(event) {
        if (this.value === event.target.value) {
            return;
        }

		this.checked = event.target.value;
        console.log('event:' + this.checked);
    }

    statusChangeHandler(event) {
        if (this.value === event.target.value) {
            return;
        }

        const fieldsToUpdate = {};		
		this.value = event.target.value;
		fieldsToUpdate['id'] = this.id;
        fieldsToUpdate['checked'] = true;
        fieldsToUpdate['status'] = this.value;

		const selectedEvent = new CustomEvent("inputchanged", {
		  detail: fieldsToUpdate
		});

		this.dispatchEvent(selectedEvent);
        console.log('event:' + selectedEvent);
    }

}