@isTest
private class LeadBOTest {
  @TestSetup
  static void makeData() {
    Lead l = new Lead(
      FirstName = 'teste',
      LastName = 'teste',
      Company = 'teste',
      Status = 'Open - Not Contacted',
      CNPJ__c = '22.711.684/0001-72'
    );
    insert l;
  }

  @isTest
  static void createOrUpdateAccountByLeadStatusChangeTest() {
    List<Lead> leadsToUpdate = new List<Lead>();

    List<Lead> leads = [
      SELECT Id, Company, FirstName, LastName, Status
      FROM Lead
      WHERE LastName = 'teste'
    ];

    for (Lead l : leads) {
      l.Status = 'Working - Contacted';
      leadsToUpdate.add(l);
    }

    Test.startTest();
    update leadsToUpdate;
    Test.stopTest();

    Account acc = [SELECT Id FROM Account WHERE Name LIKE 'teste | 22.711.684/0001-72' LIMIT 1];

    if(acc != null) {
        System.assert(true);
    }else{
        System.assert(false);
    }
    
  }
}
