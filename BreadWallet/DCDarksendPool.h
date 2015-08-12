//
//  DarksendPool.h
//  DashWallet
//
//  Created by  Quantum Exploreron 4/22/15.
//  Copyright (c) 2015 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCDarksendTransaction.h"
#import "DCDarksendService.h"
#import "DCDarksendScript.h"
#import "BRTransaction.h"

#define POOL_MAX_TRANSACTIONS                  3 // wait for X transactions to merge and publish
#define POOL_STATUS_UNKNOWN                    0 // waiting for update
#define POOL_STATUS_IDLE                       1 // waiting for update
#define POOL_STATUS_QUEUE                      2 // waiting in a queue
#define POOL_STATUS_ACCEPTING_ENTRIES          3 // accepting entries
#define POOL_STATUS_FINALIZE_TRANSACTION       4 // master node will broadcast what it accepted
#define POOL_STATUS_SIGNING                    5 // check inputs/outputs, sign final tx
#define POOL_STATUS_TRANSMISSION               6 // transmit transaction
#define POOL_STATUS_ERROR                      7 // error
#define POOL_STATUS_SUCCESS                    8 // success

// status update message constants
#define MASTERNODE_ACCEPTED                    1
#define MASTERNODE_REJECTED                    0
#define MASTERNODE_RESET                       -1

#define DARKSEND_QUEUE_TIMEOUT                 120
#define DARKSEND_SIGNING_TIMEOUT               30

@interface DCDarksendPool : NSObject {
    
    // clients entries
    NSMutableArray * myEntries; //Array of DarkSendEntry
    // masternode entries
    NSMutableArray * entries; //Array of DarkSendEntry
    // the finalized transaction ready for signing
    BRTransaction * finalTransaction;
    
    int64_t lastTimeChanged;
    int64_t lastAutoDenomination;
    
    unsigned int state;
    unsigned int entriesCount;
    unsigned int lastEntryAccepted;
    unsigned int countEntriesAccepted;
    
    // where collateral should be made outCDarkSendPool to
    DCDarksendScript * collateralPubKey;
    
    NSArray * lockedCoins; //NSArray of TxIn
    
    NSData * masterNodeBlockHash; //uint256 32 bytes of data
    
    NSString * lastMessage;
    bool completedTransaction;
    bool unitTest;
    DCDarksendService * submittedToMasternode;
    
    int sessionID;
    int sessionDenom; //Users must submit an denom matching this
    int sessionUsers; //N Users have said they'll join
    bool sessionFoundMasternode; //If we've found a compatible masternode
    int64_t sessionTotalValue; //used for autoDenom
    NSMutableArray * vecSessionCollateral; //NSArray of DCDarksendTransaction
    
    int cachedLastSuccess;
    int cachedNumBlocks; //used for the overview screen
    int minBlockSpacing; //required blocks between mixes
    DCDarksendTransaction * txCollateral;
    
    int64_t lastNewBlock;
    
    //debugging data
    NSString * strAutoDenomResult;
    
    //incremented whenever a DSQ comes through
    int64_t nDsqCount;
}

+(DCDarksendPool*)sharedInstance;


@end
