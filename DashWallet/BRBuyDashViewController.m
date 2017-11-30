//
//  BRBuyDashViewController.m
//  dashwallet
//
//  Created on 16/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRBuyDashViewController.h"
#import "BRImportClasses.h"
#import "BROfferViewController.h"
#import "BROrderCell.h"

@interface BRBuyDashViewController ()
{
    NSString *tempCurrencyCode;
    double dashAmount;
    NSString *pubId;
    NSMutableArray *offersArray;
    NSMutableArray *ordersArray;
    
}

@property (nonatomic, strong) NSUserDefaults *groupDefs;
@property (nonatomic, strong) BRPaymentRequest *paymentRequest;

@end

@implementation BRBuyDashViewController

@synthesize txtFirst,txtSecond,btnGetOffers,lblOr,lblLooking,txtZipCode,tblOrder;

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    offersArray = [[NSMutableArray alloc]init];
    ordersArray = [[NSMutableArray alloc]init];
    
    // Initial View Setup
    [self setUpView];
    
    [txtFirst addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [txtSecond addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    
    // Get
    
    
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIView Method
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    BRPaymentRequest *req;
    self.groupDefs = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP_ID];
    req = (_paymentRequest) ? _paymentRequest :
    [BRPaymentRequest requestWithString:[self.groupDefs stringForKey:APP_GROUP_RECEIVE_ADDRESS_KEY]];
    
    if (req.isValid) {
        pubId = req.paymentAddress;
    }
    else
    {
        pubId = req.paymentAddress;
    }
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    tempCurrencyCode = manager.localCurrencyCode;
    dashAmount = manager.localCurrencyDashPrice.doubleValue;
    
    NSString *userToken = [BRHelprClass getAuthToken];
    //NSLog(@"TOKEN %@",userToken);
    if(userToken.length != 0)
    {
        [self getOrderList];
        self.orderView.hidden = NO;
    }
    else
    {
        self.orderView.hidden = YES;
    }
    
}
- (void)setUpView
{
    lblLooking.text = @"I'm looking for";
    lblOr.text = @"Or";
    [btnGetOffers setTitle:@"GET OFFERS" forState:UIControlStateNormal];
    txtFirst.placeholder = @"0.00";
    txtSecond.placeholder = @"0.00";
    txtZipCode.placeholder = @"Zip Code";
    
    self.viewBuyMore.hidden = YES;
    tblOrder.hidden = YES;
    
}
- (void)setUIViewScreen
{
    if(ordersArray.count != 0)
    {
        self.hightBuyMoreConstraint.constant = 65;
        self.viewBuyMore.hidden = NO;
        tblOrder.hidden = NO;
        [tblOrder reloadData];
    }
    else
    {
        self.orderView.hidden = YES;
    }
}

#pragma mark - WebServices Call


- (void)getOrderList
{
    // For Existing User
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    NSString *token = [BRHelprClass getAuthToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"X-Coins-Api-Token"];
    [manager GET:GetOrderList parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hideAnimated:YES];
        //NSLog(@"JSON: %@", responseObject);
        NSError *e=nil;
        
        
        NSArray *resArray = (NSArray*)responseObject;
        
        ordersArray = [[NSMutableArray alloc]initWithArray:resArray];
        
        
      [self setUIViewScreen];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        
        //  NSLog(@"%@",ErrorResponse);
        
        //NSLog(@"CODE : %ld",(long)operation.response.statusCode);
        //NSLog(@"description : %ld",(long)operation.response.description);
        [hud hideAnimated:YES];
        
        if(operation.response.statusCode == 403)
        {
             [BRHelprClass removeAuthToken];
        }
        
        NSLog(@"Error: %@", error);
      
        [self setUIViewScreen];
    }];
    
}

