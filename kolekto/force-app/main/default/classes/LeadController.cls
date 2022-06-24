public with sharing class LeadController {
  @AuraEnabled
  public static ResponseTO getSavedData(Id leadId) {
    System.debug('Chamou');
    ResponseTO responseTO = new ResponseTO();
    try {
      responseTO = LeadBO.getInstance().getSavedData(leadId);
    } catch (DmlException e) {
      responseTO.error = true;
      responseTO.message = e.getDmlMessage(0);
    } catch (Exception e) {
      responseTO.error = true;
      responseTO.message = e.getMessage();
      responseTO.errorStackTrace = e.getStackTraceString();
    }
    return responseTO;
  }

  public class ResponseTO {
    @AuraEnabled
    public String message { get; set; }
    @AuraEnabled
    public String errorStackTrace { get; set; }
    @AuraEnabled
    public Boolean error { get; set; }
    @AuraEnabled
    public Boolean needsFieldFilled { get; set; }
    @AuraEnabled
    public String response { get; set; }
    @AuraEnabled
    public Lead leadObj { get; set; }
    @AuraEnabled
    public Account accObj { get; set; }
    @AuraEnabled
    public Contact ctObj { get; set; }

    public ResponseTO() {
      message = '';
      error = false;
      needsFieldFilled = false;
      leadObj = null;
      accObj = null;
      ctObj = null;
    }
  }
}
