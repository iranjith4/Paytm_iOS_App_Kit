//
//  ViewController.h
//  PaymentMerchantApp
//
//  Created by Pradeep Udupi on 13/12/12.
//  Copyright (c) 2012-2015 Paytm Mobile Solutions Ltd. All rights reserved.
//  Written under contract by Robosoft Technologies Pvt Ltd.
//

#import <UIKit/UIKit.h>
#import "PaymentsSDK.h"

@interface ViewController : UIViewController <PGTransactionDelegate, UITextFieldDelegate, UIActionSheetDelegate>

/*
 Form Fields
 */
@property (nonatomic, strong) IBOutlet UITextField *merchantIDTextField;
@property (nonatomic, strong) IBOutlet UITextField *customerIDTextField;
@property (nonatomic, strong) IBOutlet UITextField *transactionAmountTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *custMobileNoTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *custeMailTextField;
@property (nonatomic, strong) IBOutlet UITextField *channelIDTextField;
@property (nonatomic, strong) IBOutlet UITextField *industryTypeIDTextField;
@property (nonatomic, strong) IBOutlet UITextField *websiteTextField;
@property (nonatomic, strong) IBOutlet UITextField *themeTextField;
@property (nonatomic, strong) IBOutlet UITextField *orderIDField;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *checksumGenLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *checksumGenTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *checksumValidLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *checksumValidTextfield;


- (IBAction)beginPayment:(id)sender;

- (IBAction)refreshCustomer:(id)sender;


@end
