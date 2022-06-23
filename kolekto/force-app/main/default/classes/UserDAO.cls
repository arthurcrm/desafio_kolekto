public with sharing class UserDAO {
  public static List<User> getUsers() {
    return [SELECT Id, Name, Email, Phone FROM User];
  }
}
