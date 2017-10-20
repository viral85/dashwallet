//
//  DWSpork.h
//  dashwallet
//
//  Created by Sam Westrich on 10/18/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint32_t,SporkIdentifier) {
    Spork2InstantSendEnabled = 10001,
    Spork3InstantSendBlockFiltering = 1002,
    Spork5InstantSendMaxValue = 10004,
    Spork8MasternodePaymentEnforcement = 10007,
    Spork9SuperblocksEnabled = 10008,
    Spork10MasternodePayUpdatedNodes = 10009,
    Spork12ReconsiderBlocks = 10011,
    Spork13OldSuperblockFlag = 10012,
    Spork14RequireSentinelFlag = 10013
};


@interface DWSpork : NSObject

@property (nonatomic,assign,readonly) SporkIdentifier identifier;
@property (nonatomic,assign,readonly,getter=isValid) BOOL valid;
@property (nonatomic,assign,readonly) uint64_t timeSigned;
@property (nonatomic,assign,readonly) uint64_t value;
@property (nonatomic,strong,readonly) NSData * signature;

+ (instancetype)sporkWithMessage:(NSData *)message;
    
- (instancetype)initWithIdentifier:(SporkIdentifier)identifier value:(uint64_t)value timeSigned:(uint64_t)timeSigned signature:(NSData*)signature;
    
-(BOOL)isEqualToSpork:(DWSpork*)spork;

@end
