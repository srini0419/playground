public with sharing class OpportunityTriggerHandler {

    public static void onBeforeUpdate (List<Opportunity> lstOpty) {
        // Get list of Opportunities which need to be validated
        List<String> lstOptyIds = new List<String>();
        for (Opportunity opty : lstOpty) {
            lstOptyIds.add(opty.Id);
        }
    
        // Get the Opportunity Contact Roles for the list of Opportunities being updated and
        // put them into a Map
        Map<String, String> mapOCR = new Map<String, String> ();
        List<OpportunityContactRole> lstOCR = [SELECT Id, OpportunityId, Role 
                                            from OpportunityContactRole
                                            where OpportunityId = :lstOptyIds];
        for (OpportunityContactRole ocr : lstOCR) {
            if (mapOCR.get(ocr.OpportunityId) == null) {
                mapOCR.put(ocr.OpportunityId, ocr.Role);
            } else {
                mapOCR.put(ocr.OpportunityId, ocr.Role + ';' + mapOCR.get(ocr.OpportunityId));
            }
        }
        System.debug('mapOCR: ' + mapOCR);

        // Get the Opportunity Stage Contact Role Custom Metadata Type values and put it 
        // into a map to be used later
        Map<String, String> mapStageContactRole = new Map<String, String>();
        List<Opportunity_Stage_Contact_Roles_Mapping__mdt> lstStageContactRole 
            = [SELECT id, MasterLabel, Contact_Role__c 
               from Opportunity_Stage_Contact_Roles_Mapping__mdt];

        for (Opportunity_Stage_Contact_Roles_Mapping__mdt scr : lstStageContactRole) {
            mapStageContactRole.put(scr.MasterLabel, scr.Contact_Role__c);
        }
        System.debug('mapStageContactRole: ' + mapStageContactRole);
    
		// Find if there exists a Contact Role for a given Opportunity based on the taxonomy
		// defined in the Custom Metadata Type and display error if Contact Role doesn't exist
        for (Opportunity opty : lstOpty) {
            Boolean isMatched = false;
            List<String> lstOCR2;
            List<String> lstSCR;
            
            if ((mapOCR.get(opty.id) != null) && (mapStageContactRole.get(opty.StageName) != null)) {
                lstOCR2 = mapOCR.get(opty.id).split(';');
                lstSCR  = mapStageContactRole.get(opty.StageName).split(';');
                
                for (String role: lstSCR) {
                    if (lstOCR2.contains(role)) {
                        isMatched = true;
                    }
                }
            }
    
            if (!isMatched) {
                opty.addError('Opportunity Stage doesn\'t have corresponding Contact Role(s) for the Opportunity ' + opty.Id);
            }
        }
    }
}