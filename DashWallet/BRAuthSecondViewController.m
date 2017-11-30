//
//  BRAuthSecondViewController.m
//  dashwallet
//
//  Created by Viral on 22/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRAuthSecondViewController.h"
#import "BRImportClasses.h"
#import "BRConfirmViewController.h"
#import "BRBuyDashViewController.h"

@interface BRAuthSecondViewController ()
{
    NSString *holdid;
}

@end

@implementation BRAuthSecondViewController

@synthesize txtPassword,btnNext,lblInstruction;

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //
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
        if (self.userAvability == 0)
        {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createHoldWithPasswordApiCall];
            });
        }
        else
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getAuthTokenApiCall];
            });
            
            
            
        }

    }
    
}

#pragma mark - WebServices Call
- (void)createHoldWithPasswordApiCall
{
    // For New User
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    /*
     offer
     phone
     password

     */
    
    NSString *offerId = [self.offerDict objectForKey:@"id"];
    
    NSDictionary *retVal =  @{@"offer" : offerId,@"phone":self.phoneNumber, @"password":txtPassword.text};
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithDictionary:retVal];
    
    [BRWebServices callPostWithURLString:CreateHold withParameters:param withViewCtr:self withSuccessCompletionHandler:^(id responseObject) {
        
        if (responseObject) {
            [hud hideAnimated:YES];
            NSDictionary *dicResponse = (NSDictionary*)responseObject;
            // NSLog(@"Response : %@",dicResponse);
    
           
            
            holdid = dicResponse[@"id"];
        
            if(holdid.length != 0)
            {
                [BRHelprClass setHoldId:holdid];
            }
            
            
            NSString *userToken = dicResponse[@"token"];
           // NSLog(@"TOKEN %@",userToken);
            
            if(userToken.length != 0)
            {
                [BRHelprClass setAuthToken:userToken];
                [self moveToConfirmView];
            }
            else
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getAuthTokenApiCall];
                });
               
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
                   [self createHoldApiCall];
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
- (void)createHoldApiCall
{
    // For Existing User
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *offerId = [self.offerDict objectForKey:@"id"];
    
    NSDictionary *retVal =  @{@"offer" : offerId};
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithDictionary:retVal];
    
    NSString *token = [BRHelprClass getAuthToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
   
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"X-Coins-Api-Token"];
    [manager POST:CreateHold parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hideAnimated:YES];
      //  NSLog(@"JSON: %@", responseObject);
        NSError *e=nil;
        
        NSDictionary *dicResponse = (NSDictionary*)responseObject;
        //NSLog(@"Response : %@",dicResponse);
        
        holdid = dicResponse[@"id"];
        
        if(holdid.length != 0)
        {
            [BRHelprClass setHoldId:holdid];
        }
        
        [self moveToConfirmView];
        
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(operation.response.statusCode == 403)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if(operation.response.statusCode == 400)
        {
            [self getOrderList];
        }
        
        [hud hideAnimated:YES];
        //NSLog(@"Error: %@", error);
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
    }];
    
}
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
        
        if(resArray.count == 0)
        {
            [self moveToConfirmView];
        }
        else
        {
            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController *aViewController in allViewControllers) {
                if ([aViewController isKindOfClass:[BRBuyDashViewController class]]) {
                    [self.navigationController popToViewController:aViewController animated:NO];
                }
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        
        //  NSLog(@"%@",ErrorResponse);
        
        //NSLog(@"CODE : %ld",(long)operation.response.statusCode);
        //NSLog(@"description : %ld",(long)operation.response.description);
        [hud hideAnimated:YES];
        
       
        
        NSLog(@"Error: %@", error);
        // [self alertDisplay:SomthingErrorMsg];
    
    }];
    
}
- (void)moveToConfirmView
{
    [BREventManager saveEvent:@"buy_dash:offer_confirm"];
    BRConfirmViewController *authObj
    = [self.storyboard instantiateViewControllerWithIdentifier:@"BRConfirmVC"];
    authObj.holdiD = holdid;
    [self.navigationController pushViewController:authObj animated:YES];
}
@end
