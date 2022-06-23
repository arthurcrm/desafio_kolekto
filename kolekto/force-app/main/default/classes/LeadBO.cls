public with sharing class LeadBO {
  private class CustomException extends Exception {
  }

  private static LeadBO instance = new LeadBO();
  public static LeadBO getInstance() {
    return instance;
  }

  public void createOrUpdateAccountByLeadStatusChange(
    List<Lead> lstLead,
    Map<Id, Lead> mapOldLead
  ) {
    List<Lead> lstLeadsToUpdate = new List<Lead>();
    List<Contact> lstContactsToUpdate = new List<Contact>();
    List<Account> lstAccountsToUpdateOrCreate = new List<Account>();

    List<Account> accounts = AccountDAO.getAccounts();
    List<User> users = UserDAO.getUsers();

    Map<Id, User> mapUserByAccountId = new Map<Id, User>();
    Set<Account> setAccounts = new Set<Account>();
    Map<Id, Lead> mapLeadByCt = new Map<Id, Lead>();

    for (Lead leadItem : lstLead) {
      if (
        mapOldLead != null &&
        mapOldLead.get(leadItem.Id).Status == 'Open - Not Contacted' &&
        leadItem.Status.equals('Working - Contacted') &&
        leadItem.CNPJ__c != null
      ) {
        String accountName = leadItem.Company + ' | ' + leadItem.CNPJ__c;

        for (Account acc : accounts) {
          setAccounts.add(acc);
        }

        if (leadItem.Company == null) {
          leadItem.Company = 'No Company';
        }

        for (Account acc : setAccounts) {
          if (acc.Name.equals(accountName)) {
            lstAccountsToUpdateOrCreate.add(acc);
          }
        }

        if (lstAccountsToUpdateOrCreate.isEmpty()) {
          Account newAccount = new Account(Name = accountName, OwnerId = UserInfo.getUserId());
          lstAccountsToUpdateOrCreate.add(newAccount);
          insert newAccount;
        }

        Set<User> setUsers = new Set<User>();

        for (Account acc : lstAccountsToUpdateOrCreate) {
          for (User u : users) {
            if (acc.OwnerId == u.Id) {
              mapUserByAccountId.put(acc.Id, u);
              acc.Phone = u.Phone;
              continue;
            }
          }
        }

        for (User u : mapUserByAccountId.values()) {
          setUsers.add(u);
        }

        for (Id accountId : mapUserByAccountId.keySet()) {
          for (User u : setUsers) {
            String firstName = u.Name.substringBefore(' ');
            String lastName = u.Name.substringAfter(' ');
            Contact ct = new Contact(
              FirstName = firstName,
              LastName = lastName,
              Email = u.Email,
              Phone = u.Phone,
              AccountId = accountId
            );
            lstContactsToUpdate.add(ct);
            mapLeadByCt.put(ct.Id, leadItem);
          }
        }
      }
    }

    if (
      !lstAccountsToUpdateOrCreate.isEmpty() && !lstContactsToUpdate.isEmpty()
    ) {
      upsert lstContactsToUpdate;
      update lstAccountsToUpdateOrCreate;

      for (Contact ct : lstContactsToUpdate) {
          if(mapLeadByCt.containsKey(ct.Id)){
              Lead l = mapLeadByCt.get(ct.Id);
              l.Contact__c = ct.Id;
              lstLeadsToUpdate.add(l);
          }
      }

      if(!lstLeadsToUpdate.isEmpty()){
          update lstLeadsToUpdate;
      }
    }
  }
}
