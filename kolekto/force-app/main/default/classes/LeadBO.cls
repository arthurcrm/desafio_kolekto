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
          if (acc.Name.contains(leadItem.CNPJ__c)) {
            acc.Name = accountName;
            lstAccountsToUpdateOrCreate.add(acc);
          }
        }

        if (lstAccountsToUpdateOrCreate.isEmpty()) {
          Account newAccount = new Account(
            Name = accountName,
            OwnerId = UserInfo.getUserId()
          );
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
            Contact oldCt;
            try {
              oldCt = [SELECT Id FROM Contact WHERE Email = :u.Email LIMIT 1];
            } catch (Exception e) {
              if (e != null) {
                Contact ct = new Contact(
                  FirstName = firstName,
                  LastName = lastName,
                  Email = u.Email,
                  Phone = u.Phone,
                  AccountId = accountId
                );
                lstContactsToUpdate.add(ct);
                leadItem.Contact__c = ct.Id;
                mapLeadByCt.put(ct.Id, leadItem);
                System.debug('mapLEadbyCt' + mapLeadByCt);
              }
            }

            if (oldCt != null) {
              oldCt.FirstName = firstName;
              oldCt.LastName = lastName;
              oldCt.Email = u.Email;
              oldCt.Phone = u.Phone;
              oldCt.AccountId = accountId;
              lstContactsToUpdate.add(oldCt);
            }
          }
        }
      }
      lstLeadsToUpdate.add(leadItem);
    }

    if (!lstAccountsToUpdateOrCreate.isEmpty()) {
      upsert lstContactsToUpdate;
      update lstAccountsToUpdateOrCreate;

      if (!lstLeadsToUpdate.isEmpty()) {
        update lstLeadsToUpdate;
      }
    }
  }
}
