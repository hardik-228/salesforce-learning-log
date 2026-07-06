/* 
 * BEFORE API-67
 *  - Apex runs in System Mode (No Object and Field permission will be checked)
 * FROM API-67
 *  - Apex runs in User Mode (Object and Field permission will be checked), 
 *      but Record Level check still comes from SHARING_CLAUSE
 */
public without sharing class SEC_AccountService_CRUDFLS {

    // 1. No check at all — system mode ignores permissions, returns everything regardless of what the profile/permission set allows.
    @AuraEnabled
    public static List<Account> getAccountsNoCheck() {
        return [SELECT Name, AnnualRevenue, Industry FROM Account ORDER BY Name];
    }

    // 2. Manual object-level check. but not checking fields, not a best practice.
    @AuraEnabled
    public static List<Account> getAccountsObjectCheck() {
        if (!Schema.sObjectType.Account.isAccessible()) {
            return new List<Account>();
        }
        return [SELECT Name, AnnualRevenue, Industry FROM Account ORDER BY Name];
    }

    // 3. Manual field-level check — deliberately checks all fields.
    @AuraEnabled
    public static List<Account> getAccountsFieldCheck() {
        if (!Schema.sObjectType.Account.fields.Name.isAccessible() ||
            !Schema.sObjectType.Account.fields.Industry.isAccessible() ||
            !Schema.sObjectType.Account.fields.AnnualRevenue.isAccessible() 
        ) {
            return new List<Account>();
        }
        return [SELECT Name, AnnualRevenue, Industry FROM Account ORDER BY Name];
    }

    // 4. WITH SECURITY_ENFORCED — throws if ANY selected field is
    //    inaccessible. Enforces object AND field level. Does NOT enforce
    //    sharing (this class is without sharing, and that still holds).
    //    Legacy — Salesforce now recommends USER_MODE. Cannot be combined
    //    with aggregate functions like COUNT().
    //     You can't use this from API-67.0
    @AuraEnabled
    public static List<Account> getAccountsSecurityEnforced() {
        return [
            SELECT Name, AnnualRevenue, Industry
            FROM Account
            WITH SECURITY_ENFORCED
            ORDER BY Name
        ];
    }

    // 5. WITH USER_MODE — enforces object + field level AND record-level
    //    sharing, regardless of this class's own sharing declaration.
    //    This is the query that proves USER_MODE overrides the class-level
    //    keyword: even though this class is "without sharing", this one
    //    query still only returns shared records.
    @AuraEnabled
    public static List<Account> getAccountsUserMode() {
        return [
            SELECT Name, AnnualRevenue, Industry
            FROM Account
            WITH USER_MODE
            ORDER BY Name
        ];
    }

    // 6. Security.stripInaccessible — silent/graceful instead of throwing.
    //    Removes fields the user can't see rather than erroring out.
    @AuraEnabled
    public static List<Account> getAccountsStripInaccessible() {
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Name, AnnualRevenue, Industry FROM Account ORDER BY Name]
        );
        return decision.getRecords();
    }
}