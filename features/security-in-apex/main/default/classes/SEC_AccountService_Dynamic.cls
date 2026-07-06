/* 
 * BEFORE API-67
 *  - Apex runs in System Mode (No Object and Field permission will be checked)
 * FROM API-67
 *  - Apex runs in User Mode (Object and Field permission will be checked), 
 *      but Record Level check still comes from SHARING_CLAUSE
 */

public without sharing class SEC_AccountService_Dynamic {

    // BAD — string concatenation, directly exploitable.
    // Try term = ' OR Name != '
    // Query will become: WHERE Name LIKE '%' OR Name != '%' ORDER BY Name
    @AuraEnabled
    public static List<Account> searchInjectable(String term) {
        String clause = '\'%' + term + '%\'';
        return (List<Account>) Database.query(
            'SELECT Name, AnnualRevenue, Industry FROM Account WHERE Name LIKE ' + clause + ' ORDER BY Name'
        );
    }

    // GOOD — bind variable inside a dynamic query string.
    @AuraEnabled
    public static List<Account> searchBindVariable(String term) {
        String likeTerm = '%' + term + '%';
        return (List<Account>) Database.query(
            'SELECT Name, AnnualRevenue, Industry FROM Account WHERE Name LIKE :likeTerm ORDER BY Name'
        );
    }

    // GOOD — escapeSingleQuotes when you truly must concatenate.
    // Query will become: WHERE Name LIKE '%\' OR Name != \'%' ORDER BY Name
    @AuraEnabled
    public static List<Account> searchEscaped(String term) {
        String clause = '\'%' + String.escapeSingleQuotes(term) + '%\'';
        return (List<Account>) Database.query(
            'SELECT Name, AnnualRevenue, Industry FROM Account WHERE Name LIKE ' + clause + ' ORDER BY Name'
        );
    }

    // Dynamic SOQL with AccessLevel.USER_MODE — CRUD/FLS/sharing enforced
    // on a dynamically built query, in addition to safe binding.
    @AuraEnabled
    public static List<Account> searchUserMode(String term) {
        String likeTerm = '%' + term + '%';
        return (List<Account>) Database.query(
            'SELECT Name, AnnualRevenue, Industry FROM Account WHERE Name LIKE :likeTerm ORDER BY Name',
            AccessLevel.USER_MODE
        );
    }

    // SOSL with AccessLevel.USER_MODE.
    @AuraEnabled
    public static List<Account> searchSoslUserMode(String term) {
        List<List<SObject>> results = Search.query(
            'FIND :term IN Name FIELDS RETURNING Account(Name, AnnualRevenue, Industry)',
            AccessLevel.USER_MODE
        );
        return (List<Account>) results[0];
    }
}