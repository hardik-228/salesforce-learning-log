public with sharing class HelloWorldController {
    @AuraEnabled(cacheable=true)
    public static String getGreeting() {
        return 'Hello from Apex Controller!';
    }
}
