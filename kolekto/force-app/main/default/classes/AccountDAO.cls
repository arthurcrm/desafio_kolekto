public with sharing class AccountDAO {
  public static List<Account> getAccounts() {
    return [SELECT Id, Name, Phone, CreatedById, OwnerId FROM Account];
  }

  public static Account getAccountByCNPJ(String accountName) {
    return [
      SELECT
        Id,
        Name,
        Phone,
        CreatedById,
        OwnerId,
        (SELECT Id, FirstName, LastName, Phone FROM Contacts)
      FROM Account
      WHERE Name LIKE :accountName
      LIMIT 1
    ];
  }
}
