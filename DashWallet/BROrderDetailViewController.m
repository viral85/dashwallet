//
//  BROrderDetailViewController.m
//  dashwallet
//
//  Created by Viral on 23/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BROrderDetailViewController.h"
#import "BRImportClasses.h"
#import "BRBuyDashViewController.h"

@interface BROrderDetailViewController ()

@end

@implementation BROrderDetailViewController

@synthesize lblAcc,lblName,lblNear,lblSAcc,lblPhone,lblDepDue,lblSPhone,lblStatus,lblCashDep,lblNameAcc,lblSDepDue,lblSStatus,lblSCashDep,lblSNameAcc,btnCancel,btnDeposit,imgOffer;

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self intialViewSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIView Method
- (void)intialViewSetup
{
    imgOffer.layer.cornerRadius = 5.0;
    imgOffer.layer.masksToBounds = YES;
    
    
    NSString *imgStr = self.orderDetailDict[@"bankLogo"];
    NSURL *imgUrl = [NSURL URLWithString:imgStr];
    if(imgStr.length != 0)
    {
        [imgOffer sd_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:nil];
    }
    
    NSDictionary *nearestDict = self.orderDetailDict[@"nearestBranch"];
    
    lblName.text = self.orderDetailDict[@"bankName"];
    lblNear.text = @"Near By Center";
    lblPhone.text = nearestDict[@"phone"];
    
   // lblStatus.text = self.orderDetailDict[@"status"];
    
    lblStatus.text = [BRHelprClass getStatusString:self.orderDetailDict[@"status"]];
    
    lblNameAcc.text = self.orderDetailDict[@"nameOnAccount"];
    lblAcc.text = self.orderDetailDict[@"account"];
    lblCashDep.text = self.orderDetailDict[@"payment"];
    lblDepDue.text = self.orderDetailDict[@"paymentDue"];
    
    
    
    lblSPhone.text = @"Phone:";
    lblSStatus.text = @"Status:";
    lblSNameAcc.text = @"Name on Account:";
    lblSAcc.text = @"Account #:";
    lblSCashDep.text = @"Cash to Deposit:";
    lblSDepDue.text = @"Deposit Due:";
    
    [btnDeposit setTitle:@"DEPOSIT FINISHED" forState:UIControlStateNormal];
    [btnCancel setTitle:@"CANCEL ORDER" forState:UIControlStateNormal];
    
}

#pragma mark - UIAction Method
- (IBAction)selDeposit:(id)sender
{
    [self ConfirmDepositApiCall];
}

- (IBAction)selCancel:(id)sender
{
    [self CancelApiCall];
}
#pragma mark - WebServices Call

- (void)ConfirmDepositApiCall{
    /*
     X-Coins-Api-Token
     Id
     */
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    NSString *oId = self.orderDetailDict[@"id"];
    
  //  NSLog(@"oId : %@",oId);
    
    NSString *authUrl = [NSString stringWithFormat:@"https://wallofcoins.com/api/v1/orders/%@/confirmDeposit/",oId];
    
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
      //  NSLog(@"JSON: %@", responseObject);
        NSError *e=nil;
        
         //[self alertDisplay:@"Your order deposit success"];
        
        [self moveToBuyDash];
        

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [hud hideAnimated:YES];
        NSLog(@"Error: %@", error);
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
    }];
    
}

- (void)CancelApiCall{
    /*
     X-Coins-Api-Token
     orderId

     */
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    NSString *oId = self.orderDetailDict[@"id"];
    
   // NSLog(@"oId : %@",oId);
    
    NSString *authUrl = [NSString stringWithFormat:@"https://wallofcoins.com/api/v1/orders/%@/",oId];
    
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
        
      //  [self alertDisplay:@"Your order cancelled"];
        
        [self moveToBuyDash];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [hud hideAnimated:YES];
        NSLog(@"Error: %@", error);
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
    }];
    
}

- (void)moveToBuyDash
{
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[BRBuyDashViewController class]]) {
            [self.navigationController popToViewController:aViewController animated:NO];
        }
    }
}
@end
