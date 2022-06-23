trigger LeadTrigger on Lead(after update) {
  if (Trigger.isAfter && Trigger.isUpdate) {
    LeadBO.getInstance().createOrUpdateAccountByLeadStatusChange(Trigger.new, Trigger.oldMap);
  }
}
