/**
 * Copyright (c) 2011, Sebastian Wagner <sbw*DOT*dev[at]gmail_com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/
/**
 * ApexCodePatrol
 * allows you to control the execution of your classes, triggers, groups or even single methods,
 * by setting execution limits or simply disabling the code on the fly.
 */
public class ApexCodePatrol {
	
	static Map<String,Ponch> officers;
	
	/**
	 * CONTROLLING EXECUTION
	 */
	 
	/**
	 * Register code and the max. executions
	 */
	public static void register(String key, Integer numberOfExecutions)
	{
		getOfficer(key,numberOfExecutions);
	}

	/**
	 * Returns true if you can execute your code and increments the execution counter
	 * to simple eval if you can execute a certain code use canExecute() method
	 */
	public static Boolean execute(String key, Integer maxExecutions)
	{
		Ponch off = getOfficer(key,maxExecutions);
		// reset the limit's when executed in testMode for the first time
		if(off.isTest() && off.getCounter() == 0)
		{
			off.resetLimits(maxExecutions);
		}
		return getOfficer(key,maxExecutions).execute();
	}

	/**
	 * sames as above, about defaults to 1 execution 
	 */
	public static Boolean execute(String key)
	{
		return execute(key,1);
	}

	/** 
	 * Use when you need parts of your code to behave different when executed in a test
	 * in general you should use system.isRunningTest()
	 */
	public static void startTest(String key){
		getOfficer(key,0).setIsTest(true);
	}

	public static void stopTest(String key){
		getOfficer(key,0).setIsTest(false);
	}

	/**
	 * Disable code for execution
	 */
	public static void disable(String key)
	{
		getOfficer(key).setDisabled(true);
	}

	/**
	 * Enable code for execution
	 */
	public static void enable(String key)
	{
		getOfficer(key).setDisabled(false);
	}

	/**
	 * COUNTER AND LIMITS
	 */
	/** 
	 * Return the Number of Executions of a code
	 */
	public static Integer getCounter(String key){
		return getOfficer(key).getCounter();
	}

	/** 
	 * Returns the Execution Limit of a code
	 */
	public static Integer getLimit(String key){
		return getOfficer(key).getLimit();
	}

	/**
	 * Sets the counter for code matching the key param to 0 and overwrites the limits
	 */
	public static void resetLimits(String key, Integer maxExecutions)
	{
		getOfficer(key).resetLimits(maxExecutions);
	}


	/**
	 * FLAGS
	 */
	/**
	 * Evals if a code can be executed
	 */
	public static Boolean canExecute(String key)
	{
		return getOfficer(key).canExecute();
	}
	/**
	 * True if code has been disabled
	 */
	public static Boolean isDisabled(String key)
	{
		return getOfficer(key).isDisabled();
	}
	/**
	 * Evals if the code is executed in test mode
	 */
	public static Boolean isTest(String key)
	{
		return getOfficer(key).isTest();
	}
	/**
	 * Evals if there's an officer keep track of the code
	 */
	public static Boolean isRegistered(String key)
	{
		return getOfficers().containsKey(key);
	}


	/**
	 * HELPER UTILS
	 */
	private static Map<String,Ponch> getOfficers()
	{
		if(officers == null)
		{
			officers = new Map<String,Ponch>();
		}
		return officers;
	}

	/**
	 * Returns an the officer matching key, if it does not exist an new one is created
	 */
	private static Ponch getOfficer(String key)
	{
		return getOfficer(key,1);
	}
	private static Ponch getOfficer(String key, Integer maxExecutions)
	{
		if(!isRegistered(key)){
			officers.put(key,new Ponch(key,maxExecutions));	
		}
		return getOfficers().get(key);
	}


	/**
	 * THE OFFICER
	 *
	 * Every code controlled by the ApexCodePatrol has its personal Erik
	 * who know's their names and ensures that they stay within their limits. 
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
		public Ponch(String Pname, Integer maxExecutions)
		{
			name = Pname;
			resetLimits(maxExecutions);
			inTestMode = false;
			disabled = false;
		}
		
		/**
		 * set the inTestMode flag
		 */
		public void setIsTest(Boolean testMode)
		{
			inTestMode = testMode;
		}
		
		public Boolean isTest(){
			return inTestMode;
		}
		
		/**
		 * Disable / enable the code
		 */
		public void setDisabled(Boolean disable)
		{
			disabled = disable;
		}
		/**
		 * True if code has been disabled
		 */
		public Boolean isDisabled()
		{
			return disabled;
		}
		
		/** 
		 * The number of time execute() has been called
		 */
		public Integer getCounter()
		{
			return exeCounter < exeLimit ? exeCounter : exeLimit;
		}
		
		/**
		 * Maximum number of executions for the code
		 */
		public Integer getLimit()
		{
			return exeLimit;
		}
		
		/**
		 * Call the overwrite the Limit and to set the counter to 0
		 */
		public void resetLimits(Integer maxExecutions)
		{
			exeLimit = maxExecutions;
			exeCounter = 0;
		}
		
		
		/**
		 * Evals if the code can be executed
		 */
		public Boolean canExecute()
		{
			return (exeLimit > exeCounter || exeLimit == 0 && inTestMode) && !disabled;
		}
		
		/** 
	   	 * Returns true if the code can be executed and increments the counter
	   	 */
		public Boolean execute()
		{
			if(!canExecute())
				return false;
			exeCounter++;
			return true;
		}
		
	}

	/**
	 * TESTS
	 */
	private static testMethod void testCore()
	{
		// imaginary code names
		string cls1 = 'AccountHierarchyBuilder';
		string mtd1 = 'AccountHierarchyUtil.build';
		string trg1 = 'AccountTriggerBefore';	// trigger invoiced before 
		
		// start the test
		ApexCodePatrol.startTest(cls1);
		system.assertEquals(true, ApexCodePatrol.isTest(cls1));
		system.assertEquals(true, ApexCodePatrol.isRegistered(cls1));
		
		// since it hasn't been executed the class should be executable able at least once
		system.assertEquals(true, ApexCodePatrol.canExecute(cls1));

		// DISABLE TRIGGER
		// before executing the class, disable the account trigger, because multipe updates might
		// be peformed
		ApexCodePatrol.disable(trg1);

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
		for(integer i = 0; i<10;i++)
		{
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