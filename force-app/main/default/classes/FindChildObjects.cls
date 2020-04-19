public with sharing class FindChildObjects {

  // delete existing child object records
  public void DeleteRecords () {
    List<Child_Object_Detail__c> lstCO = [SELECT Id FROM Child_Object_Detail__c];
    if (lstCO != null && lstCO.size() > 0) {
      delete lstCO;
    }
  }

  // get child objects and build SOQL into 2 maps (child+field, soql); one for counts, other for id's
  public void WriteChildRecords (String[] Types, String RecordType) {
    List < Child_Object_Detail__C > lstChilds = new List < Child_Object_Detail__C > ();

    // Make the describe call for the inputs sObject Types
    Schema.DescribeSobjectResult[] results = Schema.describeSObjects(Types);
    System.debug('Describe information for ' + Types + ' :' + results);

    for (Schema.DescribeSobjectResult res: results) {
      Integer ii                                              = 1;
      String sAccountRecordTypeId                             = res.getRecordTypeInfosByName().get(RecordType).getRecordTypeId(); 
      List < Schema.ChildRelationship > lstChildRelationship  = res.getChildRelationships();

      // For each child relationship, get the details
      for (Schema.ChildRelationship objChildRelation: lstChildRelationship) {
        Schema.DescribeFieldResult childRelationName = objChildRelation.getField().getDescribe();
        SObjectType oChildType                       = objChildRelation.getChildSObject();
        String sObjectLabel                          = oChildType.getDescribe().getLabel();
        Schema.DescribeSObjectResult oDescription    = oChildType.getDescribe();

        Child_Object_Detail__C oChild                = new Child_Object_Detail__C();
        oChild.Sequence__c                           = ii;
        oChild.Process__c                            = true;
        oChild.Object_Name__c                        = String.valueOf(oChildType);
        oChild.Object_Label__c                       = sObjectLabel;
        oChild.Field_Label__c                        = childRelationName.getLabel();
        oChild.Relationship_Field__c                 = childRelationName.getLocalName();
        oChild.Relationship_Name__c                  = objChildRelation.getRelationshipName();
        oChild.Field_Relationship_Name__c            = childRelationName.getRelationshipName();
        oChild.Is_Queryable__c                       = oDescription.isQueryable();
        oChild.Total_Count_SOQL__c                   = 'select count(id) cnt from ' + oChild.Object_Name__c + ' where ' 
          + oChild.Relationship_Field__c + ' != \'\'';
        oChild.Field_Count_SOQL__c                   = 'select count(id) cnt from ' + oChild.Object_Name__c + ' where ' 
          + oChild.Field_Relationship_Name__c + '.recordtypeid = \'' + sAccountRecordTypeId  + '\'';
        oChild.Field_SOQL__c                         = 'select id from ' + oChild.Object_Name__c + ' where ' 
         + oChild.Field_Relationship_Name__c + '.recordtypeid = \'' + sAccountRecordTypeId  + '\' limit 1';

        System.debug(oChild);

        lstChilds.add(oChild);

        ii++;
      } // inner for loop

      try {
        insert(lstChilds);
      } catch (Exception e) {
        System.debug(' *** ' + e.getStackTraceString() + '\n' + e.getMessage());
      }
    } // outer for loop
  } // DisplayChildObjects

  private void ExecuteAnonymous () {
    /*
    FindChildObjects oCO = new FindChildObjects();      
    oCO.DeleteRecords();
    oCO.WriteChildRecords (new String[] { 'Account' }, 'External');

    // SOQL to export data to update Process__c & In_Scope__C
    select Id, Object_Name__c, Object_Label__c, Sequence__c, Count__c, Process__c, In_Scope__c, Is_Queryable__c, Total_Count__c, 
    Field_Count__c, Field__c , Total_Count_SOQL_Error__c, Field_Count_SOQL_Error__c, Field_SOQL_Error__c, Relationship_Field__c, 
    Field_Label__c, Relationship_Name__c, Field_Relationship_Name__c, Total_Count_SOQL__c, Field_Count_SOQL__c, Field_SOQL__c  
    from Child_Object_Detail__c order by Sequence__c

    select Sequence__c, Count__c, Object_Name__c, Relationship_Field__c, Is_Queryable__c, In_Scope__c, Process__c, 
    Relationship_Name__c, Field_Relationship_Name__c, Field_Count__c, Field__c from Child_Object_Detail__c
    where Is_Queryable__c = false
    */
  }
} // FindChildObjects