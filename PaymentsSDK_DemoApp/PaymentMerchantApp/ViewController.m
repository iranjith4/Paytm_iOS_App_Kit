//
//  ViewController.m
//  PaymentMerchantApp
//
//  Created by Pradeep Udupi on 13/12/12.
//  Copyright (c) 2012-2015 Paytm Mobile Solutions Ltd. All rights reserved.
//  Written under contract by Robosoft Technologies Pvt Ltd.
//

#import "ViewController.h"
#import "PaymentsSDK.h"

#define NO_OF_FORM_FIELDS 7 

typedef enum
{
    eMerchantID = 1,
    eCustomerID,
    eTransactionAmount,
    eChannelID,
    eIndustryTypeID,
    eWebsite,
    eTheme,
}FormFieldType;

//static NSString *kMerchantChecksumGenURL = @"https://125.63.68.107/merchant-chksum/ChecksumGenerator";
//static NSString *kMerchantChecksumValURL = @"https://125.63.68.107/merchant-chksum/ValidateChksum";

static NSString *kMerchantChecksumGenURL = @"https://pguat.paytm.com/paytmchecksum/paytmCheckSumGenerator.jsp";
static NSString *kMerchantChecksumValURL = @"https://pguat.paytm.com/paytmchecksum/paytmCheckSumVerify.jsp";

@interface ViewController ()
- (void)setKeyboardNotifications:(BOOL)shouldRegister;

@property (nonatomic, assign) UITextField *currentField;
@property (nonatomic, strong) NSTimer *statusTimer;
@property (nonatomic, strong) PGOrder *currentOrder;
@property (weak, nonatomic) IBOutlet UISwitch *topBarCustomSwitch;

@end

@implementation ViewController

+(NSString*)generateOrderIDWithPrefix:(NSString *)prefix
{
    srand ( (unsigned)time(NULL) );
    NSInteger randomNo = rand(); //just randomizing the number
    NSString *orderID = [NSString stringWithFormat:@"%@%ld", prefix, (long)randomNo];
    return orderID;
}

+(NSString*)generateCustomerID
{
    srand ( (unsigned)time(NULL) );
    NSInteger randomNo = rand(); //just randomizing the number
    NSString *orderID = [NSString stringWithFormat:@"CUST%ld", (long)randomNo];
    return orderID;
}

- (void)setOrderParameterFields
{
    //set the customer field only once when the app is launched
    if ([self.customerIDTextField.text isEqualToString:@""] || self.customerIDTextField.text == nil) {
        self.customerIDTextField.text = [ViewController generateCustomerID];
    }
    
    //create a new order id every time a order preparation view appears
    self.orderIDField.text = [ViewController generateOrderIDWithPrefix:@"ORDER"];
    self.customerIDTextField.text = @"CUSTOMER123";
    self.transactionAmountTextField.text = @"1"; //reset amount to 1 for safety
    self.custeMailTextField.text = @"customer123@paytm.com";
    self.custMobileNoTextField.text = @"9343999888";
}

- (void)setDefaultMerchantParamsAndFields
{
    //set the client SSL cert settings
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"Client" ofType:@"p12"];

    PGMerchantConfiguration *merchant = [PGMerchantConfiguration defaultConfiguration];
    merchant.clientSSLCertPath = certPath;
    merchant.clientSSLCertPassword = @"admin";
    
    //set the merchant params
    merchant.merchantID = @"WorldP64425807474247"; //STAGING MID
    //merchant.merchantID = @"robote84198990953406"; //PRODUCTION MID
    merchant.website = @"worldpressplg";
    merchant.industryID = @"Retail";
    merchant.checksumGenerationURL = kMerchantChecksumGenURL;
    merchant.checksumValidationURL = kMerchantChecksumValURL;

    
    //Display these below values as default values and consider these values only as parameters if fields are not modified.
    self.merchantIDTextField.text = merchant.merchantID;
    self.channelIDTextField.text = merchant.channelID;
    self.industryTypeIDTextField.text = merchant.industryID;
    self.websiteTextField.text = merchant.website;
    self.themeTextField.text = merchant.theme;
    self.checksumGenTextField.text = merchant.checksumGenerationURL;
    self.checksumValidTextfield.text = merchant.checksumValidationURL;    
}

