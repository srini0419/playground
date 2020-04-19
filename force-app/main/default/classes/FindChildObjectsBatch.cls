global class FindChildObjectsBatch implements Database.Batchable <SObject> {
  Integer ii = 1;
  Integer jj = 1;
  Integer kk = 1;
  
  // start: 
  global Database.QueryLocator start (Database.BatchableContext bc) {
    String sCountQuery = 'SELECT Id FROM Child_Object_Detail__c ' 
      + 'WHERE Process__c = true AND Field_Count__c = null AND Sample_Id__c = \'\' ORDER BY Sequence__c ASC';
    System.debug(ii + ': start() processed: ' + sCountQuery);
    ii++; 
    return Database.getQueryLocator(sCountQuery);
  }

  // execute: read SOQLs from Child_Objhect_Detail__c, run them and write back to the same object
    global void execute (Database.BatchableContext bc, List<Child_Object_Detail__c> lstToProcess) {}
  // finish: email the job details
  global void finish (Database.BatchableContext bc) {
  }

}