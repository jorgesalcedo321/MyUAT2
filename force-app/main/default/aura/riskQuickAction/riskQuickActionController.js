({
    doInit: function(component, event, helper) {
        //var obj = component.find("overlay").getElement();
        //obj.style='display:block';
        
        var recId = component.get("v.recordId");
        var ObjectName = component.get("v.objectLabel");
        component.set("v.title", (recId === undefined ? "New " : "Edit ") + ObjectName);
        
        if (recId === undefined) {
        	helper.getUrlParameter(component, 'recordTypeId');
        	helper.getProjectIdByUrl(component, 'projectId');
        	var recordTypeId = component.get("v.recordTypeId");  
            var objectName = component.get("v.objectApiName");    
            helper.getRecordTypeName(component, objectName, recordTypeId, 'recordTypeId');
        } else {
            var objectName = component.get("v.objectApiName");    
            helper.getRecordTypeIdByRecordId(component, objectName, recId, 'recordTypeId');
        }        
    },
	saveRecord : function(component, event, helper) {
        component.find("customFormContainer").saveFromDialog();
        //var cancelActionFunction = component.get("c.cancelDialog");
        //$A.enqueueAction(cancelActionFunction);   
	},    
    cancelDialog : function(component, event, helper) {
        //window.location.href = '../'; //one level up  or
        //window.location.href = '/path'; //relative to domain
        
        history.back();       
        //location.reload()
        //window.location.replace(document.referrer);
        $A.get("e.force:closeQuickAction").fire();
        /*var recId = component.get("v.recordId");
        var objectName = component.get("v.objectApiName");
        if (!recId) {
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
                "scope": objectName
            });
            homeEvt.fire();
        } else {
            helper.navigateTo(component, recId);
        }*/
    }, 
    getSaveStatusFromLwc: function(component, event, helper) {
        var result = event.getParam('errorExist');
        var id = event.getParam('id');
        component.set("v.recordId", id);
        
        console.log('###getSaveStatusFromLwc result:' + result);
        var cancelActionFunction = component.get("c.cancelDialog");
        if (result === false) {
            $A.enqueueAction(cancelActionFunction);
        }        
	}
})