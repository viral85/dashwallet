//
//  BRSellDashAdsViewController.m
//  dashwallet
//
//  Created by Viral on 29/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRSellDashAdsViewController.h"
#import "BRImportClasses.h"
#import "BRTableSelViewController.h"

@interface BRSellDashAdsViewController ()
{
    NSMutableArray *arrayBank;
    NSInteger selectedBankIndex;
}
@end

@implementation BRSellDashAdsViewController

@synthesize txtAccountNo,txtConfirmAcc,txtAccountName,lblSelectPrice,btnSelectAccount;

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrayBank = [[NSMutableArray alloc]init];
    
    [self setupInitialView];
    
    [self getBankListApiCall];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSelBankNameNotification:) name:@"UpdateBankName" object:nil];
    
    selectedBankIndex = -1;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIView Method
- (void)setupInitialView
{
    [btnSelectAccount setTitle:@"Select Your Cash Account" forState:UIControlStateNormal];
    txtAccountName.placeholder = @"Name on Account";
    txtAccountNo.placeholder = @"Account #";
    txtConfirmAcc.placeholder = @"Confirm Account #";
    lblSelectPrice.text = @"SELECT PRICING OPTIONS";
    
}
-(void)receiveSelBankNameNotification:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    NSString *check = [dict objectForKey:@"SelObjIndex"];
    NSDictionary *objDict = [arrayBank objectAtIndex:[check integerValue]];
    selectedBankIndex = [check integerValue];
    [btnSelectAccount setTitle:[objDict objectForKey:@"name"] forState:UIControlStateNormal];

}
#pragma mark - UIAction Method
- (IBAction)selAccountAct:(id)sender
{

    [BREventManager saveEvent:@"sell_dash:select_account"];
    BRTableSelViewController *authObj
    = [self.storyboard instantiateViewControllerWithIdentifier:@"BRTableSelVC"];
    
    authObj.ArrayOpt = arrayBank;
    authObj.tblType = 1;
    authObj.selectedCell = selectedBankIndex;
    [self.navigationController presentViewController:authObj animated:YES completion:nil];
    
}

- (IBAction)selCreateAdAct:(id)sender {
}

- (IBAction)selPrimarktAct:(id)sender {
}

- (IBAction)selSecdmerktAct:(id)sender {
}

- (IBAction)selCurrAct:(id)sender {
}

#pragma mark - WebServices Call
- (void)getBankListApiCall
{
    
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    
    NSLog(@"C : %@",countryCode);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *retVal =  @{@"country":countryCode};
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithDictionary:retVal];
    
    
    NSString *token = [BRHelprClass getAuthToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"X-Coins-Api-Token"];
    [manager POST:GetBankList parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hideAnimated:YES];
        NSLog(@"JSON: %@", responseObject);
        NSError *e=nil;
        
        
        NSArray *resArray = (NSArray*)responseObject;
        
        arrayBank = [[NSMutableArray alloc]initWithArray:resArray];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //operation.response.statusCode
        [hud hideAnimated:YES];
        //NSLog(@"Error: %@", error);
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
    }];
    
}
@end
