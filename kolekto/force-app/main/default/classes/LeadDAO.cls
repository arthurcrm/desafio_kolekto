public with sharing class LeadDAO {
  public static Lead selectLeadById(Id leadId) {
    return [SELECT Id, CNPJ__c, Company FROM Lead WHERE Id = :leadId];
  }
}