//Set Web Service Parameter Methods
- (NSMutableDictionary *)setDiscoveryParameters
{
    /*"publisherId": "",
     "cryptoAddress": "",
     "usdAmount": "500",
     "crypto": "DASH",
     "bank": "",
     "zipCode": "34236"
     */
    
    
    NSInteger usdAmount;
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    manager.localCurrencyCode = manager.currencyCodes[0];
    
    double textValue = [txtFirst.text doubleValue];
    usdAmount = (textValue * manager.localCurrencyDashPrice.doubleValue);
    
    manager.localCurrencyCode = tempCurrencyCode;
    
    if(pubId == nil)
    {
        pubId = @"";
    }
    
    NSDictionary *retVal =  @{@"publisherId" : pubId,@"cryptoAddress":@"", @"usdAmount":[NSString stringWithFormat:@"%ld",(long)usdAmount],@"crypto":@"DASH",@"bank":@"",@"zipCode":txtZipCode.text};
    
   // NSLog(@"PARAM : %@",retVal);
    
    return [[NSMutableDictionary alloc] initWithDictionary:retVal];
}
- (void)discoveryInputsApiCall
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableDictionary *dicParameters = [self setDiscoveryParameters];
    
    [BRWebServices callPostWithURLString:DiscoveryInputs withParameters:dicParameters withViewCtr:self withSuccessCompletionHandler:^(id responseObject) {
        
        if (responseObject) {
             [hud hideAnimated:YES];
            NSDictionary *dicResponse = (NSDictionary*)responseObject;
           // NSLog(@"Response : %@",dicResponse);
            
            
            NSString *disId = dicResponse[@"id"];
            
            //NSLog(@"%@",disId);
            //https://wallofcoins.com/

            dispatch_async(dispatch_get_main_queue(), ^{
                [self getOffersApiCall:[NSString stringWithFormat:@"https://wallofcoins.com//api/v1/discoveryInputs/%@/offers/",disId]];
            });
        }
        else{
            [hud hideAnimated:YES];
           
            [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
        }
        
    } withFailureCompletionHandler:^(AFHTTPRequestOperation *operation, NSError *error, BOOL Failure) {
        
        if (Failure && ![operation isCancelled]) {
            [hud hideAnimated:YES];
            [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
        }
        else
        {
            [hud hideAnimated:YES];
            [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
        }
    }];
}

-(void)getOffersApiCall:(NSString *)stringUrl
{
    
    // NSLog(@"%@",stringUrl);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableDictionary *dicParameters = [self setDiscoveryParameters];
   
    

    [BRWebServices callGetWithURL:stringUrl withParameters:nil withViewCtr:self withSuccessCompletionHandler:^(id responseObject) {
        
        if (responseObject) {
            [hud hideAnimated:YES];
            NSDictionary *dicResponse = (NSDictionary*)responseObject;
           // NSLog(@"Response : %@",dicResponse);
            
            if(dicResponse[@"singleDeposit"])
            {
               // NSLog(@"PRINT");
                
                offersArray = dicResponse[@"singleDeposit"];
                
                [self getOffersResponse];
                
            }
        }
        else{
            [hud hideAnimated:YES];
            [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
        }
        
    } withFailureCompletionHandler:^(AFHTTPRequestOperation *operation, NSError *error, BOOL Failure) {
        
        if (Failure && ![operation isCancelled]) {
            [hud hideAnimated:YES];
           [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
        }
        else
        {
            [hud hideAnimated:YES];
            [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
        }
    }];
}
- (void)getOffersResponse
{
    if(offersArray.count > 0)
    {
        // sell dash for cash
        [BREventManager saveEvent:@"buy_dash:cash_offers"];
        BROfferViewController *brOffer
        = [self.storyboard instantiateViewControllerWithIdentifier:@"BROfferVC"];
        brOffer.Arrayoffers = offersArray;
        [self.navigationController pushViewController:brOffer animated:YES];
    }
    else
    {
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:@"No any offer available" withViewController:self];
    
    }
}
- (void)ConfirmDepositApiCall:(NSString*)ordId{
    /*
     X-Coins-Api-Token
     Id
     */
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    

    
   // NSLog(@"oId : %@",ordId);
    
    NSString *authUrl = [NSString stringWithFormat:@"https://wallofcoins.com/api/v1/orders/%@/confirmDeposit/",ordId];
    
    //api/v1/orders/{holdId}/confirmDeposit/
    
    NSString *token = [BRHelprClass getAuthToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"X-Coins-Api-Token"];
    [manager POST:authUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hideAnimated:YES];
        //NSLog(@"JSON: %@", responseObject);
        NSError *e=nil;
        
        [self getOrderList];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [hud hideAnimated:YES];
        NSLog(@"Error: %@", error);
       
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
    }];
    
}

- (void)CancelApiCall:(NSString*)ordId{
    /*
     X-Coins-Api-Token
     orderId
     
     */
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    //NSString *oId = self.orderDetailDict[@"id"];
    
   // NSLog(@"oId : %@",ordId);
    
    NSString *authUrl = [NSString stringWithFormat:@"https://wallofcoins.com/api/v1/orders/%@/",ordId];
    
    //api/v1/orders/{orderId}/
    
    NSString *token = [BRHelprClass getAuthToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"X-Coins-Api-Token"];
    [manager DELETE:authUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hideAnimated:YES];
       // NSLog(@"JSON: %@", responseObject);
        NSError *e=nil;
        
        [self getOrderList];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [hud hideAnimated:YES];
        NSLog(@"Error: %@", error);
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
    }];
    
}

