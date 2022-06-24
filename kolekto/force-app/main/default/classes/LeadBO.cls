public with sharing class LeadBO {
  private class CustomException extends Exception {
  }

  private static LeadBO instance = new LeadBO();
  public static LeadBO getInstance() {
    return instance;
  }

  public LeadController.ResponseTO getSavedData(Id leadId) {
    LeadController.ResponseTO to = new LeadController.ResponseTO();
    try {
      Lead l = LeadDAO.selectLeadById(leadId);
      String accountName = l.Company + ' | ' + l.CNPJ__c;
      Account acc = AccountDAO.getAccountByCNPJ(accountName);
      if (l != null && acc != null) {
        to.leadObj = l;
        to.accObj = acc;
        to.ctObj = acc.Contacts;
        to.error = false;
      }
    } catch (DmlException e) {
      to.error = true;
      to.message = e.getDmlMessage(0);
    } catch (Exception e) {
      to.error = true;
      to.message = e.getMessage();
      to.errorStackTrace = e.getStackTraceString();
    }

    return to;
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
              Contact ct = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = u.Email,
                Phone = u.Phone,
                AccountId = accountId
              );

              lstContactsToUpdate.add(ct);
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
    }

    if (!lstAccountsToUpdateOrCreate.isEmpty()) {
      upsert lstContactsToUpdate;
      update lstAccountsToUpdateOrCreate;
    }
  }
}
