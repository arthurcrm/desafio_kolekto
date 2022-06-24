import { LightningElement, track, api } from "lwc";
import getSavedData from "@salesforce/apex/LeadController.getSavedData";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class LeadDetailComponent extends LightningElement {
  @api recordId;

  @track errorMessage = "";
  @track error = false;
  @track contacts = [];
  @track accountName = "";
  @track accountId = "";

  showToast(title, variant, message) {
    const event = new ShowToastEvent({
      title: title,
      variant: variant,
      message: message
    });
    this.dispatchEvent(event);
  }

  async load() {
    getSavedData({
      leadId: this.recordId
    })
      .then((data) => {
        console.log("DATA :: ", data);
        if (data) {
          if (data.error) {
            console.log("Error ", data.message);
            console.log("Error ", data.errorStackTrace);
            this.errorMessage = data.message;
            this.error = data.error;
          } else {
            const { accObj } = data;
            this.accountName = accObj.Name;
            this.accountId = accObj.Id;

            this.contacts = accObj.Contacts;
          }
        } else {
          this.error = true;
        }
      })
      .catch((error) => {
        console.log("error ", error);
        console.log("Error received: code", error);
        this.errorMessage = error;
        this.error = true;
      });
  }
}
