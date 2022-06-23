public with sharing class AccountDAO {
  public static List<Account> getAccounts() {
    return [SELECT Id, Name, Phone, CreatedById, OwnerId FROM Account];
  }
}
