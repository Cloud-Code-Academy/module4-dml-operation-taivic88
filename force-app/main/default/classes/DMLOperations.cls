/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Vic
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account acc = new Account(Name = 'Vic\'s BBQ House');
        // Set some fields on the Account
        // Insert the Account into the database
        insert acc;
        // Return the Id of the newly created Account
        //Id accountId = acc.Id;
        return acc.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account acc = new Account(Name = name, Industry = industry);
        // Insert the Account
        insert acc;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact con = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@email.com',
            Phone = '555-123-4567',
            AccountId = accountId
        );
        // Set some fields on the Contact
        // Set the AccountId field to the given accountId
        // Insert the Contact into the database
        insert con;
        // Return the Id of the newly created Contact
        return con.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        Contact con = [SELECT Id FROM Contact WHERE Id = :contactId];
        // Update the Contact's last name
        con.LastName = newLastName;
        // Update the Contact in the database
        update con;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        // Update the Opportunity's stage
        opp.StageName = newstage;
        // Update the Opportunity in the database
        update opp;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        Account acc = [SELECT Id FROM Account WHERE Id = :accountId];
        // Update the Account with the given Id with the new name and industry
        acc.Name = newName;
        acc.Industry = newIndustry;
        update acc;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        if (opportunities == null || opportunities.isEmpty()) {
            return;
        }

        try {
            // Loop through each Opportunity in the list
            for (Opportunity opp : opportunities) {
                // Set the Opportunity's Stage to Qualification
                opp.StageName = 'Qualification';
                // Set the Opportunity's Close Date to 3 months from today
                opp.CloseDate = Date.today().addMonths(3); 
                // Set the Opportunity's Amount to 50000
                opp.Amount = 50000;
            }
            
            // Upsert the opportunities List so that records are either updated or created
            // Vic notes: Upsert with error handling
            Database.UpsertResult[] results = Database.upsert(opportunities, false);

            System.debug('Here is the system response: ' + results);

            //Vic notes: Failure logs
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    System.debug('Failed to upsert opportunity ' + i + ': ' + results[i].getErrors());
                }
            }
        }
        //Vic notes: Catch exceptions
        catch (Exception e) {
            System.debug('Error in upsertOpportunityList: ' + e.getMessage());
            throw e;
        }
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        /*

        // Vic Notes: BEFORE CREATING External_Id__c FIELD ON ACCOUNTS
        // Vic Notes: get Account Ids and map to Account names
        List<Account> accs = [
            SELECT Id, Name
            FROM Account
            WHERE Name = :accountName
        ];

        Map<String, Id> accNameToId = new Map<String, Id>();
        for (Account acc : accs) {
            accNameToId.put(acc.Name, acc.Id);  
        } 

        // Vic Notes: Handle if no account was found 
        if (accNameToId.isEmpty()) {
            System.debug('No account found with name: ' + accountName);
            Account newAcc = new Account(Name = accountName); 
            insert newAcc;
            accNameToId.put(newAcc.Name, newAcc.Id);
        }

        // Vic Notes: Map for exsting Opps
        Map<String, Opportunity> existingOpps = new Map<String, Opportunity>();
        
        Id accountId = accNameToId.get(accountName);

        List<Opportunity> existingOppList = [
            SELECT Id, Name, AccountId, StageName, CloseDate
            FROM Opportunity 
            WHERE AccountId = :accountId AND Name IN :oppNames
        ];
        
        for (Opportunity opp : existingOppList) {
            existingOpps.put(opp.Name, opp);
        }

        // Loop through each Opportunity name
        List<Opportunity> upsertOpps = new List<Opportunity>();

        for (String oppName : oppNames) {
            // Create an Opportunity with the given name
            // Add the Opportunity to the list
            Opportunity opp;
        
            if (existingOpps.containsKey(oppName)) {
                // Vic Note: Update existing opportunity
                opp = existingOpps.get(oppName);
                opp.StageName = 'Prospecting';
                opp.CloseDate = Date.today().addMonths(3);
            } else {
                // Vic Note: Create new opportunity
                opp = new Opportunity(
                    Name = oppName,
                    AccountId = accountId,
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addMonths(3)
                );
            }
            
            upsertOpps.add(opp);
        }
        
        upsert upsertOpps; 

        */

        // Vic Notes: AFTER CREATING External_Id__c FIELD ON ACCOUNTS
        // Vic Notes: Upsert account using external id field
        Account acc = new Account(
            Name = accountName,
            External_Id__c = accountName
        );
        
        upsert acc External_Id__c;
        
        // Query for existing opportunities
        Map<String, Opportunity> existingOpps = new Map<String, Opportunity>();
        List<Opportunity> existingOppList = [
            SELECT Id, Name, AccountId, StageName, CloseDate
            FROM Opportunity 
            WHERE AccountId = :acc.Id AND Name IN :oppNames
        ];
        
        for (Opportunity opp : existingOppList) {
            existingOpps.put(opp.Name, opp);
        }

        // Create or update opportunities
        List<Opportunity> upsertOpps = new List<Opportunity>();
        
        for (String oppName : oppNames) {
            Opportunity opp;
            
            if (existingOpps.containsKey(oppName)) {
                // Update existing opportunity
                opp = existingOpps.get(oppName);
                opp.StageName = 'Prospecting';
                opp.CloseDate = Date.today().addMonths(3);
            } else {
                // Create new opportunity
                opp = new Opportunity(
                    Name = oppName,
                    AccountId = acc.Id,
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addMonths(3)
                );
            }
            upsertOpps.add(opp);
        }
        
        upsert upsertOpps;
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
        // Vic Notes: Assuming there are no dupes
		List<Account> accounts = [SELECT Id, Description, Name FROM Account WHERE Name = :accountName];
        Account upsertAcc;

		// if the Account exists, update the description
        if (accounts == null || accounts.isEmpty()) {
            Account newAcc = new Account(Description = 'New Account', Name = accountName);
            upsertAcc = newAcc;
        } else {  // otherwise, create a new Account and set the description
            for (Account acc : accounts) {
                acc.Description = 'Updated Account';
                upsertAcc = acc;
            } 
        }
        
		// Upsert the Account
		try {
            Database.UpsertResult result = Database.upsert(upsertAcc, false);
            if (!result.isSuccess()) {
                System.debug('Failed to upsert opportunity: ' + result.getErrors());
            }
        }
        catch (Exception e) {
            System.debug('Error in upsertOpportunityList: ' + e.getMessage());
            throw e;
        }

        return upsertAcc;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Vic Notes: Early exit
        if (contactsToUpsert == null || contactsToUpsert.isEmpty()) {
            return; // Early exit for empty input
        }
        
        // Loop through each Contact
        // Vic Notes: Null check
        List<String> lastNames = new List<String>();
        for (Contact con : contactsToUpsert) {
            if (con.LastName != null) {
                lastNames.add(con.LastName);
            }
        }
		// Extract the Account Name from Contact's LastName
        Map<String, Account> nameToAccount = new Map<String, Account>();
        List<Account> accs = [SELECT Id, Name FROM Account WHERE Name IN :lastNames];
        
        // Get the account based on the name or create one if it doesn't exist
        for (Account acc : accs) {
            nameToAccount.put(acc.Name, acc);
        }
        // Vic Notes: find missing Accounts
        List<Account> missingAccs = new List<Account>();
        for (String lastName : lastNames) {
            if (!nameToAccount.containsKey(lastName)) {
                Account acc = new Account(Name = lastName);
                missingAccs.add(acc);
            }  
        }
        // Vic Notes: insert missingAccs
        Database.SaveResult[] accResults = Database.insert(missingAccs, false);
        for (Database.SaveResult result : accResults) {
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()) {
                    System.debug('Error creating account: ' + error.getMessage());
                }
                // Vic Notes: Throw DmlException
                throw new DmlException('Failed to create accounts');
            }
        }

        // Vic Notes: logging
        System.debug('Created ' + missingAccs.size() + ' new accounts');

        // Vic Notes: only add successfully created accounts to map
        for (Integer i = 0; i < missingAccs.size(); i++) {
            if (accResults[i].isSuccess()) {
                nameToAccount.put(missingAccs[i].Name, missingAccs[i]);
            }
        }

		// Link the Contact to its Account using the Account Id
        for (Contact con : contactsToUpsert) {
            if (con.LastName != null && nameToAccount.containsKey(con.LastName)) {
                Account matchedAccForCon = nameToAccount.get(con.LastName);
                con.AccountId = matchedAccForCon.Id;
            }
        }

        // Vic Notes: Logging
        System.debug('Processing ' + contactsToUpsert.size() + ' contacts');

		// Upsert the Contacts
        Database.UpsertResult[] conResults = Database.upsert(contactsToUpsert, false);
        for (Database.UpsertResult result : conResults) {
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()) {
                    System.debug('Error upserting contact: ' + error.getMessage());
                    throw new DmlException('Failed to upsert some contacts');
                }
            }
        }

        //Vic Notes: Logging
        System.debug('Upserted ' + contactsToUpsert.size() + ' contacts');
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        List<Lead> insertLeads = new List<Lead>();

        // Loop through each Lead name
        for (String leadName : leadNames) {
            String firstName = 'Unknown';
            String lastName = 'Unknown';

            if (String.isNotBlank(leadName)) {
                leadName = leadName.trim();
                if (leadName.contains(' ')) {
                    List<String> nameParts = leadName.split(' ', 2);
                    firstName = nameParts[0];
                    lastName = nameParts[1];
                } else {
                    lastName = leadName;
                }
            }
        
            Lead lead = new Lead(
                FirstName = firstName,
                LastName = lastName,
                Company = 'Test Company'
            );

            insertLeads.add(lead);
        }
        // Insert the Leads
        insert insertLeads;
        // Delete the Leads
        delete insertLeads;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        // Insert the cases
        List<Case> insertCases = new List<Case>();

        for (Integer i = 0 ; i < numOfCases; i++) {
            Case newCase = new Case(
                AccountId = accountId
            );
            insertCases.add(newCase);
        }

        insert insertCases;
        // Delete the cases
        delete insertCases;
    }
}