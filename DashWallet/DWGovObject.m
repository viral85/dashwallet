//
//  DWGovObject.m
//  dashwallet
//
//  Created by Sam Westrich on 10/16/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "DWGovObject.h"
#import "NSData+Dash.h"
#import "NSData+Bitcoin.h"
#import "NSString+Dash.h"
#import "NSMutableData+Bitcoin.h"
#import "BRKey.h"

@interface DWGovObject()

@property (nonatomic,assign) NSString * dataString;
@property (nonatomic,strong) NSData * masternodeVInSignature;
@property (nonatomic,strong) NSData * signature;

@end

@implementation DWGovObject

+ (instancetype)govObjWithMessage:(NSData *)message
{
    return [[DWGovObject alloc] initWithMessage:message];
}

- (instancetype)initWithMessage:(NSData *)message
{
    if (! (self = [self init])) return nil;
    
    uint32_t offset = 0;
    _parentHash = [message hashAtOffset:0];
    offset += sizeof(UInt256);
    _revision = [message UInt32AtOffset:offset];
    offset += sizeof(uint32_t);
    _time = [message UInt64AtOffset:offset];
    offset += sizeof(uint64_t);
    _collateralhash = [message hashAtOffset:offset];
    offset += sizeof(UInt256);
    NSNumber * length = nil;
    self.dataString = [message stringAtOffset:offset length:&length];
    offset += [length unsignedIntegerValue];
    length = nil;
    _type = [message UInt32AtOffset:offset];
    offset += sizeof(uint32_t);
    _masternodeVInHash = [message hashAtOffset:offset];
    offset += sizeof(UInt256);
    self.masternodeVInSignature = [message dataAtOffset:offset length:&length];
    offset += length.unsignedIntegerValue;
    length = 0;
    self.signature = [message dataAtOffset:offset length:&length];
    _valid = [self checkSignature:self.signature];
    return self;
}

//- (instancetype)initWithIdentifier:(SporkIdentifier)identifier value:(uint64_t)value timeSigned:(uint64_t)timeSigned signature:(NSData*)signature {
//    if (! (self = [self init])) return nil;
//    _identifier = identifier;
//    _value = value;
//    _timeSigned = timeSigned;
//    _valid = TRUE;
//    self.signature = signature;
//    return self;
//}

-(BOOL)isEqualToGovObject:(DWGovObject*)govObject {
    return (uint256_eq(self.parentHash,govObject.parentHash) && (self.revision == govObject.revision) && (self.time == govObject.time) && uint256_eq(self.collateralhash,govObject.collateralhash) && (self.dataString == govObject.dataString) && (self.type == govObject.type) && ([self.masternodeVInSignature isEqualToData:govObject.masternodeVInSignature]) && (self.signature == govObject.signature));
}

-(BOOL)checkSignature:(NSData*)signature {
    return TRUE;
//    NSString * stringMessage = [NSString stringWithFormat:@"%@|%u|%llu|%@|%@|%@",[NSString hexWithUInt256:self.parentHash],self.revision,self.time,self.dataString,[NSString hexWithUInt256:self.masternodeVInHash],[NSString hexWithUInt256:self.collateralhash]];
//    NSMutableData * stringMessageData = [NSMutableData data];
//    [stringMessageData appendString:DASH_MESSAGE_MAGIC];
//    [stringMessageData appendString:stringMessage];
//    BRKey * sporkPublicKey = [BRKey keyWithPublicKey:[NSData dataFromHexString:SPORK_PUBLIC_KEY]];
//    UInt256 messageDigest = stringMessageData.SHA256_2;
//    BRKey * messagePublicKey = [BRKey keyRecoveredFromCompactSig:signature andMessageDigest:messageDigest];
//    return [sporkPublicKey.publicKey isEqualToData:messagePublicKey.publicKey];
}

@end
