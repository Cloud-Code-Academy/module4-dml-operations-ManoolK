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
 * @author Oxana Suvorova
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
        Account acc = new Account();
        acc.name = 'Test New Account HW4';
        insert acc;
        // Return the Id of the newly created Account
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
        Contact newContact = new Contact(FirstName = 'John', LastName = 'Smith');
        // Set some fields on the Contact
        // Set the AccountId field to the given accountId
        newContact.AccountId = accountId;
        // Insert the Contact into the database
        insert newContact;
        // Return the Id of the newly created Contact
        return newContact.Id;
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
        Contact contact = [SELECT Id FROM Contact WHERE Id = :contactId];
        contact.LastName = newLastName;
        update contact;
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
        opp.StageName = newStage;
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
        acc.Name = newName;
        acc.Industry = newIndustry;
        // Update the Account with the given Id with the new name and industry
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
        // Iterate over the opportunities
        for (Opportunity opp : opportunities) {
            opp.StageName = 'Qualification'; // Stage to Qualification
            opp.CloseDate = Date.today().addMonths(3); // Close Date to 3 months from today
            opp.Amount = 50000; // Amount to 50000
        }
        // Upsert the Opportunity
        upsert opportunities;
    }

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        // Get or create Account that has the name accountName.
        Account acc = new Account();
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = :accountName];
        if (accounts.size() == 0) {
            acc.Name = accountName;
            insert acc;
        } else {
            acc = accounts.get(0);
        }
        // Get all Opportunities associated with the Account.
        List<Opportunity> opportunities = [SELECT Id, Name FROM Opportunity WHERE AccountId = :acc.Id];
        // Create new opportunities with provided names
        if (opportunities.size() == 0) {
            for (String oppName : oppNames) {
                Opportunity opp = new Opportunity(Name = oppName, AccountId = acc.Id);
                opp.StageName = 'Qualification';
                opp.CloseDate = Date.today().addMonths(3);
                opportunities.add(opp);
            }
        } else {
            // Check all names and update if they are not in the list. 
            // Assume: we have the same amount of records as the number of provided names
            if (opportunities.size() == oppNames.size()) {
                for (Opportunity opp : opportunities) {
                    if (!oppNames.contains(opp.Name)) {
                        Integer i = opportunities.indexOf(opp);
                        opp.Name = oppNames.get(i);
                    }
                }
            }
        }
        upsert opportunities;
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
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
		// if the Account exists, update the description
        Account acc;
        if (accounts.size() > 0) {
            acc = accounts.get(0);
            acc.Description = 'Updated Account';
        } else {
		// otherwise, create a new Account and set the description
            acc = new Account(Name = accountName, Description = 'New Account');
        }
		// Upsert the Account
        upsert acc;
		return acc;
	}

    /**
     * Question 10
	 * Upserts accounts and links contacts to them based on the contact's last name and account name.
	 * Create or use existing account with contact last name. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
	 * Contacts are then linked to these accounts based on a full last name match.
     * Example Contact Last Name = Doe Link to Account Name = Doe 
     * Example Contact Last Name = Jane Link to Account Name = Jane
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
        // The main idea: not use SOQL and DML inside the for loop.
		// Loop through each Contact to collect names
        List<String> names = new List<String>();
        for (Contact cont : contactsToUpsert) {
            names.add(cont.LastName);
        }
        // Get all existing accounts with contact's last name and collect in a Map
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name IN :names];
        Map<String, Id> accIdByName = new Map<String, Id>();
        for (Account acc : accounts) {
            accIdByName.put(acc.Name, acc.Id);
        }
        // Create Accounts for those Contact's names that has no Accounts 
        List<Account> newAcc = new List<Account>();
        for (String name : names) {
            if (!accIdByName.keySet().contains(name)) {
                Account acc = new Account(Name = name);
                newAcc.add(acc);
            }
        }
        insert newAcc;
        // Put new Account's Name and Id to the Map
        for (Account acc : newAcc) {
            accIdByName.put(acc.Name, acc.Id);
        }
        // Link the Contact to its Account using the Account Id
        for (Contact cont : contactsToUpsert) {
            cont.AccountId = accIdByName.get(cont.LastName);
        }
		// Upsert the Contacts
        upsert contactsToUpsert;
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        List<Lead> leads = new List<Lead>();
        // Loop through each Lead name
        for (String leadName : leadNames) {
            Lead newLead = new Lead();
            newLead.LastName = leadName;
            newLead.Status = 'Open - Not Contacted';
            newLead.Company = 'Test Company';
            leads.add(newLead);
        }
        // Insert the Leads
        insert leads;
        // Delete the Leads
        delete leads;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> cases = new List<Case>();
        // Insert the cases
        for (Integer i = 0; i < numOfCases; i++) {
            Case newCase = new Case();
            newCase.Origin = 'Web';
            newCase.Status = 'New';
            newCase.AccountId = accountId;
            cases.add(newCase);
        }
        insert cases;
        // Delete the cases
        delete cases;
    }
}