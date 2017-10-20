//
//  BRWalletConstants.m
//  BreadWallet
//
//  Created by Samuel Sutch on 6/3/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint32_t,DWSyncType) {
    DWSyncBlocks,
    DWSyncSporks,
};

NSString* const BRPeerManagerSyncStartedNotification =      @"BRPeerManagerSyncStartedNotification";
NSString* const BRPeerManagerSyncFinishedStepNotification = @"BRPeerManagerSyncFinishedStepNotification";
NSString* const BRPeerManagerSyncFailedNotification =       @"BRPeerManagerSyncFailedNotification";
NSString* const BRPeerManagerTxStatusNotification =         @"BRPeerManagerTxStatusNotification";
NSString* const BRWalletManagerSeedChangedNotification =    @"BRWalletManagerSeedChangedNotification";
NSString* const BRWalletBalanceChangedNotification =        @"BRWalletBalanceChangedNotification";
NSString* const DWSporkManagerSporkUpdateNotification =     @"DWSporkManagerSporkUpdateNotification";
