/*============================================================
 * Apex Code Patrol, 2011
 *
 * http://code.google.com/p/apex-code-patrol/
 *
 * Code is licensed under "New BSD License".
 *============================================================
 */
/**
 * ApexCodePatrol
 * allows you to control the execution of your classes, triggers, groups or even single methods,
 * by setting execution limits or simply disabling the code on the fly. Additionally 
 */
global class ApexCodePatrol {
	
    
    static Map<String,Ponch> officers;
	
    /**
     *============================================================
     * GLOBAL FLAGS / CONTEXT
     *
     * eval Pages, Triggers, Tests and Async
     *============================================================
     */

     // VISUALFORCE CONTEXT
    global static Boolean isPage(){
    	return ApexPages.currentPage() != null;
    }

     // TRIGGER CONTEXT
    global static Boolean isTrigger(){
    	return Trigger.isExecuting;
    }

     // TEST CONTEXT
    global static Boolean isTest(){
    	return Test.isRunningTest();
    }

     // ASYNC CONTEXT
    /**
     * True if we haven't reached the futures limit
     */
    global static Boolean allowFutureCall(){
    	return remainingFutureCalls() > 0;
    }
    /**
     * Diff. between LimitFutureCalls and acutall number of calls made
     */
    global static Integer remainingFutureCalls(){
    	return Limits.getLimitFutureCalls() - Limits.getFutureCalls();
    }

    /**
     *============================================================
     * EXECUTION CONTROL
     *============================================================
     */

    /**
     * Register code and the max. executions
     */
    global static void register(String key, Integer numberOfExecutions){
        getOfficer(key,numberOfExecutions);
    }

    /**
     * Returns true if you can execute your code and increments the execution counter.
     * To simplly eval if you can execute a certain code use canExecute() method instead
     */
    global static Boolean execute(String key, Integer maxExecutions){
        Ponch off = getOfficer(key,maxExecutions);
        // reset the limit's when executed in testMode for the first time
        if(off.isTestMode() && off.getCounter() == 0){
            off.resetLimits(maxExecutions);
        }
        return getOfficer(key,maxExecutions).execute();
    }

    /**
     * sames as above, but sets number of executions 1 one 
     */
    global static Boolean execute(String key){
        return execute(key,1);
    }

    /** 
     * Start and stop tests for parts of your code, to evaluate testMode use isTest(String)
     * for a sample see inlcuded unitTests
     * In general you should use system.isRunningTest() or isTest()
     */
    global static void startTest(String key){
        getOfficer(key,0).setTestMode(true);
    }

    global static void stopTest(String key){
        getOfficer(key,0).setTestMode(false);
    }

    /**
     * Disable code for execution
     */
    global static void disable(String key){
        getOfficer(key).setDisabled(true);
    }

    /**
     * Enable code for execution
     */
    global static void enable(String key){
        getOfficer(key).setDisabled(false);
    }

    /**
     *============================================================
     * COUNTER AND LIMITS
     *============================================================
     */
    /** 
     * Return the number of executions of a code
     */
    global static Integer getCounter(String key){
        return getOfficer(key).getCounter();
    }

    /** 
     * Returns the execution limit of a code
     */
    global static Integer getLimit(String key){
        return getOfficer(key).getLimit();
    }

    /**
     * Sets the counter for code matching the key param to 0 and overwrites the limits
     */
    global static void resetLimits(String key, Integer maxExecutions){
        getOfficer(key).resetLimits(maxExecutions);
    }


    /**
     *============================================================
     * CONCRETE FLAGS
     *============================================================
     */
    /**
     * Evals if a code can be executed
     */
    global static Boolean canExecute(String key){
       return getOfficer(key).canExecute();
    }
    /**
     * Evals if execution is blocked by any code which key is contained in keys set param
     */
    global static Boolean canExecute(Set<String> keys){
    	
        for(String key : keys){
            if(isRegistered(key) && !canExecute(key))
                return false;
        }
        return true;
    }
    /**
     * True if code has been disabled
     */
    global static Boolean isDisabled(String key){
        return getOfficer(key).isDisabled();
    }
    
    /**
     * True if startTest(String) has been called
     */
    global static Boolean isTest(String key){
       return getOfficer(key).isTestMode();
    }
    /**
     * Evals if there's an officer keep track of the code
     */
    global static Boolean isRegistered(String key){
       return getOfficers().containsKey(key);
    }


    /**
     *============================================================
     * HELPER UTILS
     *============================================================
     */
    private static Map<String,Ponch> getOfficers(){
        if(officers == null){
            officers = new Map<String,Ponch>();
        }
        return officers;
    }

    /**
     * Returns an the officer matching key, if it does not exist an new one is created
     */
    private static Ponch getOfficer(String key){
        return getOfficer(key,1);
    }

    private static Ponch getOfficer(String key, Integer maxExecutions){
        
        if(!isRegistered(key)){
            officers.put(key,new Ponch(key,maxExecutions));	
        }
        return getOfficers().get(key);
    }


    /**
     * THE OFFICER
     *
     * Every code controlled by the ApexCodePatrol has its personal Erik,
     * who knows their names and ensures that they stay within their limits. 
     */
    public class Ponch {

        String name;

        Integer exeLimit;
        Integer exeCounter; 
		
        // FLAGS
        Boolean inTestMode;
        Boolean disabled;

        /**
         * Class constructor, defines the name and max. number of executions
         */
        public Ponch(String Pname, Integer maxExecutions){
            name = Pname;
            resetLimits(maxExecutions);
            inTestMode = false;
            disabled = false;
        }

        /**
         * set the inTestMode flag
         */
        public void setTestMode(Boolean testMode){
            inTestMode = testMode;
        }

        public Boolean isTestMode(){
            return inTestMode;
        }

        /**
         * Disable / enable the code
         */
        public void setDisabled(Boolean disable){
            disabled = disable;
        }
        /**
         * True if code has been disabled
         */
        public Boolean isDisabled(){
            return disabled;
        }

        /** 
         * The number of time execute() has been called
         */
        public Integer getCounter(){
            return exeCounter < exeLimit ? exeCounter : exeLimit;
        }

        /**
         * Maximum number of executions for the code
         */
        public Integer getLimit(){
            return exeLimit;
        }

        /**
         * Call the overwrite the Limit and to set the counter to 0
         */
        public void resetLimits(Integer maxExecutions){
            exeLimit = maxExecutions;
            exeCounter = 0;
        }


        /**
         * Evals if the code can be executed
         */
        public Boolean canExecute(){
            return (exeLimit > exeCounter || exeLimit == 0 && inTestMode) && !disabled;
        }

        /** 
         * Returns true if the code can be executed and increments the counter
         */
        public Boolean execute(){
            if(!canExecute()) return false;

            exeCounter++;
            return true;
        }
    }

    /**
     * INLINE TESTS
     * 
     * Included in class to make it easy to extend with functionallity. I suggest to export to dedicated test class 
     * before deploying to production
     */
    private static testMethod void testCore(){
        // imaginary code names
        string cls1 = 'AccountHierarchy';
        string mtd1 = 'AccountHierarchy.build()';
        string trg1 = 'AccountTriggerBefore'; 

        // GLOBAL FLAGS

        // system.assertEquals(false,ApexCodePatrol.isPage()); --> fails
        // isPage() not necessarily false, even when running the test in IDE it evals to true 
        // verfied that it worked via trigger and api
        // system.debug(ApexPages.currentPage()) prints out==> System.PageReference[null]; 
        system.assertEquals(ApexPages.currentPage() != null,ApexCodePatrol.isPage());
        system.assertEquals(false,ApexCodePatrol.isTrigger());
        system.assertEquals(true,ApexCodePatrol.isTest());

        // ACP Tests
        ApexCodePatrol.startTest(cls1);
        system.assertEquals(true, ApexCodePatrol.isTest(cls1));
        system.assertEquals(true, ApexCodePatrol.isRegistered(cls1));

        // since it hasn't been executed the class should be executable able at least once
        system.assertEquals(true, ApexCodePatrol.canExecute(cls1));

        // same goes for sets
        system.assertEquals(true, ApexCodePatrol.canExecute(new Set<String>{cls1,'no_block'}));

        // DISABLE TRIGGER
        // before executing the class, disable the account trigger,in order to perform a dml operation
        // that causes a recrusive trigger
        ApexCodePatrol.disable(trg1);
        system.assertNotEquals(true, ApexCodePatrol.canExecute(new Set<String>{trg1,'no_block'}));
        system.assertEquals(false, ApexCodePatrol.execute(trg1));
        system.assertEquals(true, ApexCodePatrol.isDisabled(trg1));
        system.assertEquals(0, ApexCodePatrol.getCounter(trg1));

        // EXECUTE CLASS
        // Excute the class for the first time
        system.assertEquals(true, ApexCodePatrol.execute(cls1));
        system.debug('\n**counter=' + ApexCodePatrol.getCounter(cls1) + '\n limit' + ApexCodePatrol.getLimit(cls1));
        // at the second attempt it's false because no MaxExecutions has been defined
        system.assertEquals(false, ApexCodePatrol.canExecute(cls1));
        system.assertEquals(ApexCodePatrol.getCounter(cls1),ApexCodePatrol.getLimit(cls1));

        // to build the hierarchy, buildMethod needs to be executed 10, times
        // in order to reach 100% test coverage use register instead of inline defintion
        ApexCodePatrol.register(mtd1, 10);		
        for(integer i = 0; i<10;i++){
            system.assertEquals(true, ApexCodePatrol.execute(mtd1));
        }
        system.assertEquals(false, ApexCodePatrol.canExecute(mtd1));
        // reset the limit for the method to 1
        ApexCodePatrol.resetLimits(mtd1, 1);
        system.assertEquals(true, ApexCodePatrol.canExecute(mtd1));
        
        // ENABLE & EXECUTE TRIGGER
        ApexCodePatrol.enable(trg1);
        system.assertEquals(false,ApexCodePatrol.isDisabled(trg1));
        system.assertEquals(true,ApexCodePatrol.execute(trg1));
        
        // Finsh the Test
        ApexCodePatrol.stopTest(cls1);
        system.assertEquals(false,ApexCodePatrol.isTest(cls1));
    }
}