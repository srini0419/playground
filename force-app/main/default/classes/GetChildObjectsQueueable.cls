public with sharing class GetChildObjectsQueueable implements Queueable {
  public Child_Object_Detail__c oChild;

  public GetChildObjectsQueueable (Child_Object_Detail__c Child) {
    this.oChild = Child;
  }

  public void execute (QueueableContext qc) {
    Integer ii = 1;
    System.debug(ii + ': execute started');
    if (oChild != null) {
      System.debug(ii + ': record processed: ' + oChild.Count__c + ' ' + oChild);
      if (oChild.Is_Queryable__c) {
        oChild.Field__c                  = '';
        oChild.Field_SOQL_Error__c       = '';
        oChild.Field_Count_SOQL_Error__c = '';
        oChild.Total_Count_SOQL_Error__c = '';
        oChild.Total_Count__c            = null;
        oChild.Field_Count__c            = null;
        oChild.Process__c                = false;

        try {
          AggregateResult arTotalCount        = Database.query(oChild.Total_Count_SOQL__c);
          if (arTotalCount != null) {
            oChild.Total_Count__c             = (Integer) arTotalCount.get('cnt');
            oChild.Field_Count_SOQL_Error__c  = (oChild.Total_Count__c == 0) ? 'There are NO child records!!!' : '';
            oChild.Field_SOQL_Error__c        = oChild.Field_Count_SOQL_Error__c;
            System.debug(ii + ': TOTAL query result: ' + arTotalCount);
          }
        } catch (Exception e) {
          oChild.Total_Count_SOQL_Error__c    = e.getMessage() + '\n' + e.getStackTraceString();
          oChild.Field_Count_SOQL_Error__c    = oChild.Total_Count_SOQL_Error__c;
          oChild.Field_SOQL_Error__c          = oChild.Total_Count_SOQL_Error__c;
          System.debug(ii + ': ' + e.getMessage() + '\n' + e.getStackTraceString());
        }

        if ((oChild.Total_Count_SOQL_Error__c == '') && (oChild.Total_Count__c > 0)) {
          try {
            AggregateResult arFieldCount      = Database.query(oChild.Field_Count_SOQL__c);
            if (arFieldCount != null) {
              oChild.Field_Count__c           = (Integer) arFieldCount.get('cnt');
              oChild.Field_SOQL_Error__c      = (oChild.Field_Count__c == 0) ? 'There are NO child records!!!' : '';
              System.debug(ii + ': COUNT query result: ' + arFieldCount);
            }
          } catch (Exception e) {
            oChild.Field_Count_SOQL_Error__c  = e.getMessage() + '\n' + e.getStackTraceString();
            oChild.Field_SOQL_Error__c        = oChild.Field_Count_SOQL_Error__c;
            System.debug(ii + ': ' + e.getMessage() + '\n' + e.getStackTraceString());
          }

          if ((oChild.Field_SOQL_Error__c == '') && (oChild.Field_Count__c > 0)) {
            try {
              SObject qrField                 = Database.query(oChild.Field_SOQL__c);
              if (qrField != null) {
                oChild.Field__c               = (String) qrField.get('Id');
                System.debug(ii + ': FIELD query result: ' + qrField);
              }
            } catch (Exception e) {
              oChild.Field_SOQL_Error__c      =   e.getMessage() + '\n' + e.getStackTraceString();
              System.debug(ii + ': ' + e.getMessage() + '\n' + e.getStackTraceString());
            }
          }
        }
      } else {
          oChild.Process__c                   = false;
          oChild.Total_Count_SOQL_Error__c          = oChild.Object_Name__c + ': object is not queryable!!!';
          oChild.Field_Count_SOQL_Error__c    = oChild.Total_Count_SOQL_Error__c;
          oChild.Field_SOQL_Error__c          = oChild.Total_Count_SOQL_Error__c;
          System.debug(ii + ': ' + oChild.Total_Count_SOQL_Error__c);
      }

      System.debug(ii + ': updating query results');
      Database.SaveResult sr = Database.update(oChild, false);
      System.debug(ii + ': updated query results' + sr);
    } // outer if
  } // execute
} // class