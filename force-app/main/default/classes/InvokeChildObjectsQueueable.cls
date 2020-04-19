public with sharing class InvokeChildObjectsQueueable {
  public void InvokeChildObjectsQ (Integer iOffset) {
    List<Child_Object_Detail__c> lstCO = [SELECT Id, Object_Name__c, Count__c, Is_Queryable__c, Total_Count_SOQL__c,  
                                          Field_Count_SOQL__c, Field_SOQL__c 
                                          FROM Child_Object_Detail__c 
                                          WHERE Process__c = true AND Field_Count__c = null AND Field__c = '' 
                                          AND   Count__c >= :iOffset
                                          ORDER BY Count__c ASC
                                          LIMIT 50];
    System.debug('InvokeChildObjectsQ(): ' + lstCO.size() + ' - ' + lstCO);

    // invoke GetChildObjectsQueueable 
    for (Child_Object_Detail__c co : lstCO) {
      System.debug('Invoke GetChildObjectsQueueable for: ' + co);
      GetChildObjectsQueueable oCOQ = new GetChildObjectsQueueable(co); 
      System.enqueueJob(oCOQ);
    }
  }

  private void ExecuteAnon () {
    /*
    InvokeChildObjectsQueueable oCOQ = new InvokeChildObjectsQueueable ();
    oCOQ.InvokeChildObjectsQ(1);

    // find records processed
    select Id, Object_Name__c, Field__c, Sequence__c, Count__c, Process__c, In_Scope__c, Is_Queryable__c, Total_Count__c, 
    Field_Count__c, Total_Count_SOQL_Error__c, Field_Count_SOQL_Error__c, Field_SOQL_Error__c, Relationship_Field__c, 
    Relationship_Name__c, Field_Relationship_Name__c, Total_Count_SOQL__c, Field_Count_SOQL__c, Field_SOQL__c  
    from Child_Object_Detail__c where count__c > 0 and process__c = false order by Sequence__c

    // SOQL to see if the current Apex Batch is still running
    SELECT Id, ApexClass.Name, Status FROM AsyncApexJob WHERE ApexClass.Name = 'GetChildObjectsQueueable' 
    AND JobType = 'Queueable' AND (Status = 'Holding' OR Status = 'Queued' OR Status = 'Preparing' OR Status = 'Processing')

    */
  }
}