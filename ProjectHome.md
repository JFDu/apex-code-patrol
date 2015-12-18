# What is it? #
Apex Code Patrol allows you to control the execution of your classes, triggers, groups or even single methods, by setting execution limits or simply disabling the code on the fly.



# How to use this #
_for some detail examples check out the test methods_



## Disable-Code ##
```
public class ACPSampleClass {


public void updateAccounts()
{

// maybe some other code performed dml on setup objects and disabled
// any other dml via patrol class (for heavy used keys you should think about custom labels)
if(ApexCodePatrol.isDisabled(System.Label.ACP_NON_SETUP){return;}

// disable the update trigger 
ApexCodePatrol.disable('ACPSampleTrigger.update');

// perform the first update
update accounts;


// continue modifiy accounts


// enable the update trigger, before the next update
ApexCodePatrol.enable('ACPSampleTrigger.update');

// update the accounts a second time
// trigger will be executed (see below)
update accounts;


}
}
```


## Using in a Trigger ##
```

trigger ACPSampleTrigger on Account (after insert, after update) {

/* 
if not disabled (see above), trigger is executed only once
*/
if(trigger.isUpdate && ApexCodePatrol.execute('ACPSampleTrigger.update')){
// YOUR CODE HERE
}


/* 
DataQuality code can be executed twice
*/
if(ApexCodePatrol.execute('DataQuality.Account',2)){
// YOUR CODE HERE
}

}
```