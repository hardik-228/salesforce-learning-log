/* 
 * BEFORE API-67
 *  - Apex runs in System Mode (No Object and Field permission will be checked)
 * FROM API-67
 *  - Apex runs in User Mode (Object and Field permission will be checked), 
 *      but Record Level check still comes from SHARING_CLAUSE
 */

public without sharing class SEC_AccountService_DML {

    // 1. No check at all — system mode ignores object/field permissions.
    //    Succeeds regardless of what the profile/permission set allows.
    @AuraEnabled
    public static String updateAccountNoCheck(Id acctId, String newName, Decimal annualRev) {
        Account acct = new Account(Id = acctId);
        if (String.isNotBlank(newName)) acct.Name = newName;
        if (annualRev != null) acct.AnnualRevenue = annualRev;
        update acct;
        return 'SUCCESS: updated with no permission check performed at all.';
    }

    // 2. Manual field-level check before DML.
    @AuraEnabled
    public static String updateAccountFieldCheck(Id acctId, String newName, Decimal annualRev) {
        if (String.isNotBlank(newName) && !Schema.sObjectType.Account.fields.Name.isUpdateable()) {
            throw new DMLException('BLOCKED: no field-level access to update Name.');
        }
        if (annualRev != null && !Schema.sObjectType.Account.fields.AnnualRevenue.isUpdateable()) {
            throw new DMLException('BLOCKED: no field-level access to update Annual Revenue.');
        }
        Account acct = new Account(Id = acctId);
        if (String.isNotBlank(newName)) acct.Name = newName;
        if (annualRev != null) acct.AnnualRevenue = annualRev;
        update acct;
        return 'SUCCESS: field-level check passed, fields updated.';
    }

    // 3. Manual object-level check before DML.
    @AuraEnabled
    public static String updateAccountObjectCheck(Id acctId, String newName, Decimal annualRev) {
        if (!Schema.sObjectType.Account.isUpdateable()) {
            throw new DMLException('BLOCKED: no object-level access to update Account.');
        }
        Account acct = new Account(Id = acctId);
        if (String.isNotBlank(newName)) acct.Name = newName;
        if (annualRev != null) acct.AnnualRevenue = annualRev;
        update acct;
        return 'SUCCESS: object-level check passed, fields updated.';
    }

    // 4. `as user` — enforces object + field + sharing in one line,
    //    regardless of this class's own (without sharing) declaration.
    @AuraEnabled
    public static String updateAccountAsUser(Id acctId, String newName, Decimal annualRev) {
        Account acct = new Account(Id = acctId);
        if (String.isNotBlank(newName)) acct.Name = newName;
        if (annualRev != null) acct.AnnualRevenue = annualRev;
        update as user acct;
        return 'SUCCESS: updated using "as user" (full user-mode enforcement).';
    }

    // 5. Database.update with AccessLevel.USER_MODE — salesforces object + field + sharing in one line,
    //    but returns a SaveResult instead of throwing.
    @AuraEnabled
    public static String updateAccountUserModeDb(Id acctId, String newName, Decimal annualRev) {
        Account acct = new Account(Id = acctId);
        if (String.isNotBlank(newName)) acct.Name = newName;
        if (annualRev != null) acct.AnnualRevenue = annualRev;
        
        Database.SaveResult sr = Database.update(
            acct,
            AccessLevel.USER_MODE
        );
        if (sr.isSuccess()) {
            return 'SUCCESS: Database.update with AccessLevel.USER_MODE.';
        }
        List<String> errs = new List<String>();
        for (Database.Error e : sr.getErrors()) {
            errs.add(e.getStatusCode() + ': ' + e.getMessage());
        }
        return 'BLOCKED (returned as a failed result, not thrown): ' + String.join(errs, '; ');
    }

    // 6. stripInaccessible on the way in — silently drops fields the
    //    user can't write instead of failing the whole DML.
    @AuraEnabled
    public static String updateAccountStripInaccessible(Id acctId, String newName, Decimal annualRev) {
        Account acct = new Account(Id = acctId);
        if (String.isNotBlank(newName)) acct.Name = newName;
        if (annualRev != null) acct.AnnualRevenue = annualRev;
        
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.UPDATABLE,
            new List<Account>{ acct }
        );
        update decision.getRecords();
        return 'SUCCESS (silently stripped any inaccessible fields, then updated).';
    }

    @AuraEnabled
    public static List<Account> getAccounts() {
        return [SELECT Name, AnnualRevenue FROM Account ORDER BY Name LIMIT 10];
    }
}