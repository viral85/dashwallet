//
//  BRConfirmViewController.m
//  dashwallet
//
//  Created by Viral on 22/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRConfirmViewController.h"
#import "BRImportClasses.h"
#import "BROrderDetailViewController.h"

@interface BRConfirmViewController ()
{
    NSString *pubId;
}

@property (nonatomic, strong) NSUserDefaults *groupDefs;
@property (nonatomic, strong) BRPaymentRequest *paymentRequest;

@end

@implementation BRConfirmViewController

@synthesize txtCode,lblInst,btnConfirm;

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self intialViewSetup];
}
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

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIView Method
- (void)intialViewSetup
{
   
    lblInst.text = @"Your Purchase Code has been sent via text message. Enter the code in the field below.";
    
    [btnConfirm setTitle:@"CONFIRM PURCHASE CODE" forState:UIControlStateNormal];
    txtCode.placeholder = @"Enter Code";
    
}

    
#pragma mark - UIAction Method
- (IBAction)selConfirm:(id)sender
{
    [self.view endEditing:true];
    
    if([txtCode.text length] == 0)
    {
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:@"Please your purchase code" withViewController:self];
    }
    else
    {
        [self CaptureHoldApiCall];
    }
}

#pragma mark - WebServices Call
- (void)CaptureHoldApiCall{
   /*
    X-Coins-Api-Token
    Id // hold Id
    publisherId
    verificationCode

    */
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    if(pubId == nil)
    {
        pubId = @"";
    }
    
    NSDictionary *retVal =  @{@"publisherId":pubId,@"verificationCode":txtCode.text};
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithDictionary:retVal];
    
    
     NSString *authUrl = [NSString stringWithFormat:@"https://wallofcoins.com/api/v1/holds/%@/capture/",self.holdiD];
    
    //api/v1/holds/{id}/capture/
    
    NSString *token = [BRHelprClass getAuthToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"X-Coins-Api-Token"];
    [manager POST:authUrl parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hideAnimated:YES];
        //NSLog(@"JSON: %@", responseObject);
        NSError *e=nil;
        
       
        
        NSArray *myArray = (NSArray*)responseObject;
       
       
        
        NSDictionary *myDict = [myArray objectAtIndex:0];
        
        [self moveToOrderDetail:myDict];
        
  
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [hud hideAnimated:YES];
        NSLog(@"Error: %@", error);
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
    }];
    
}
- (void)moveToOrderDetail:(NSDictionary*)resDict
{
    [BREventManager saveEvent:@"buy_dash:order_detail"];
    BROrderDetailViewController *authObj
    = [self.storyboard instantiateViewControllerWithIdentifier:@"BROrderDetailVC"];
    authObj.orderDetailDict = resDict;
    [self.navigationController pushViewController:authObj animated:YES];
}

@end
