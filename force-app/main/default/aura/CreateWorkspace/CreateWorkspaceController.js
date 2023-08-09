({
    handleCreateWorkspace : function(component, event, helper) {
        helper.hideAndShowSpinner(component);
        component.set("v.showConfirmationPopup", false);
        helper.createWorkspace(component, event, helper);
    },

    handleCloseWindow : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})