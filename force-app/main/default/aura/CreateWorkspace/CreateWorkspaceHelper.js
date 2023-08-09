({
    createWorkspace : function(component, event, helper) {
        var action = component.get("c.createWorkspaceForProject");
        action.setParams(
            {
                "projectId" : component.get("v.recordId")
            }
        );
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const responseObject = response.getReturnValue();
                component.set("v.message", responseObject.message);
                component.set("v.isSuccess", responseObject.isSuccess);
                if (responseObject.isSuccess) {
                    helper.showToastMessage(component, 'success', 'Success!');
                    $A.get("e.force:closeQuickAction").fire();
                }
                helper.hideAndShowSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    hideAndShowSpinner : function(component){
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },

    showToastMessage : function(component, type, title) {
        var toastEvent = $A.get("e.force:showToast");
        var message = component.get("v.message");
        toastEvent.setParams({
            "type" : type,
            "title" : title,
            "message" : message
        });
        toastEvent.fire();
    }
})