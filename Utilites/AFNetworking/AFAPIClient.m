#import "AFAPIClient.h"


static NSString *const AFAppAPIBaseURLString = @"";

@implementation AFAPIClient

+ (instancetype)sharedClient {
	static AFAPIClient *_sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    _sharedClient = [[AFAPIClient alloc] initWithBaseURL:[NSURL URLWithString:AFAppAPIBaseURLString]];
	    _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        
        [_sharedClient.requestSerializer setAuthorizationHeaderFieldWithUsername:@"viral" password:@"sonawala123"];
        
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions: NSJSONReadingAllowFragments];

        [_sharedClient.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        [_sharedClient.requestSerializer setTimeoutInterval:MAXFLOAT];
        [_sharedClient.requestSerializer didChangeValueForKey:@"timeoutInterval"];

        [_sharedClient.requestSerializer setValue:@"application/json"  forHTTPHeaderField:@"Content-Type"];
        
        _sharedClient.responseSerializer.acceptableContentTypes = [_sharedClient.responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"application/json", @"text/json", @"text/javascript", @"application/x-www-form-urlencoded", @"text/html", @"application/javascript"]];

	});
	return _sharedClient;
}

- (void)cancelAllHTTPOperationsWithPath:(NSString *)path {

    NSArray *operations = self.operationQueue.operations;
    for (AFHTTPRequestOperation *operation in operations) {
        //NSLog(@"Path:%@",path);
        //NSLog(@"URL:%@",[operation.request.URL absoluteString]);
        NSString *url = [operation.request.URL absoluteString];
        //NSLog(@"%@ : %@", url, path);
        if ([url isEqualToString:path]) {

#if IS_DEBUG
            NSLog(@"---------------- Cancelled Path %@", path);
#endif
            [operation cancel];
        }
    }
}

@end
