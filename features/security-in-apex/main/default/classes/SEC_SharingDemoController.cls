/** 
 * BEFORE API-67
 *  - Apex runs in System Mode (No Object and Field permission will be checked)
 * FROM API-67
 *  - Apex runs in User Mode (Object and Field permission will be checked), 
 *      but Record Level check still comes from SHARING_CLAUSE
 */

/**
 * TOP LEVEL CLASS: No Keyword
 * 
 * BEFORE API 67.0: 
 *      - Inherit by the calling class
 *      - If Entry point
 *          -> works as WITH_SHARING if called from Lightning framework(Aura, LWC)
 *          -> all other places works as WITHOUT_SHARING
 * 
 * FROM API 67.0:
 *      - By default WITH_SHARING
 *      - if an Apex class without an explicit sharing declaration extends 
 *        from a parent class, it adopts the same sharing mode as the parent class
 * 
 */
public class SEC_SharingDemoController {

    // 1. Explicit WITH SHARING
    @AuraEnabled
    public static List<Account> runWithSharing() {
        return new WithSharingRunner().getAccounts();
    }

    // 2. Explicit WITHOUT SHARING
    @AuraEnabled
    public static List<Account> runWithoutSharing() {
        return new WithoutSharingRunner().getAccounts();
    }

    // 3. NO KEYWORD (Inherits calling class sharing) (current scenario WITH_SHARING)
    @AuraEnabled
    public static List<Account> runNoKeyword() {
        return new NoKeywordRunner().getAccounts();
    }

    // 4a. INHERITED SHARING (Called directly by top-level "with sharing" context)
    @AuraEnabled
    public static List<Account> runInheritedDirectly() {
        return new InheritedSharingRunner().getAccounts();
    }

    // 4b. INHERITED SHARING (Called via a "without sharing" wrapper)
    @AuraEnabled
    public static List<Account> runInheritedViaWrapper() {
        return new WithoutSharingWrapper().runInherited();
    }


    // ==========================================
    // INNER CLASSES (Where the context is defined)
    // ==========================================

    public with sharing class WithSharingRunner {
        public List<Account> getAccounts() {
            return [SELECT Id, Name, AnnualRevenue, Industry FROM Account ORDER BY Name];
        }
    }

    public without sharing class WithoutSharingRunner {
        public List<Account> getAccounts() {
            return [SELECT Id, Name, AnnualRevenue, Industry FROM Account ORDER BY Name];
        }
    }

    public class NoKeywordRunner {
        public List<Account> getAccounts() {
            return [SELECT Id, Name, AnnualRevenue, Industry FROM Account ORDER BY Name];
        }
    }

    public inherited sharing class InheritedSharingRunner {
        public List<Account> getAccounts() {
            return [SELECT Id, Name, AnnualRevenue, Industry FROM Account ORDER BY Name];
        }
    }

    // The Wrapper to demonstrate Inheritance shifting
    public without sharing class WithoutSharingWrapper {
        public List<Account> runInherited() {
            return new InheritedSharingRunner().getAccounts();
        }
    }
}