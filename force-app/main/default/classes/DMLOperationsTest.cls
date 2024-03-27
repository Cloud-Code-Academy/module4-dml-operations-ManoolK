/**
 * The DMLOperationsTest class is specifically designed to test the functionality of the methods present in the DMLOperations class.
 * This test class contains several test methods, each one designed to validate individual methods in the DMLOperations class, ensuring their correct behavior.
 * The Salesforce Assert class is employed extensively in these test methods to assert and validate the expected outcomes.
 *
 * Each test method is created to test a corresponding method in the DMLOperations class which includes operations such as insert, update, upsert, and delete on Salesforce standard objects like Account, Contact, and Opportunity.
 */

@IsTest
public with sharing class DMLOperationsTest {

    @IsTest
    static void testInsertNewAccount() {
        // Call the method to test
        Id newAccountId = DMLOperations.insertNewAccount();

        // Assert that an ID was returned
        System.assertNotEquals(null, newAccountId, 'The new account ID should not be null');

        // Retrieve the inserted account from the database
        Account retrievedAccount = [SELECT Id, Name FROM Account WHERE Id = :newAccountId];

        // Assert that the Account was successfully inserted
        System.assertNotEquals(null, retrievedAccount, 'The retrieved account should not be null');
        System.assertEquals(newAccountId, retrievedAccount.Id, 'The IDs should match');
    }

    @IsTest
    static void testCreateAccount() {
        // Test the method
        DMLOperations.createAccount('Test Account', 'Technology');

        // Query to verify the account was created
        Account testAccount = [SELECT Id, Name, Industry FROM Account WHERE Name = 'Test Account'];

        // Assert that the account was successfully created with the correct fields
        Assert.isNotNull(testAccount, 'Account was not created.');
        Assert.areEqual('Test Account', testAccount.Name, 'Account name is incorrect.');
        Assert.areEqual('Technology', testAccount.Industry, 'Account industry is incorrect.');
    }


    @IsTest
    static void testInsertNewContact() {
        // Create a test Account first
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Call the method to test
        Id newContactId = DMLOperations.insertNewContact(testAccount.Id);

        // Assert that an ID was returned
        System.assertNotEquals(null, newContactId, 'The new contact ID should not be null');

        // Retrieve the inserted contact from the database
        Contact retrievedContact = [SELECT Id, LastName, AccountId FROM Contact WHERE Id = :newContactId];

        // Assert that the Contact was successfully inserted and linked to the correct Account
        System.assertNotEquals(null, retrievedContact, 'The retrieved contact should not be null');
        System.assertEquals(newContactId, retrievedContact.Id, 'The IDs should match');
        System.assertEquals(testAccount.Id, retrievedContact.AccountId, 'The Account IDs should match');
    }
    
    @IsTest
    static void testUpdateContactLastName() {
        // Create a test Contact first
        Contact testContact = new Contact(LastName = 'Doe');
        insert testContact;

        // Call the method to test
        String newLastName = 'Smith';
        DMLOperations.updateContactLastName(testContact.Id, newLastName);

        // Retrieve the updated Contact from the database
        Contact updatedContact = [SELECT Id, LastName FROM Contact WHERE Id = :testContact.Id];

        // Assert that the Contact's last name was successfully updated
        System.assertEquals(newLastName, updatedContact.LastName, 'The last name should be updated');
    }

    @IsTest
    static void testUpdateOpportunityStage() {
        // Create a test Account first
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;
        
        // Create a test Opportunity
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', AccountId = testAcc.Id, StageName = 'Prospecting', CloseDate = Date.today().addMonths(3));
        insert testOpp;

        // Call the method to test
        String newStage = 'Closed Won';
        DMLOperations.updateOpportunityStage(testOpp.Id, newStage);

        // Retrieve the updated Opportunity from the database
        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpp.Id];

        // Assert that the Opportunity's stage was successfully updated
        System.assertEquals(newStage, updatedOpp.StageName, 'The stage should be updated');
    }

    @IsTest
    static void testUpdateAccountFields() {
        // Create an account for the test
        Account acc = new Account(Name = 'Test Account', Industry = 'Technology');
        insert acc;

        // Test the method
        DMLOperations.updateAccountFields(acc.Id, 'Updated Account', 'Finance');

        // Query the updated account
        Account updatedAccount = [SELECT Id, Name, Industry FROM Account WHERE Id = :acc.Id];

        // Assert that the account fields were successfully updated
        Assert.areEqual('Updated Account', updatedAccount.Name, 'Account name was not updated correctly.');
        Assert.areEqual('Finance', updatedAccount.Industry, 'Account industry was not updated correctly.');
    }


    @IsTest
    static void testUpsertOpportunityList() {
        // Create a test Account first
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        List<Opportunity> opportunities = new List<Opportunity>();
        
        // Create a test Opportunity
        Opportunity insertedOpp = new Opportunity(Name = 'insertedOpp Opportunity', AccountId = testAcc.Id, StageName = 'Prospecting', CloseDate = Date.today(), Amount = 10000000);
        insert insertedOpp;

        Opportunity notInsertedOpp = new Opportunity(Name = 'notInsertedOpp Opportunity', AccountId = testAcc.Id, StageName = 'Prospecting', CloseDate = Date.today());
        opportunities.add(insertedOpp);
        opportunities.add(notInsertedOpp);

    
        // Call the method to test with the Account Id
        DMLOperations.upsertOpportunityList(opportunities);
    
        // Retrieve the Opportunity from the database
        Opportunity[] retrievedOpp = [SELECT Id, Name, CloseDate, StageName, Amount FROM Opportunity];
    
        // Assert that the Opportunity was successfully upserted
        System.assertEquals(opportunities.size(), retrievedOpp.size(), 'The number of upserted Opportunities should match the number of Opportunity names provided');
        for (Opportunity opp : retrievedOpp) {
            System.assertEquals('Qualification', opp.StageName, 'The stage should be updated to Qualification');
            System.assertEquals(Date.today().addMonths(3), opp.CloseDate, 'The CloseDate should be updated to 3 months from today');
            System.assertEquals(50000, opp.Amount, 'The Amount should be updated to 50000');
        }
    }
    
    @IsTest
    static void testUpsertOpportunities() {
        // Prepare the Account name
        String accountName = 'Test Account';
    
        // Prepare the Opportunity names
        List<String> oppNames = new List<String>{ 'Opp 1', 'Opp 2', 'Opp 3' };
    
        // Call the method to test
        DMLOperations.upsertOpportunities(accountName, oppNames);
    
        // Retrieve the Account from the database
        Account retrievedAcc = [SELECT Id, Name FROM Account WHERE Name = :accountName];
        
        // Retrieve the Opportunities from the database
        List<Opportunity> retrievedOpps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :retrievedAcc.Id];
        
        // Assert that the Account was successfully upserted
        System.assertEquals(accountName, retrievedAcc.Name, 'The upserted Account should have the provided name');
    
        // Assert that the Opportunities were successfully upserted
        System.assertEquals(oppNames.size(), retrievedOpps.size(), 'The number of upserted Opportunities should match the number of Opportunity names provided');
    
        for (Opportunity opp : retrievedOpps) {
            System.assert(oppNames.contains(opp.Name), 'All Opportunity names should be found in the database');
        }
    
        // Call the method to test again to check the upsert operation
        DMLOperations.upsertOpportunities(accountName, oppNames);
    
        // Retrieve the updated Opportunities from the database
        List<Opportunity> updatedOpps = [SELECT Id, Name FROM Opportunity WHERE AccountId = :retrievedAcc.Id];
        
        // Assert that the Opportunities were successfully updated
        System.assertEquals(oppNames.size(), updatedOpps.size(), 'The number of updated Opportunities should match the number of Opportunity names provided');
    
        for (Opportunity opp : updatedOpps) {
            System.assert(oppNames.contains(opp.Name), 'All updated Opportunity names should be found in the database');
        }
    }

    @IsTest
	static void testUpsertAccount() {
		String accountName = 'Test Account';

		// Test creating a new account
		Test.startTest();
		Account upsertedAccount = DMLOperations.upsertAccount(accountName);

		// Verify that the account was created
		System.assertNotEquals(null, upsertedAccount.Id, 'Account should be created with an Id');
		System.assertEquals(accountName, upsertedAccount.Name, 'Account name should match');
        System.assertEquals('New Account', upsertedAccount.Description, 'Account description should match');

		// Test updating the existing account
		String updatedAccountName = 'Test Account';
		upsertedAccount.Name = updatedAccountName;

		Account updatedAccount = DMLOperations.upsertAccount(updatedAccountName);
		Test.stopTest();

		// Verify that the account was updated
		System.assertEquals(updatedAccount.Id, updatedAccount.Id, 'Account Id should remain the same after update');
        System.assertEquals('Updated Account', updatedAccount.Description, 'Account description should match');
	}

    @IsTest
	static void testUpsertAccountsWithContacts() {
		Account testAccount = new Account(Name = 'Doe');
		insert testAccount;
		// Create test contacts with last names matching account names
		List<Contact> testContacts = new List<Contact>{
			new Contact(LastName = 'Doe', FirstName = 'John'),
			new Contact(LastName = 'Smith', FirstName = 'Jane')
		};

		Test.startTest();
		DMLOperations.upsertAccountsWithContacts(testContacts);
		Test.stopTest();

		List<Account> accounts = [SELECT Id FROM Account];
		System.assertEquals(2, accounts.size(), 'Two accounts should be created');

		// Query the upserted contacts to verify account links
		List<Contact> upsertedContacts = [
			SELECT Id, LastName, AccountId, Account.Name
			FROM Contact
			WHERE Id IN :testContacts
		];
		for (Contact c : upsertedContacts) {
			System.assertNotEquals(null, c.AccountId, 'Contact should be linked to an Account');
			System.assertEquals(c.LastName, c.Account.Name, 'Contact last name should match Account name');
		}
	}
    
    @IsTest
    static void testInsertAndDeleteLeads() {
        // Prepare the Lead names
        List<String> leadNames = new List<String>{ 'Test Lead 1', 'Test Lead 2', 'Test Lead 3' };
    
        // Call the method to test
        DMLOperations.insertAndDeleteLeads(leadNames);
    
        // Query the Leads from the database
        List<Lead> retrievedLeads = [SELECT Id, LastName FROM Lead WHERE LastName IN :leadNames];
    
        // Assert that the Leads have been deleted
        System.assertEquals(0, retrievedLeads.size(), 'All Leads should have been deleted');
    }



    @IsTest
    static void testCreateAndDeleteCases() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Test the method
        DMLOperations.createAndDeleteCases(testAccount.Id, 5);

        // Query to verify cases were deleted
        List<Case> cases = [SELECT Id FROM Case WHERE AccountId = :testAccount.Id];

        // Assert that no cases exist for the account
        Assert.areEqual(0, cases.size(), 'Cases were not successfully deleted.');
    }

}