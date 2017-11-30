//
//  BRWebServices.h
//  dashwallet
//
//  Created by Viral on 20/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRImportClasses.h"


@interface BRWebServices : NSObject
/*----- post Method -----*/
+ (void)callPostWithURLString:(NSString*)strMethod withParameters:(NSMutableDictionary*)dicParameters withViewCtr:(UIViewController*)viewCtr withSuccessCompletionHandler:(void (^)(id responseObject))successCompletion withFailureCompletionHandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error, BOOL Failure))failureCompletion;

/*----- get Method -----*/
+ (void)callGetWithURL:(NSString*)urlString withParameters:(NSMutableDictionary*)dicParameters withViewCtr:(UIViewController*)viewCtr withSuccessCompletionHandler:(void (^)(id responseObject))successCompletion withFailureCompletionHandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error, BOOL Failure))failureCompletion;
@end
