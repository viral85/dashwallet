//
//  BRWebServices.m
//  dashwallet
//
//  Created by Viral on 20/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRWebServices.h"



@implementation BRWebServices
/*----- post Method -----*/
+ (void)callPostWithURLString:(NSString*)strMethod withParameters:(NSMutableDictionary*)dicParameters withViewCtr:(UIViewController*)viewCtr withSuccessCompletionHandler:(void (^)(id responseObject))successCompletion withFailureCompletionHandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error, BOOL Failure))failureCompletion
{
    [kAFClient cancelAllHTTPOperationsWithPath:strMethod];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
#if IS_DEBUG
    
    if (dicParameters.count > 0) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicParameters options:NSJSONWritingPrettyPrinted error:nil];
        
        NSString *someString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Request : %@\n-----------------------\nRequest : %@",strMethod,someString);
    }
    else
    {
        NSLog(@"Request : %@",strMethod);
    }
#endif
    
    [kAFClient POST:strMethod parameters:dicParameters success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
#if IS_DEBUG
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
            
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            NSLog(@"Response : %@",jsonString);
        }
#endif
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if (successCompletion){
                successCompletion(responseObject);
            }
        }
        else{
            if (successCompletion){
                successCompletion(nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (failureCompletion) {
            failureCompletion(operation, error, YES);
        }
        
    }];
}

/*----- get Method -----*/
+ (void)callGetWithURL:(NSString*)urlString withParameters:(NSMutableDictionary*)dicParameters withViewCtr:(UIViewController*)viewCtr withSuccessCompletionHandler:(void (^)(id responseObject))successCompletion withFailureCompletionHandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error, BOOL Failure))failureCompletion
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
#if IS_DEBUG
    NSLog(@"Request : %@",urlString);
#endif
    
    [kAFClient GET:urlString parameters:dicParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
#if IS_DEBUG
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSLog(@"Response : %@",jsonString);
#endif
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if (successCompletion){
                successCompletion(responseObject);
            }
        }
        else{
            if (successCompletion){
                successCompletion(nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (failureCompletion) {
            failureCompletion(operation, error, YES);
        }
        
    }];
    
}
@end
