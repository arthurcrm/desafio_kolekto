@isTest
private class LeadControllerTest {
  @TestSetup
  static void makeData() {
    Account acc = new Account(Name = 'teste | 33.100.552/0001-20');
    insert acc;

    Contact ct = new Contact(
      FirstName = UserInfo.getFirstName(),
      LastName = UserInfo.getLastName(),
      Email = UserInfo.getUserEmail(),
      AccountId = acc.Id
    );
    insert ct;

    Lead l = new Lead(
      FirstName = 'teste',
      LastName = 'teste',
      Company = 'teste',
      Status = 'Open - Not Contacted',
      CNPJ__c = '33.100.552/0001-20'
    );
    insert l;
  }

  @isTest
  static void getSavedDataTest() {
    Lead l = [SELECT Id FROM Lead WHERE LastName = 'teste' LIMIT 1];
    Test.startTest();
    LeadController.ResponseTO to = LeadController.getSavedData(l.Id);
    Test.stopTest();

    if (to.error == true) {
      System.assert(false);
    } else {
      System.assert(true);
    }
  }
}
