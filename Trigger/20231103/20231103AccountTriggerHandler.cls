public class AccountTriggerHandler {
    public static void AddRelatedRecord(List<Account> accList){
    List<Opportunity> oppList = new List<Opportunity>();
    // Get the related opportunities for the accounts in this trigger
    Map<Id,Account> acctsWithOpps = new Map<Id,Account>(
       [SELECT Id,(SELECT Id FROM Opportunities) FROM Account WHERE Id IN :accList]);
    // Add an opportunity for each account if it doesn't already have one.
    // Iterate through each account.
    for(Account a : accList) {
        System.debug('acctsWithOpps.get(a.Id).Opportunities.size()=' + acctsWithOpps.get(a.Id).Opportunities.size());
        // Check if the account already has a related opportunity.
        if (acctsWithOpps.get(a.Id).Opportunities.size() == 0) {
            // If it doesn't, add a default opportunity
            oppList.add(new Opportunity(Name=a.Name + ' Opportunity',
                                       StageName='Prospecting',
                                       CloseDate=System.today().addMonths(1),
                                       AccountId=a.Id));
        }           
    }
    if (oppList.size() > 0) {
        insert oppList;
    }
    }
    public static void AccountDeletion(List<Account> accList){
    // Prevent the deletion of accounts if they have related opportunities.
    for (Account a : [SELECT Id FROM Account
                     WHERE Id IN (SELECT AccountId FROM Opportunity) AND
                     Id IN :Trigger.old]) {
        Trigger.oldMap.get(a.Id).addError(
            'Cannot delete account with related opportunities. I wrote this error with trigger.');
    }
}
}