- (void)updateMerchantConfigurationWithLatestValues
{
    PGMerchantConfiguration *defaultConfig = [PGMerchantConfiguration defaultConfiguration];
    defaultConfig.merchantID = self.merchantIDTextField.text;
    defaultConfig.channelID = self.channelIDTextField.text;
    defaultConfig.industryID = self.industryTypeIDTextField.text;
    defaultConfig.website = self.websiteTextField.text;
    defaultConfig.theme = self.themeTextField.text;
    
    if (!self.checksumGenTextField.hidden)
    {
        defaultConfig.checksumGenerationURL = [self.checksumGenTextField.text copy];
        defaultConfig.checksumValidationURL = self.checksumValidTextfield.text;
    }
    else
    {
        [PGMerchantConfiguration defaultConfiguration].checksumGenerationURL = nil;
        [PGMerchantConfiguration defaultConfiguration].checksumValidationURL = nil;
    }
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Merchant App";
    
    // For IOS 7 Screen compatible
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    CGRect frame = self.checksumGenTextField.frame;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, frame.origin.y)];
    self.scrollView.frame = CGRectMake(0.0f, self.view.frame.origin.y + 40.0, self.view.frame.size.width, self.view.frame.size.height - 105.0f);
    [self.view addSubview:self.scrollView];
    [self setDefaultMerchantParamsAndFields];

    [self setKeyboardNotifications:YES];
    [self hideServerPartUI:YES];
}

- (void)viewDidUnload
{
    [self setCusteMailTextField:nil];
    [self setCustMobileNoTextField:nil];
    [self setChecksumGenLabel:nil];
    [self setChecksumGenTextField:nil];
    [self setChecksumValidLabel:nil];
    [self setChecksumValidTextfield:nil];
    [self setTopBarCustomSwitch:nil];
    [super viewDidUnload];
    [self setKeyboardNotifications:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setOrderParameterFields]; //change the order parameters every time the view appears
}

#pragma mark UI actions

- (IBAction)refreshCustomer:(id)sender
{
    self.customerIDTextField.text = [ViewController generateCustomerID];
}

#pragma mark -

- (void)setKeyboardNotifications:(BOOL)shouldRegister
{
    if (shouldRegister)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGRect themeFieldRect = self.checksumValidTextfield.frame;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, themeFieldRect.origin.y + themeFieldRect.size.height+ 200)];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    CGRect frame = self.currentField.frame;
    
    CGPoint offset;
    if (frame.origin.y > _scrollView.frame.size.height)
    {
        offset = CGPointMake(0.0, (frame.origin.y + frame.size.height + 20) - _scrollView.frame.size.height);
    }
    else
    {
        offset = CGPointMake(0.0f, 0.0f);
    }
    [_scrollView setContentOffset:offset animated:YES];
    
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _currentField = textField;
    //DEBUGLOG(@"textFieldShouldBeginEditing _currentField = %@", _currentField);

    CGPoint scrollPoint;
    CGRect inputFieldBounds = [textField bounds];
    inputFieldBounds = [textField convertRect:inputFieldBounds toView:_scrollView];
    scrollPoint = inputFieldBounds.origin;
    scrollPoint.x = 0;
    scrollPoint.y -= 70; // you can customize this value
    if (scrollPoint.y < 0 ) scrollPoint.y = 0;
    [_scrollView setContentOffset:scrollPoint animated:YES];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _currentField)
        _currentField = nil;
    //DEBUGLOG(@"textFieldDidEndEditing _currentField = %@", _currentField);
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - CheckSumGeneration URL Change

- (IBAction)changeChecksumGenerationURL:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    
    CGPoint offset;
    
    if (seg.selectedSegmentIndex == 1)
    {
        [self hideServerPartUI:NO];
        offset = CGPointMake(0.0f, (seg.frame.origin.y + seg.frame.size.height + 200) - _scrollView.frame.size.height);
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, seg.frame.origin.y + seg.frame.size.height+ 200)];
    }
    else
    {
        [_currentField resignFirstResponder];
        [self hideServerPartUI:YES];        
        offset = CGPointMake(0.0f, (seg.frame.origin.y + seg.frame.size.height + 50) - _scrollView.frame.size.height);
    }
    [_scrollView setContentOffset:offset animated:YES];
}

