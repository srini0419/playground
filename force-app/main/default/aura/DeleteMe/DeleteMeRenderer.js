({
	// Your renderer method overrides go here
    render : function (component, helper) {
		var parentVal = component.find("msg");
        console.log(parentVal + '\n renderer invoked');
        helper.changeValue(component);
        return this.superRender();
    }
})