//
//  DCShapeshiftManager.m
//  DashWallet
//
//  Created by Quantum Explorer on 7/14/15.
//  Copyright (c) 2015 Aaron Voisine. All rights reserved.
//

#import "DCShapeshiftManager.h"

#define SHAPESHIFT_PUBLIC_KEY @"9bcdf9343a4548c6268e1ee99e6bb43af95e88eb532f4e807b423adb7a96e54664b9c3d1130f3386c005b353402c9e7698236d1e21807b8b87d64dc605552f4a"

@implementation DCShapeshiftManager

+ (instancetype)sharedInstance
{
    static id singleton = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        singleton = [self new];
    });
    
    return singleton;
}

- (NSString *)percentEscapeString:(NSString *)string
{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary
{
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
            [parameterArray addObject:param];
        } else {
            NSString *param = [NSString stringWithFormat:@"%@=%@", key, obj];
            [parameterArray addObject:param];
        }
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

-(void)GET_marketInfo:(void (^)(NSDictionary *marketInfo, NSError *error))completionBlock {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://shapeshift.io/marketinfo/dash_btc"]
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (((((NSHTTPURLResponse*)response).statusCode /100) != 2) || connectionError) {
                                   NSError * returnError = connectionError;
                                   if (!returnError) {
                                       returnError = [NSError errorWithDomain:@"DashWallet" code:((NSHTTPURLResponse*)response).statusCode userInfo:nil];
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionBlock(nil,returnError);
                                   });
                               }
                               NSError *error = nil;
                               NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                               if (error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionBlock(nil,error);
                                   });
                                   return;
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                   self.lastMarketInfoCheck = [NSDate date];
                                   self.rate = [dictionary[@"rate"] doubleValue];
                                   if (dictionary[@"limit"])
                                       self.limit = [[[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",dictionary[@"limit"]]] decimalNumberByMultiplyingByPowerOf10:8]
                                                 unsignedLongLongValue];
                                   if (dictionary[@"minimum"])
                                       self.min = [[[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",dictionary[@"minimum"]]] decimalNumberByMultiplyingByPowerOf10:8]
                                    unsignedLongLongValue];
                                   completionBlock(dictionary,nil);
                               });
                           }];
    
}

-(void)POST_ShiftWithAddress:(NSString*)withdrawalAddress returnAddress:(NSString*)returnAddress completionBlock:(void (^)(NSDictionary *shiftInfo, NSError *error))completionBlock {
    NSDictionary *params = @{@"withdrawal": withdrawalAddress, @"pair": @"dash_btc", @"returnAddress":returnAddress,@"apiKey":SHAPESHIFT_PUBLIC_KEY};
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://shapeshift.io/shift"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (((((NSHTTPURLResponse*)response).statusCode /100) != 2) || connectionError) {
                                   NSError * returnError = connectionError;
                                   if (!returnError) {
                                       returnError = [NSError errorWithDomain:@"DashWallet" code:((NSHTTPURLResponse*)response).statusCode userInfo:nil];
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionBlock(nil,returnError);
                                   });
                               }
                               NSError *error = nil;
                               NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                               if (error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionBlock(nil,error);
                                   });
                                   return;
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   completionBlock(dictionary,nil);
                               });

                           }];
}

-(void)POST_SendAmount:(NSNumber*)amount withAddress:(NSString*)withdrawalAddress returnAddress:(NSString*)returnAddress completionBlock:(void (^)(NSDictionary *shiftInfo, NSError *error))completionBlock {
    NSDictionary *params = @{@"amount":amount,@"withdrawal": withdrawalAddress, @"pair": @"dash_btc", @"returnAddress":returnAddress,@"apiKey":SHAPESHIFT_PUBLIC_KEY};
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://shapeshift.io/sendamount"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
    NSString * s = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (((((NSHTTPURLResponse*)response).statusCode /100) != 2) || connectionError) {
                                   NSError * returnError = connectionError;
                                   if (!returnError) {
                                       returnError = [NSError errorWithDomain:@"Shapeshift" code:((NSHTTPURLResponse*)response).statusCode userInfo:nil];
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionBlock(nil,returnError);
                                   });
                               }
                               NSError *error = nil;
                               NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                               if (error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionBlock(nil,error);
                                   });
                                   return;
                               }
                               if (dictionary[@"error"]) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionBlock(nil,[NSError errorWithDomain:@"Shapeshift" code:416 userInfo:@{NSLocalizedDescriptionKey:
                                                                                                                                                                dictionary[@"error"]
                                                                                                                                                            }]);
                                   });
                                   return;
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   completionBlock(dictionary[@"success"],nil);
                               });
                               
                           }];
}

-(void)GET_transactionStatusWithAddress:(NSString*)withdrawalAddress completionBlock:(void (^)(NSDictionary *transactionInfo, NSError *error))completionBlock {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://shapeshift.io/txStat/%@",withdrawalAddress]]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (((((NSHTTPURLResponse*)response).statusCode /100) != 2) || connectionError) {
                                   NSError * returnError = connectionError;
                                   if (!returnError) {
                                       returnError = [NSError errorWithDomain:@"DashWallet" code:((NSHTTPURLResponse*)response).statusCode userInfo:nil];
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionBlock(nil,returnError);
                                   });
                               }
                               NSError *error = nil;
                               NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                               if (error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completionBlock(nil,error);
                                   });
                                   return;
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   completionBlock(dictionary,nil);
                               });
                           }];
}

@end
