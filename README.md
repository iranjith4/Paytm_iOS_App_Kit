# Steps for iOS Integration

* Step 0: IOS Configuration
	* PGSDK provided in the IOS plugin can be downloaded from here
	* Add library to the project.
	* Add System configuration framework.

* Step 1: Merchant configuration
	* SDK identifies each Merchant by PGMerchantConfiguration object. You can configure this anywhere in the code before the first transaction with necessary parameters. It requires only one time configuration. Since it is singleton Class, you may utilize the same for any transaction within your application.

	* Objective – C
		
		#### //You will get default PGMerchantConfiguration object. By setting the below properties of object you can make a fully configured merchant object.
		#### PGMerchantConfiguration *mc = [PGMerchantConfiguration defaultConfiguration];

* Step 2: Order Creation:
	* Create the order with the mandatory parameters, as given below in the code snippet. In addition to this, you may add other optional parameters as needed.

	* Objective – C
		
		#### NSMutableDictionary * orderDict = [NSMutableDictionary new];
		#### //Merchant configuration in the order object
		#### orderDict[@"MID"] = @"WorldP64421234564247";
		#### orderDict[@"CHANNEL_ID"] = @"WAP";
		#### orderDict[@"INDUSTRY_TYPE_ID"] = @"Retail";
		#### orderDict[@"WEBSITE"] = @"worldpressplg";
		#### //Order configuration in the order object
		#### orderDict[@"TXN_AMOUNT"] = @"1";
		#### orderDict[@"ORDER_ID"] = [ViewController generateOrderIDWithPrefix:@""];
		#### orderDict[@"CALLBACK_URL"] = @"https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=<ORDER_ID>";
		#### orderDict[@"CHECKSUMHASH"] = @"w2QDRMgp1234567JEAPCIOmNgQvsi+BhpqijfM9KvFfRiPmGSt3Ddzw+oTaGCLneJwxFFq5mqTMwJXdQE2EzK4px2xruDqKZjHupz9yXev4=";
		#### orderDict[@"REQUEST_TYPE"] = @"DEFAULT";
		#### orderDict[@"CUST_ID"] = @"1234567890";
		#### PGOrder *order = [PGOrder orderWithParams:orderDict];

* Step 3:
	* Choose the PG server. In your production build don’t call selectServerDialog. Just create an instance of the PGTransactionViewController and set the serverType to eServerTypeProduction

	* Objective – C
		
		#### [PGServerEnvironment selectServerDialog:self.view completionHandler:^(ServerType type)
		#### 	{
		#### 		PGTransactionViewController *txnController = [[PGTransactionViewController alloc] initTransactionForOrder:order];
		#### 		if (type != eServerTypeNone) {
		#### 		txnController.serverType = type;
		#### 		txnController.merchant = mc;
		#### 		txnController.delegate = self;
		#### 		[self showController:txnController];
		#### 	}
		#### }];

* Step 4: Implement The PGTransactionDelegate protocol.
	* The following code snippet shows how the callback will be handled.

	* Objective-C
		
		#### //Called when a transaction has completed. response dictionary will be having details about Transaction.
		#### -(void)didFinishedResponse:(PGTransactionViewController *)controller response:(NSString *)responseString;
		#### //Called when a user has been canceled the transaction.
		#### -(void)didCancelTrasaction:(PGTransactionViewController *)controller;
		#### //Called when a required parameter is missing.
		#### -(void)errorMisssingParameter:(PGTransactionViewController *)controller error:(NSError *) error;

# Paytm iOS Kit

Note: kindly add the dependency in your project **`SystemConfiguration.framework`**

## SDK Documentation
http://paywithpaytm.com/developer/paytm_sdk_doc/

## SDK work flow
http://paywithpaytm.com/developer/paytm_sdk_doc?target=how-paytm-sdk-works

## IOS Integration Flow
http://paywithpaytm.com/developer/paytm_sdk_doc?target=steps-for-ios-integration



# Checksum Utilities

## PHP
https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_PHP

## Java
https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_JAVA

## Python
https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_Python

## Ruby
https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_Ruby

## NodeJs
https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_NodeJs

## .Net
https://github.com/Paytm-Payments/Paytm_App_Checksum_Kit_DotNet



# Transaction Status API
http://paywithpaytm.com/developer/paytm_api_doc?target=txn-status-api

# Steps to configure via PODS
1. Do a 'pod init' in the project Directory if you don't have a pod added already. It will create a Podfile.
2. Add `source 'https://github.com/Paytm-Payments/Paytm_iOS_App_Kit.git'` at the top of the podfile
3. Add `pod 'Paytm-Payments'` in the pod file under the `target 'App Name' do`.
4. Save and run `pod install` in the terminal, in which pod file is there.
5. Open xcorkspace
6. Go to App Target -> Build Phases -> Link Binaries with libraries and add **SystemConfiguaration.framework**
7. Go to Pods Target -> Build Phases -> Link Binaries with libraries and add drag libPaymentsSDK.a there From Pods Resources
