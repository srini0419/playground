({
	clickHandler : function(component, event, helper) {
        var btnClicked = event.getSource();
        var btnName    = btnClicked.getLocalId();
        console.log(btnName + ' is clicked!!!' );
        component.set("v.WhichButton", btnName);
	}
})