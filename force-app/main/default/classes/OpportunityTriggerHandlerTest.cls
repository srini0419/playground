@isTest
public class OpportunityTriggerHandlerTest {
    
    public static testmethod void onBeforeUpdateTest () {
        
        // create a Contact record to be used in Opportunity Contact Role
        Contact con   = new Contact();
        con.FirstName = 'Srini';
        con.LastName  = 'Test';
        insert con;
        System.debug('Contact created: ' + con.Id);
        
        // create an Opportunity record
        Opportunity opty = new Opportunity();
        opty.name        = 'Test Opty';
        opty.CloseDate   = Date.today() + 30;
        opty.StageName   = 'Prospecting';
        insert opty;
        System.debug('Opportunity created: ' + opty.Id);
        
        // create an Opportunity Contact Role record
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opty.Id;        
		ocr.ContactId     = con.Id;
        ocr.Role          = 'Business User';
        insert ocr;
        System.debug('Opportunity Contact Role created: ' + ocr.Id);

        // Test 1: fire the before trigger to test updating Opty Stage with proper Contact Role
        Test.startTest();

        System.debug('positive test case');
		opty.StageName = 'Qualification';
        update opty;
        
        // Test 2: negative test
        try {
            System.debug('negative test case');
            opty.StageName = 'Needs Analysis';
            update opty;
        } catch (Exception e) {
			System.assert(e.getMessage().contains('Opportunity Stage doesn\'t have corresponding Contact Role(s) for the Opportunity ' + opty.Id), e.getMessage());
        }

        System.debug('both positive and negative test cases executed');
        
        Test.stopTest();
        System.debug('Opportunity updated: ' + ocr.Id);
        
        List<Opportunity> lstOpty = [SELECT Id, StageName FROM Opportunity WHERE Id = :opty.Id and StageName = 'Qualification'];
        System.assertEquals(1, lstOpty.size());
    }
}