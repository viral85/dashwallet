//
//  DWSpork.m
//  dashwallet
//
//  Created by Sam Westrich on 10/18/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "DWSpork.h"
#import "NSData+Dash.h"
#import "NSData+Bitcoin.h"
#import "BRKey.h"

#define SPORK_PUBLIC_KEY @"04549ac134f694c0243f503e8c8a9a986f5de6610049c40b07816809b0d1d06a21b07be27b9bb555931773f62ba6cf35a25fd52f694d4e1106ccd237a7bb899fdd"
#define SPORK_MESSAGE_MAGIC @"Darkcoin Signed Message"

@implementation DWSpork


+ (instancetype)sporkWithMessage:(NSData *)message
{
    return [[DWSpork alloc] initWithMessage:message];
}

- (instancetype)initWithMessage:(NSData *)message
{
    if (! (self = [self init])) return nil;
    
    _identifier = [message UInt32AtOffset:0];
    _value = [message UInt64AtOffset:4];
    _timeSigned = [message UInt64AtOffset:12];
    NSNumber * lNumber = nil;
    NSData * signature = [message dataAtOffset:20 length:&lNumber];
    NSUInteger l = lNumber.unsignedIntegerValue;
    _valid = [self checkSignature:signature];
    return self;
}

-(BOOL)checkSignature:(NSData*)signature {
    NSString * stringMessage = [NSString stringWithFormat:@"%@%d%llu%llu",SPORK_MESSAGE_MAGIC,self.identifier,self.value,self.timeSigned];
    BRKey * sporkPublicKey = [BRKey keyWithPublicKey:[NSData dataFromHexString:SPORK_PUBLIC_KEY]];
    UInt256 messageDigest = [stringMessage dataUsingEncoding:NSUTF8StringEncoding].SHA256;
    return [sporkPublicKey verify:messageDigest signature:signature];
}

@end
