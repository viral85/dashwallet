//
//  DWGovObject.h
//  dashwallet
//
//  Created by Sam Westrich on 10/16/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint32_t,GovernanceObjectType) {
    GovernanceUnknownObject = 0,
    GovernanceProposalObject = 1,
    GovernanceTriggerObject = 2,
    GovernanceWatchdogObject = 3
};

typedef union _UInt256 UInt256;

@interface DWGovObject : NSObject

//@property (nonatomic,assign,readonly) UInt256 hash;
@property (nonatomic,assign,readonly) UInt256 parentHash;
@property (nonatomic,assign,readonly,getter=isValid) BOOL valid;
@property (nonatomic,assign,readonly) uint32_t revision;
@property (nonatomic,assign,readonly) uint64_t time;
@property (nonatomic,assign,readonly) UInt256 collateralhash;
@property (nonatomic,assign,readonly) NSString * dataString;
@property (nonatomic,assign,readonly) GovernanceObjectType type;
@property (nonatomic,assign,readonly) UInt256 masternodeVInHash;
@property (nonatomic,strong,readonly) NSData * masternodeVInSignature;
@property (nonatomic,strong,readonly) NSData * signature;

+ (instancetype)govObjWithMessage:(NSData *)message;

@end