- (void)hideServerPartUI:(BOOL)hide
{
    self.checksumGenLabel.hidden = hide;
    self.checksumGenTextField.hidden = hide;
    self.checksumValidLabel.hidden = hide;
    self.checksumValidTextfield.hidden = hide;
}


#pragma mark -

- (IBAction)beginPayment:(id)sender
{
    //Set the latest merchant id in case it has been changed
    [self updateMerchantConfigurationWithLatestValues];
    
    [PGServerEnvironment selectServerDialog:self.view completionHandler:^(ServerType type)
     {
         PGOrder *order = [PGOrder orderForOrderID:self.orderIDField.text
                                        customerID:self.customerIDTextField.text
                                            amount:self.transactionAmountTextField.text
                                      customerMail:self.custeMailTextField.text
                                    customerMobile:self.custMobileNoTextField.text];
         
        
        
         
         order.params =   @{@"MID" : @"TECHOP10964184510936",
                            @"ORDER_ID": @"1520843747890",
                            @"CUST_ID" : @"test111",
                            @"CHANNEL_ID": @"WAP",
                            @"INDUSTRY_TYPE_ID": @"Retail",
                            @"WEBSITE": @"TECHweb",
                            @"TXN_AMOUNT": @"1",
        @"CHECKSUMHASH":@"Bzk47IMatCI7T3b21iB403MsRBNhJ9DWHeK79iD+dli6GUg5w+JKDk6gk6roSjuKrtFzDiXwuUsfgVz30Xa2+W+kgwnNQaZXJTSfKPy6gU4=",
                            @"CALLBACK_URL":@"https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=1520843747890"
                           };
        PGTransactionViewController *txnController = [[PGTransactionViewController alloc] initTransactionForOrder:order];
         txnController.loggingEnabled = YES;
         
        if (type != eServerTypeNone)
            txnController.serverType = type;
        else return;
        txnController.merchant = [PGMerchantConfiguration defaultConfiguration];
        txnController.delegate = self;
         
         if (_topBarCustomSwitch.isOn)
         {
             if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) // For IOS 7 Screen compatible
             {
                 UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 64.0f)];
                 headerView.backgroundColor = [UIColor clearColor];
                 UIView * topBar = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 20.0f, 320.0f, 50.0f)];
                 [topBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topBar"]]];
                 [headerView addSubview:topBar];
                 txnController.topBar = headerView;
                 
                 UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(10.0f, 25.0f, 60.0f, 40.0f)];
                 [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
                 txnController.cancelButton = cancelButton;
             }
             else
             {
                 UIView * topBar = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 50.0f)];
                 [topBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topBar"]]];
                 txnController.topBar = topBar;
                 UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(10.0f, 5.0f, 60.0f, 40.0f)];
                 [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
                 txnController.cancelButton = cancelButton;

             }
         }
         
        [self.navigationController pushViewController:txnController animated:YES];
             
    }];
}

- (void)checkStatus:(id)sender
{
    [PGServerEnvironment statusForOrderID:_currentOrder.orderID responseHandler:^(NSDictionary *response, NSError *error)
    {
        if (error)DEBUGLOG(@"STATUS ERROR: %@",error.localizedDescription);
        else      DEBUGLOG(@"STATUS RESPONSE: %@",response.description);
    }];
}

#pragma mark PGTransactionViewController delegate

-(void)didFinishedResponse:(PGTransactionViewController *)controller response:(NSString *)responseString {
    DEBUGLOG(@"ViewController::didFinishedResponse:response = %@", responseString);
    [controller.navigationController popViewControllerAnimated:YES];
}


-(void)didCancelTrasaction:(PGTransactionViewController *)controller {
    
    [_statusTimer invalidate];
    NSString *msg = [NSString stringWithFormat:@"UnSuccessful"];
    [[[UIAlertView alloc] initWithTitle:@"Transaction Cancel" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [controller.navigationController popViewControllerAnimated:YES];
}

//Called when a required parameter is missing.
-(void)errorMisssingParameter:(PGTransactionViewController *)controller error:(NSError *) error {
    DEBUGLOG(@"Parameter is missing %@",error.localizedDescription);
    [controller.navigationController popViewControllerAnimated:YES];
}

@end
