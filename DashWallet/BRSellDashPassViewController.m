//
//  BRSellDashPassViewController.m
//  dashwallet
//
//  Created by Viral on 28/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRSellDashPassViewController.h"
#import "BRImportClasses.h"
#import "BRSellDashAdsViewController.h"

@interface BRSellDashPassViewController ()
{
    NSMutableArray *arrayCurrency;
    NSMutableArray *arrayAds;
}

@end

@implementation BRSellDashPassViewController

@synthesize txtPassword,btnNext,lblInstruction;

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrayCurrency = [[NSMutableArray alloc]init];
    arrayAds = [[NSMutableArray alloc]init];
    
    [self intialViewSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIView Method
- (void)intialViewSetup
{
    if (self.userAvability == 0)
    {
        lblInstruction.text = @"Login to Register New Account";
    }
    else
    {
        lblInstruction.text = @"Existing Account Login";
    }
    [btnNext setTitle:@"Next" forState:UIControlStateNormal];
    txtPassword.placeholder = @"Password";
    
}

#pragma mark - UIAction Method

- (IBAction)selNext:(id)sender
{
    [self.view endEditing:true];
    
    if([txtPassword.text length] == 0)
    {
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:@"Please your password" withViewController:self];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
                [self getAuthTokenApiCall];
            });
    }
    
}

#pragma mark - WebServices Call
- (void)getAuthTokenApiCall
{
    // For Existing User
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *retVal =  @{@"password":txtPassword.text};
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithDictionary:retVal];
    
    
    NSString *authUrl = [NSString stringWithFormat:@"https://wallofcoins.com/api/v1/auth/%@/authorize/",self.phoneNumber];
    
    //  NSLog(@"Auth URL : %@",authUrl);
    
    //api/v1/auth/{phone}/authorize/
    
    
    [BRWebServices callPostWithURLString:authUrl withParameters:param withViewCtr:self withSuccessCompletionHandler:^(id responseObject) {
        
        if (responseObject) {
            [hud hideAnimated:YES];
            NSDictionary *dicResponse = (NSDictionary*)responseObject;
            //  NSLog(@"Response : %@",dicResponse);
            
            NSString *userToken = dicResponse[@"token"];
            //   NSLog(@"TOKEN %@",userToken);
            
            if(userToken.length != 0)
            {
                [BRHelprClass setAuthToken:userToken];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getCurruncyApiCall];
                });
                
            }
            else
            {
                [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
            }
            
        }
        else{
            [hud hideAnimated:YES];
            [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
        }
        
    } withFailureCompletionHandler:^(AFHTTPRequestOperation *operation, NSError *error, BOOL Failure) {
        
        // NSLog(@"CODE : %ld",(long)operation.response.statusCode);
        
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

- (void)getCurruncyApiCall
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
    [manager GET:GetCurrency parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hideAnimated:YES];
        //NSLog(@"JSON: %@", responseObject);
        NSError *e=nil;
        
        
        NSArray *resArray = (NSArray*)responseObject;
        
        arrayCurrency = [[NSMutableArray alloc]initWithArray:resArray];
        
        [self getAdsListingApiCall];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        
        //  NSLog(@"%@",ErrorResponse);
        
        //NSLog(@"CODE : %ld",(long)operation.response.statusCode);
        //NSLog(@"description : %ld",(long)operation.response.description);
        [hud hideAnimated:YES];
        
        NSLog(@"Error: %@", error);
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
       
    }];
    
}
- (void)getAdsListingApiCall
{
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // NSString *offerId = [self.offerDict objectForKey:@"id"];
    
    // NSDictionary *retVal =  @{@"offer" : offerId};
    
    // NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithDictionary:retVal];
    
    NSString *token = [BRHelprClass getAuthToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"X-Coins-Api-Token"];
    [manager POST:GetAdsList parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hideAnimated:YES];
        NSLog(@"JSON: %@", responseObject);
        NSError *e=nil;
        

        NSArray *resArray = (NSArray*)responseObject;
        
        arrayAds = [[NSMutableArray alloc]initWithArray:resArray];
        
        [self moveToAdsScreen];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //operation.response.statusCode
        [hud hideAnimated:YES];
        //NSLog(@"Error: %@", error);
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
    }];
    
}
- (void)moveToAdsScreen
{
    [BREventManager saveEvent:@"sell_dash:create_ad"];
    BRSellDashAdsViewController *authObj
    = [self.storyboard instantiateViewControllerWithIdentifier:@"BRSellDashAdsVC"];
    
    authObj.DictCurrency = self.DictCurr;
    authObj.ArrayAds = arrayAds;
    authObj.ArrayCurrency = arrayCurrency;
    
    [self.navigationController pushViewController:authObj animated:YES];
}

@end
