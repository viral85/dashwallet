//
//  DCShapeshiftEntity.h
//  DashWallet
//
//  Created by Quantum Explorer on 8/23/15.
//  Copyright (c) 2015 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum eShapeshiftAddressStatus {
    eShapeshiftAddressStatus_NoDeposits = 0,
    eShapeshiftAddressStatus_Received = 1,
    eShapeshiftAddressStatus_Complete = 2,
    eShapeshiftAddressStatus_Failed = 4,
    eShapeshiftAddressStatus_Finished = eShapeshiftAddressStatus_Complete | eShapeshiftAddressStatus_Failed,
} eShapeshiftAddressStatus;


@class BRTransactionEntity;

@interface DCShapeshiftEntity : NSManagedObject

@property (nonatomic, retain) NSString * inputAddress;
@property (nonatomic, retain) NSString * inputCoinType;
@property (nonatomic, retain) NSString * outputCoinType;
@property (nonatomic, retain) NSNumber * shapeshiftStatus;
@property (nonatomic, retain) NSString * withdrawalAddress;
@property (nonatomic, retain) NSString * outputTransactionId;
@property (nonatomic, retain) NSString * errorMessage;
@property (nonatomic, retain) NSNumber * inputCoinAmount;
@property (nonatomic, retain) NSNumber * outputCoinAmount;
@property (nonatomic, retain) NSDate * expiresAt;
@property (nonatomic, retain) NSNumber * isFixedAmount;
@property (nonatomic, retain) BRTransactionEntity *transaction;

-(NSString*)shapeshiftStatusString;

-(void)checkStatus;

+(DCShapeshiftEntity*)shapeshiftHavingWithdrawalAddress:(NSString*)withdrawalAddress;
+(DCShapeshiftEntity*)registerShapeshiftWithInputAddress:(NSString*)inputAddress andWithdrawalAddress:(NSString*)withdrawalAddress;

-(void)routinelyCheckStatusAtInterval:(NSTimeInterval)timeInterval;

@end
