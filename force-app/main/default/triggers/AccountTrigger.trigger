trigger AccountTrigger on Account (before insert, before update, before delete) {
    
    // dis-associate related contact records from account record upon it's deletion
    if (Trigger.isBefore && Trigger.isDelete) {
        List<Contact> lstContacts = [SELECT Id FROM Contact WHERE AccountID IN : Trigger.OldMap.keyset() limit 10000];
        
        if (! lstContacts.isEmpty()) {
            for (Contact con : lstContacts) {
                con.AccountId = null;
            }
            
            // commit changes
            update lstContacts;
        }
    }
    
    // duplicate record check based on Account Name
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        
        Set<String> setAccountNames = new Set<String>();
        for (Account acc : Trigger.New) {
            if (acc.Name != null && acc.Name != '') {
                setAccountNames.add(acc.Name);
            }
        }
        System.debug('New Account Names: ' + setAccountNames);
        
        List<Account> lstAccounts    = [SELECT Id, Name FROM Account WHERE Name in : setAccountNames];
        System.debug('Account List: ' + lstAccounts);
        
        setAccountNames.clear() ;
        for (Account acc : lstAccounts) {
            setAccountNames.add(acc.Name);
        }
        
        for (Account acc : Trigger.New) {
            System.debug('setAccountNames contains ' + setAccountNames.contains(acc.Name));
            if ((acc.Name != null && acc.Name != '') && (setAccountNames.contains(acc.Name))) {
                System.debug('Account \'' + acc.Name + '\' already exists, please give a unique name');
                
                acc.Name.addError('Account \'' + acc.Name + '\' already exists, please give a unique name');
            }
        }
    }
}