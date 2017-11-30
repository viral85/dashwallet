//
//  BRHelprClass.h
//  dashwallet
//
//  Created by Viral on 22/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRImportClasses.h"

@interface BRHelprClass : NSObject
/*----- set authentication token -----*/
+ (void)setAuthToken:(NSString*)token;
+ (void)removeAuthToken;
+ (NSString*)getAuthToken;
+ (void)setHoldId:(NSString*)h_id;
+ (void)removeHoldId;
+ (NSString*)getHoldId;
+ (NSString*)getStatusString:(NSString*)shortStr;
+ (void)showAlertwithTitle:(NSString *)title withMessage:(NSString *)msg withViewController:(UIViewController *)viewCtr;
@end
