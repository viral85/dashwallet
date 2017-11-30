//
//  BROfferViewController.m
//  dashwallet
//
//  Created by Viral on 21/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BROfferViewController.h"
#import "BROfferCell.h"
#import "BRImportClasses.h"
#import "BRAuthFirstViewController.h"
#import "BRConfirmViewController.h"
#import "BRBuyDashViewController.h"

@interface BROfferViewController ()

@end

@implementation BROfferViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.Arrayoffers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"BROfferCell1";
    
    NSMutableDictionary *currentDict = [self.Arrayoffers objectAtIndex:indexPath.row];
    
    //NSLog(@"%@",currentDict);
    
    BROfferCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSMutableDictionary *amountDict = [currentDict objectForKey:@"amount"];
    
   // NSLog(@"%@",amountDict);
    
    double dist = [[currentDict objectForKey:@"distance"] doubleValue];
    
  
    
    NSString *imgStr = [currentDict objectForKey:@"bankLogo"];
    
    NSURL *imgUrl = [NSURL URLWithString:imgStr];
    
    if(imgStr.length != 0)
    {
        [cell.imgIcon sd_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:nil];
    }

    cell.lblFirst.text = [amountDict objectForKey:@"DASH"];
    cell.lblSecond.text = [amountDict objectForKey:@"dots"];
    cell.lblThird.text = [currentDict objectForKey:@"bankName"];
    cell.lblFour.text = [currentDict objectForKey:@"address"];
    cell.lblFive.text = [NSString stringWithFormat:@"%.2f miles - %@,%@",dist,[currentDict objectForKey:@"city"],[currentDict objectForKey:@"state"]];
    cell.btnOrder.tag = indexPath.row;
    [cell.btnOrder addTarget:self
               action:@selector(selOrder:) forControlEvents:UIControlEventTouchDown];

    return cell;
}
-(void)selOrder:(UIButton*)sender
{
    NSMutableDictionary *currentDict = [self.Arrayoffers objectAtIndex:sender.tag];
    
    NSString *offerId = [currentDict objectForKey:@"id"];
    
    NSString *userToken = [BRHelprClass getAuthToken];
   // NSLog(@"TOKEN %@",userToken);
    
    if(userToken.length != 0)
    {
        [self createHoldApiCall:offerId];
    }
    else
    {
        [BREventManager saveEvent:@"buy_dash:get_auth_first"];
        BRAuthFirstViewController *authObj
        = [self.storyboard instantiateViewControllerWithIdentifier:@"BRAuthFirstVC"];
        authObj.offerDict = currentDict;
        
        [self.navigationController pushViewController:authObj animated:YES];
    }
    
}
#pragma mark - WebServices Call
- (void)createHoldApiCall:(NSString*)offId
{
    // For Existing User
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSDictionary *retVal =  @{@"offer" : offId};
    
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
        
        
        NSString *holdid = dicResponse[@"id"];
       // NSLog(@"holdid %@",holdid);
        
        if(holdid.length != 0)
        {
            [BRHelprClass setHoldId:holdid];
        }
        
        [self moveToConfirmView:dicResponse[@"id"]];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        
      //  NSLog(@"%@",ErrorResponse);
        
        //NSLog(@"CODE : %ld",(long)operation.response.statusCode);
        //NSLog(@"description : %ld",(long)operation.response.description);
        [hud hideAnimated:YES];
        
        if(operation.response.statusCode == 400)
        {
            // GET ORDER LIST
            [self getOrderList];
        }
        else
        {
            NSLog(@"Error: %@", error);
            
            [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
        }

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
       // NSLog(@"JSON: %@", responseObject);
        NSError *e=nil;
        
        NSDictionary *dicResponse = (NSDictionary*)responseObject;
        
    
        [self moveToConfirmView:dicResponse[@"id"]];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        

        [hud hideAnimated:YES];
    
        NSLog(@"Error: %@", error);
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
    }];
    
}
- (void)moveToConfirmView:(NSString*)holdId
{
    [BREventManager saveEvent:@"buy_dash:offer_confirm"];
    BRConfirmViewController *authObj
    = [self.storyboard instantiateViewControllerWithIdentifier:@"BRConfirmVC"];
    authObj.holdiD = holdId;
    [self.navigationController pushViewController:authObj animated:YES];
}

@end
