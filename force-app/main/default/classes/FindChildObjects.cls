public with sharing class FindChildObjects {

  // delete existing child object records
  public void deleteRecords () {
    List<Child_Object_Detail__c> lstCO = [SELECT Id FROM Child_Object_Detail__c];
    if (lstCO != null && lstCO.size() > 0) {
      delete lstCO;
    }
  }

  // get child objects and build SOQL into 2 maps (child+field, soql); one for counts, other for id's
  public void writeChildRecords (String[] types, String recordType) {

    Map < String, String > mapApp                     = new Map < String, String >();
    Map < String, Child_Object_Detail__c > mapChilds  = new Map < String, Child_Object_Detail__c >();
    List < Child_Object_Detail__C > lstChilds         = new List < Child_Object_Detail__C > ();

    Integer ii = 1;
    Integer jj = 1;
    String sAppName;
    String sObjName;
    Map <String, Set<String>> mapObjApp = new Map <String, Set<String>>();
    List <Schema.DescribeTabSetResult> tabSetDesc     = Schema.describeTabs();
    for (Schema.DescribeTabSetResult tsr : tabSetDesc) {
      System.debug('app ' + ii + ': ' + tsr.label);
        
      jj = 1;
      List <Schema.DescribeTabResult> tabDesc = tsr.getTabs();
      for (Schema.DescribeTabResult tr : tabDesc) {
        sObjName = tr.SObjectName;
        sAppName = tsr.label;

        if (mapObjApp.containsKey(sObjName)) {
          mapObjApp.get(sObjName).add(sAppName);
        } else {
          mapObjApp.put(sObjName, new Set<String>{sAppName});
        }

        System.debug('app ' + ii + ', obj ' + jj + ' map: ' + mapObjApp.toString());
        jj++;
      }
      ii++;
    }

    // Make the describe call for the inputs sObject types
    Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
    System.debug('Describe information for ' + types + ' :' + results);

    for (Schema.DescribeSobjectResult res: results) {
      ii                                                      = 1;
      String sAccountRecordTypeId                             = res.getRecordTypeInfosByName().get(recordType).getRecordTypeId(); 
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

        //System.debug(oChild);
        //mapChilds.put(ii + ':' + sObjectLabel, oChild);
        mapChilds.put(ii + ':' + oChild.Object_Name__c, oChild);

        ii++;
      } // inner for loop

      // loop thru map to populate App name and put it into a list
      for (String sName : mapChilds.keySet()) {
        sObjName                   = sName.split(':')[1];
        Set<String> setAppName     = mapObjApp.get(sObjName);
        sAppName                   = String.join(new List<String>(setAppName), ',');

        System.debug('sObjName: ' + sObjName + '; sAppName: ' + sAppName);

        Child_Object_Detail__c oCO = mapChilds.get(sName); 
        if (oCO != null) {
          oCO.App_Name__c            = sAppName; 
          lstChilds.add(oCO);
          System.debug(oCO.Sequence__c + ': ' + oCO);
        }
      }

      try {
        if (lstChilds != null) {
          insert(lstChilds);
        }
      } catch (Exception e) {
        System.debug(' *** ' + e.getStackTraceString() + '\n' + e.getMessage());
      }
    } // outer for loop
  } // DisplayChildObjects

  private void executeAnonymous () {
    /*
    FindChildObjects oCO = new FindChildObjects();      
    oCO.deleteRecords();
    oCO.writeChildRecords (new String[] { 'Account' }, 'External');

    // SOQL to export data to update Process__c & In_Scope__C
    select Id, Object_Name__c, Object_Label__c, App_Name__c, Sequence__c, Count__c, Process__c, In_Scope__c, Is_Queryable__c, Total_Count__c, 
    Field_Count__c, Field__c , Total_Count_SOQL_Error__c, Field_Count_SOQL_Error__c, Field_SOQL_Error__c, Relationship_Field__c, 
    Field_Label__c, Relationship_Name__c, Field_Relationship_Name__c, Total_Count_SOQL__c, Field_Count_SOQL__c, Field_SOQL__c  
    from Child_Object_Detail__c order by Sequence__c

    select Sequence__c, Count__c, Object_Name__c, App_Name__c, Relationship_Field__c, Is_Queryable__c, In_Scope__c, Process__c, 
    Relationship_Name__c, Field_Relationship_Name__c, Field_Count__c, Field__c from Child_Object_Detail__c
    where Is_Queryable__c = false
    */
  }
} // FindChildObjects