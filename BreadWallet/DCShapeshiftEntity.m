//
//  DCShapeshiftEntity.m
//  DashWallet
//
//  Created by Quantum Explorer on 8/23/15.
//  Copyright (c) 2015 Aaron Voisine. All rights reserved.
//

#import "DCShapeshiftEntity.h"
#import "BRTransactionEntity.h"
#import "NSManagedObject+Sugar.h"
#import "DCShapeshiftManager.h"

@implementation DCShapeshiftEntity

@dynamic inputAddress;
@dynamic inputCoinType;
@dynamic outputCoinType;
@dynamic shapeshiftStatus;
@dynamic withdrawalAddress;
@dynamic outputTransactionId;
@dynamic errorMessage;
@dynamic inputCoinAmount;
@dynamic outputCoinAmount;
@dynamic expiresAt;
@dynamic isFixedAmount;
@dynamic transaction;

+(DCShapeshiftEntity*)shapeshiftHavingWithdrawalAddress:(NSString*)withdrawalAddress {
    DCShapeshiftEntity * previousShapeshift = [DCShapeshiftEntity anyObjectMatching:[NSString stringWithFormat:@"withdrawalAddress == %@ && shapeshiftStatus == %@",withdrawalAddress, @(eShapeshiftAddressStatus_NoDeposits)]];
    return previousShapeshift;
}

+(DCShapeshiftEntity*)registerShapeshiftWithInputAddress:(NSString*)inputAddress andWithdrawalAddress:(NSString*)withdrawalAddress {
    DCShapeshiftEntity * shapeshift = [DCShapeshiftEntity managedObject];
    shapeshift.inputAddress = inputAddress;
    shapeshift.withdrawalAddress = withdrawalAddress;
    shapeshift.shapeshiftStatus = @(eShapeshiftAddressStatus_NoDeposits);
    shapeshift.isFixedAmount = @NO;
    [self saveContext];
    return shapeshift;
}

-(void)checkStatus {
    [[DCShapeshiftManager sharedInstance] GET_transactionStatusWithAddress:self.withdrawalAddress completionBlock:^(NSDictionary *transactionInfo, NSError *error) {
        if (transactionInfo) {
            NSString * status = transactionInfo[@"status"];
            if ([status isEqualToString:@"received"]) {
                self.shapeshiftStatus = @(eShapeshiftAddressStatus_Received);
            } else if ([status isEqualToString:@"complete"]) {
                self.shapeshiftStatus = @(eShapeshiftAddressStatus_Complete);
                self.outputTransactionId = transactionInfo[@"transaction"];
                self.outputCoinAmount = transactionInfo[@"outgoingCoin"];
            } else if ([status isEqualToString:@"failed"]) {
                self.shapeshiftStatus = @(eShapeshiftAddressStatus_Failed);
                self.errorMessage = transactionInfo[@"error"];
            }
        }
    }];
}

-(void)startObservingAtInterval:(NSTimeInterval)timeInterval {
    self.checkStatusTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(checkStatus) userInfo:nil repeats:YES];
}

-(void)deleteObject {
    [self.checkStatusTimer invalidate];
    [super deleteObject];
}

@end