#pragma mark - UITextBox Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");
    
    if (isBackSpace == -8) {
        
        return YES;
    }
    
    
    /*  limit to only numeric characters  */
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            return YES;
        }
    }
    return NO;
}
-(void)textChanged:(UITextField *)textField
{
    txtFirst.placeholder = @"0.00";
    txtSecond.placeholder = @"0.00";
    
    if(textField == txtFirst)
    {
        double textValue = [textField.text doubleValue];
        txtSecond.text = [NSString stringWithFormat:@"%.2f",textValue*dashAmount];
    }
    
    if(textField == txtSecond)
    {
        double textValue = [textField.text doubleValue];
        txtFirst.text = [NSString stringWithFormat:@"%.2f",textValue/dashAmount];
    }
}


#pragma mark - UIView Action Methods
- (IBAction)SelBuyMore:(id)sender
{
    self.orderView.hidden = YES;
}

- (IBAction)SelGetOffers:(id)sender
{
    [self.view endEditing:true];
    
    if([txtFirst.text length] == 0)
    {
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:@"Enter dash amount" withViewController:self];
    }
    else if([txtSecond.text length] == 0)
    {
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:@"Enter currency amount" withViewController:self];
    }
    else if([txtZipCode.text length] == 0)
    {
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:@"Enter zip code" withViewController:self];
    }
    else
    {
        [self discoveryInputsApiCall];
    }

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ordersArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"BROrderCell1";
    
    NSMutableDictionary *currentDict = [ordersArray objectAtIndex:indexPath.row];
    
   // NSLog(@"%@",currentDict);
    
    BROrderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    
    cell.imgBank.layer.cornerRadius = 5.0;
    cell.imgBank.layer.masksToBounds = YES;
    
    
    NSString *imgStr = currentDict[@"bankLogo"];
    NSURL *imgUrl = [NSURL URLWithString:imgStr];
    if(imgStr.length != 0)
    {
        [cell.imgBank sd_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:nil];
    }
    
    NSDictionary *nearestDict = currentDict[@"nearestBranch"];
    
    cell.lblName.text = currentDict[@"bankName"];
    
    cell.lblPhone.text = nearestDict[@"phone"];
    
   
    NSString *strStatus;
    
    strStatus = currentDict[@"status"];
    
    
    if(self.viewBuyMore.hidden == NO)
    {
        if([strStatus isEqualToString:@"WD"])
        {
            self.viewBuyMore.hidden = YES;
            self.hightBuyMoreConstraint.constant = 0;
        }
    }
    
    
    
    cell.lblStatus.text = [BRHelprClass getStatusString:currentDict[@"status"]];
    
    cell.lblNameAcc.text = currentDict[@"nameOnAccount"];
    cell.lblAcc.text = currentDict[@"account"];
    cell.lblCashDep.text = currentDict[@"payment"];
    cell.lblDepDue.text = currentDict[@"paymentDue"];
    
    
    
    cell.lblSPhone.text = @"Phone:";
    cell.lblSStatus.text = @"Status:";
    cell.lblSNameAcc.text = @"Name on Account:";
    cell.lblSAcc.text = @"Account #:";
    cell.lblSCashDep.text = @"Cash to Deposit:";
    cell.lblSDepDue.text = @"Deposit Due:";
    
    [cell.btnDeposite setTitle:@"DEPOSIT FINISHED" forState:UIControlStateNormal];
    [cell.btnCancel setTitle:@"CANCEL ORDER" forState:UIControlStateNormal];
    
 
    cell.backgroundColor = [UIColor clearColor];
    cell.viewBack.layer.cornerRadius = 5.0;
    cell.viewBack.layer.shadowColor = [UIColor grayColor].CGColor;
    cell.viewBack.layer.shadowOpacity = 0.5;
    cell.viewBack.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    cell.viewBack.layer.shadowRadius = 5.0;
    
    if([strStatus isEqualToString:@"WD"])
    {
        cell.bottomView.hidden = NO;
    }
    else
    {
        cell.bottomView.hidden = YES;
    }
    
    cell.btnCancel.tag = indexPath.row;
    cell.btnDeposite.tag = indexPath.row;
    
    [cell.btnDeposite addTarget:self               action:@selector(selDeposit:) forControlEvents:UIControlEventTouchDown];
    
    [cell.btnCancel addTarget:self               action:@selector(selCancel:) forControlEvents:UIControlEventTouchDown];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSMutableDictionary *currentDict = [ordersArray objectAtIndex:indexPath.row];
    
    NSString *strStatus;
    strStatus = currentDict[@"status"];
    
    if([strStatus isEqualToString:@"WD"])
    {
        return 290;
    }
    else
    {
        return 190;
    }
}
-(void)selDeposit:(UIButton*)sender
{
    NSMutableDictionary *currentDict = [ordersArray objectAtIndex:sender.tag];
    
    NSString *oId = currentDict[@"id"];
    
    [self ConfirmDepositApiCall:oId];
    
    
}
-(void)selCancel:(UIButton*)sender
{
    NSMutableDictionary *currentDict = [ordersArray objectAtIndex:sender.tag];
    
    NSString *oId = currentDict[@"id"];
    
    [self CancelApiCall:oId];
}
@end
