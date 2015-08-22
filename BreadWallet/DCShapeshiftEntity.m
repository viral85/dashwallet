//
//  DCShapeshiftEntity.m
//  DashWallet
//
//  Created by  Quantum Exploreron 8/22/15.
//  Copyright (c) 2015 Aaron Voisine. All rights reserved.
//

#import "DCShapeshiftEntity.h"
#import "BRTransactionEntity.h"
#import "NSManagedObject+Sugar.h"


@implementation DCShapeshiftEntity

@dynamic withdrawalAddress;
@dynamic inputAddress;
@dynamic inputCoin;
@dynamic outputCoin;
@dynamic shapeshiftStatus;
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
    [self saveContext];
    return shapeshift;
}

@end
