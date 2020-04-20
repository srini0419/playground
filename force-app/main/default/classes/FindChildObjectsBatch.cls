global class FindChildObjectsBatch implements Database.Batchable <SObject> {
  /*
   * Author      : Srini Reddy
   * Description : 
   * Created     : 
   * Last Updated: 
  */
  /* invoking this from anon block

  select count() from FeedItem where parentid in (select id from account where recordtype.name = 'Radiology_Contact')
  select count() from EntitySubscription where parentid in (select id from account where recordtype.name = 'Radiology_Contact')
  select count() from RecordActionHistory where ParentRecord.id in (select id from account where recordtype.name = 'Radiology_Contact')

  List<AsyncApexJob> lstJobs = [SELECT Id, ApexClass.Name, Status FROM AsyncApexJob WHERE ApexClass.Name = 'FindChildObjectsBatch' 
      AND JobType = 'BatchApex' AND (Status = 'Holding' OR Status = 'Queued' OR Status = 'Preparing' OR Status = 'Processing')];

  for (AsyncApexJob jb : lstJobs) {
    try {
      System.debug('Aborting job: ' + jb);
      System.abortJob(jb.Id);
    } catch (Exception e) {
      System.debug(e.getMessage() + '\n' + e.getStackTraceString());
    }
  }

  FindChildObjects oCO = new FindChildObjects();      
  oCO.DeleteRecords();
  oCO.WriteChildRecords (new String[] { 'Account' });

  FindChildObjectsBatch oBatch = new FindChildObjectsBatch();
  Database.executeBatch (oBatch, 1);

  select Count__c, Name__c, Process__c, In_Scope__c, Relationship_Name__c, Field_Relationship_Name__c, Field_Count__c, Sample_Id__c, Field_SOQL_Error__c, Id_SOQL_Error__c from Child_Object_Detail__c

  select Count__c, Name__c, Process__c, In_Scope__c, Relationship_Name__c, Field_Relationship_Name__c, Field_Count__c, Sample_Id__c, Field_SOQL_Error__c, Id_SOQL_Error__c from Child_Object_Detail__c

  */

  Integer iCount1 = 1;
  Integer iCount2 = 1;
  Integer ii      = 1;
  
  // start: use iterable later
  global Database.QueryLocator start (Database.BatchableContext bc) {
    System.debug('start() processed: ' + iCount1);
    String sCountQuery = 'SELECT Id, Name__c, Count__c, Field_Count_SOQL__c, Child_Id_SOQL__c FROM Child_Object_Detail__c ' 
      + 'WHERE Process__c = true AND Field_Count__c = null AND Sample_Id__c = \'\' ORDER BY Count__c ASC';
    
    return Database.getQueryLocator(sCountQuery);
  }

  // execute: read SOQLs from Child_Objhect_Detail__c, run them and write back to the same object
  global void execute (Database.BatchableContext bc, List<Child_Object_Detail__c> recordsToProcess) {
    if (!recordsToProcess.isEmpty()) {
      for (Child_Object_Detail__c co : recordsToProcess) {
        System.debug(ii + ': record processed: ' + co.Count__c + ' ' + co);
        co.Field_Count__c          = null;
        co.Sample_Id__c            = '';
        co.Field_SOQL_Error__c     = '';
        co.Id_SOQL_Error__c        = '';
        co.Process__c              = false;
        String sChild              = co.Name__c;
        SObjectType sChildType     = Schema.getGlobalDescribe().get(sChild);
        if (sChildType.getDescribe().isAccessible() && sChildType.getDescribe().isQueryable()) {
          try {
            AggregateResult ar     = Database.query(co.Field_Count_SOQL__c);
            if (ar != null) {
              co.Field_Count__c    = (Integer) ar.get('cnt');
              co.Id_SOQL_Error__c  = (co.Field_Count__c == 0) ? 'There are NO child records!!!' : '';
              System.debug(ii + ': COUNT query result: ' + ar);
            }
          } catch (Exception e) {
            co.Field_SOQL_Error__c = e.getMessage() + '\n' + e.getStackTraceString();
            co.Id_SOQL_Error__c    = co.Field_SOQL_Error__c;
            System.debug(ii + ': ' + e.getMessage() + '\n' + e.getStackTraceString());
          }

          if ((co.Field_SOQL_Error__c == '') && (co.Field_Count__c > 0)) {
            try {
              SObject qr = Database.query(co.Child_Id_SOQL__c);
              if (qr != null) {
                co.Sample_Id__c    = (String) qr.get('Id');
                System.debug(ii + ': ID query result: ' + qr);
              }
            } catch (Exception e) {
              co.Id_SOQL_Error__c  =   e.getMessage() + '\n' + e.getStackTraceString();
              System.debug(ii + ': ' + e.getMessage() + '\n' + e.getStackTraceString());
            }
          }
        } else {
            co.Field_SOQL_Error__c = co.Name__c + ': object is not queryable!!!';
            co.Id_SOQL_Error__c    = co.Field_SOQL_Error__c;
            System.debug(ii + ': ' + co.Field_SOQL_Error__c);
        }

        ii++;
      }

      System.debug(iCount2 + ': updating query results');
      List<Database.SaveResult> sr = Database.update(recordsToProcess, false);
      System.debug(iCount2 + ': updated query results: ' + sr);
    }
  }

  // finish: email the job details
  global void finish (Database.BatchableContext bc) {
    AsyncApexJob jobDetails = [SELECT Id, Status, TotalJobItems, JobItemsProcessed, NumberOfErrors, CreatedBy.Email
                                            FROM AsyncApexJob WHERE Id =: bc.getJobId()];
    System.debug('Batch Job Id: ' + bc.getJobId() + '\n' + jobDetails);

    Messaging.SingleEmailMessage oEmailMsg = new Messaging.SingleEmailMessage();
    String[] sToAddr                  = new String[]{'srini.r@standav.com'};
    oEmailMsg.setToAddresses(sToAddr);
    oEmailMsg.setSubject('Batch Completion Alert');
    oEmailMsg.setPlainTextBody('FindChildObjectsBatch (' + bc.getJobId() + ') has been processed!!!' + '\n' + jobDetails);

    Messaging.Email[] oEmail          = new Messaging.Email[]{oEmailMsg};
    //Messaging.sendEmail(oEmail);
  }
}