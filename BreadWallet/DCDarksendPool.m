//
//  DarksendPool.m
//  DashWallet
//
//  Created by Quantum Explorer on 4/22/15.
//  Copyright (c) 2015 Aaron Voisine. All rights reserved.
//

#import "DCDarksendPool.h"
#import "DCDataStream.h"
#import "BRPeer.h"
#import "DCMasternode.h"
#import "BRTransaction.h"

@implementation DCDarksendPool

-(id)init {
    self = [super init];
    if (self) {
        cachedLastSuccess = 0;
        cachedNumBlocks = 0;
        unitTest = false;
        txCollateral = [[DCDarksendTransaction alloc] init];
        minBlockSpacing = 1;
        nDsqCount = 0;
        lastNewBlock = 0;
        
        SetNull();
    }
    return self;
}

-(void)initCollateralAddress {
    NSString * address = @"";
    if(Params().NetworkID() == CChainParams::MAIN) {
        strAddress = "Xq19GqFvajRrEdDHYRKGYjTsQfpV5jyipF";
    } else {
        strAddress = "y1EZuxhhNMAUofTBEeLqGE1bJrpC2TWRNp";
    }
    SetCollateralAddress(strAddress);
}

-(void)updateState:(unsigned int)newState
{
    NSLog(@"CDarkSendPool::UpdateState() == %d | %d \n", state, newState);
    if(state != newState){
        lastTimeChanged = GetTimeMillis();
    }
    state = newState;
}

-(NSInteger)maxPoolTransactions
{
#if DASH_TESTNET
    //if we're on testnet, just use two transactions per merge
    return 2;
#endif
    
    //use the production amount
    return POOL_MAX_TRANSACTIONS;
}

-(void)processDarksendCommand:(NSString*)command withData:(DCDataStream*)vRecv fromPeer:(BRPeer*) pfrom
{
    if([self isInitialBlockDownload]) return;
    
    if ([command isEqualToString:@"dsa"]) { //Darksend Accept Into Pool
        
            NSString * strError = @"This is not a Masternode.";
            NSLog(@"dsa -- not a Masternode! \n");
            pfrom->PushMessage("dssu", sessionID, GetState(), GetEntriesCount(), MASTERNODE_REJECTED, strError);
        
    } else if ([command isEqualToString:@"dsq"]) { //Darksend Queue
        TRY_LOCK(cs_darksend, lockRecv);
        if(!lockRecv) return;
        
        if (pfrom->nVersion < MIN_POOL_PEER_PROTO_VERSION) {
            return;
        }
        
                
    } else if ([command isEqualToString:@"dsi"]) { //DarkSend vIn
            LogPrintf("dsi -- not a Masternode! \n");
            error = _("This is not a Masternode.");
            pfrom->PushMessage("dssu", sessionID, GetState(), GetEntriesCount(), MASTERNODE_REJECTED, error);
        
    } else if ([command isEqualToString:@"dssu"]) { //Darksend status update
        if (pfrom->nVersion < MIN_POOL_PEER_PROTO_VERSION) {
            return;
        }
        
        
        
    } else if ([command isEqualToString:@"dss"]) { //Darksend Sign Final Transaction
        
        if (pfrom->nVersion < MIN_POOL_PEER_PROTO_VERSION) {
            return;
        }
        

    } else if ([command isEqualToString:@"dsf"]) { //Darksend Final tx

        
    } else if ([command isEqualToString:@"dsc"]) { //Darksend Complete
        
        
    }
    
}
-(void)reset{
    cachedLastSuccess = 0;
    vecMasternodesUsed.clear();
    UnlockCoins();
    SetNull();
}

-(void)setNull:(BOOL)clearEverything {
    self.finalTransaction.vin.clear();
    self.finalTransaction.vout.clear();
    
    entries.clear();
    
    state = POOL_STATUS_IDLE;
    
    lastTimeChanged = GetTimeMillis();
    
    entriesCount = 0;
    lastEntryAccepted = 0;
    countEntriesAccepted = 0;
    lastNewBlock = 0;
    
    sessionUsers = 0;
    sessionDenom = 0;
    sessionFoundMasternode = false;
    vecSessionCollateral.clear();
    txCollateral = CTransaction();
    
    if(clearEverything){
        myEntries.removeAllObjects;
        sessionID = 0;
    }
}

-(bool)setCollateralAddress:(NSString*)strAddress{
    CBitcoinAddress address;
    if (!address.SetString(strAddress))
    {
        LogPrintf("CDarksendPool::SetCollateralAddress - Invalid Darksend collateral address\n");
        return false;
    }
    collateralPubKey.SetDestination(address.Get());
    return true;
}

//
// Unlock coins after Darksend fails or succeeds
//
-(void)unlockCoins {
    for (BRTransaction * transaction in lockedCoins) {
        
    }
    BOOST_FOREACH(CTxIn v, lockedCoins)
    pwalletMain->UnlockCoin(v.prevout);
    
    lockedCoins.clear();
}



#pragma mark -
#pragma mark Singleton methods

+ (DCDarksendPool *)sharedInstance
{
    static DCDarksendPool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DCDarksendPool alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}


@end
