//
//  BRHelprClass.m
//  dashwallet
//
//  Created by Viral on 22/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRHelprClass.h"


@implementation BRHelprClass

+ (void)setAuthToken:(NSString*)token
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"] != nil)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"UserToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)removeAuthToken
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString*)getAuthToken
{
    NSString *authToken;
    authToken = @"";
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"] != nil)
    {
         authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserToken"];
    }
    return authToken;
}
+ (void)setHoldId:(NSString*)h_id
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"HoldId"] != nil)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HoldId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:h_id forKey:@"HoldId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)removeHoldId
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HoldId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString*)getHoldId
{
    NSString *holdid;
    holdid = @"";
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"HoldId"] != nil)
    {
        holdid = [[NSUserDefaults standardUserDefaults] stringForKey:@"HoldId"];
    }
    return holdid;
}
+ (NSString*)getStatusString:(NSString*)shortStr
{
    NSString *myReturnStr;
    
    if([shortStr isEqualToString:@"WD"])
    {
        myReturnStr = @"Waiting Deposit";
    }
    else if([shortStr isEqualToString:@"WDV"])
    {
        myReturnStr = @"Waiting Deposit Verification";
    }
    else if([shortStr isEqualToString:@"RERR"])
    {
        myReturnStr = @"Issue w/ Receipt, Contacted Buyer";
    }
    else if([shortStr isEqualToString:@"DERR"])
    {
        myReturnStr = @"Issue with Deposit, Needs Follow-up";
    }
    else if([shortStr isEqualToString:@"RSD"])
    {
        myReturnStr = @"Reserved for Seller Deposit";
    }
    else if([shortStr isEqualToString:@"RMIT"])
    {
        myReturnStr = @"Remit Address Missing";
    }
    else if([shortStr isEqualToString:@"UCRV"])
    {
        myReturnStr = @"Under Compliance Review";
    }
    else if([shortStr isEqualToString:@"PAYP"])
    {
        myReturnStr = @"Done - Pending Delivery";
    }
    else if([shortStr isEqualToString:@"SENT"])
    {
        myReturnStr = @"Done - Units Delivered";
    }
    else if([shortStr isEqualToString:@"CANC"])
    {
        myReturnStr = @"Buyer Canceled";
    }
    else if ([shortStr isEqualToString:@"ACAN"])
    {
        myReturnStr = @"Staff Canceled";
    }
    else if ([shortStr isEqualToString:@"EXP"])
    {
        myReturnStr = @"Deposit Time Expired";
    }
    else if([shortStr isEqualToString:@"ML"])
    {
        myReturnStr = @"Meat Locker";
    }
    else if([shortStr isEqualToString:@"MLR"])
    {
        myReturnStr = @"Meat Locker Returned";
    }
    else
    {
        myReturnStr = @"";
    }


    return myReturnStr;
}
+ (void)showAlertwithTitle:(NSString *)title withMessage:(NSString *)msg withViewController:(UIViewController *)viewCtr
{
    UIAlertController * alert = [UIAlertController                                 alertControllerWithTitle:title                                 message:msg preferredStyle:UIAlertControllerStyleAlert];    UIAlertAction* okButton = [UIAlertAction                               actionWithTitle:@"OK"                               style:UIAlertActionStyleCancel                               handler:^(UIAlertAction * action) {                                   //exit(0);
        
    }];
    [alert addAction:okButton];
    [viewCtr presentViewController:alert animated:YES completion:nil];
    
}
@end
