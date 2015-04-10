//
//  BRPeerManager.m
//  BreadWallet
//
//  Created by Aaron Voisine on 10/6/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BRPeerManager.h"
#import "BRPeer.h"
#import "BRPeerEntity.h"
#import "BRBloomFilter.h"
#import "BRKeySequence.h"
#import "BRTransaction.h"
#import "BRMerkleBlock.h"
#import "BRMerkleBlockEntity.h"
#import "BRWalletManager.h"
#import "NSString+Bitcoin.h"
#import "NSData+Dash.h"
#import "NSManagedObject+Sugar.h"
#import <netdb.h>

#define FIXED_PEERS          @"FixedPeers"
#define NODE_NETWORK         1  // services value indicating a node offers full blocks, not just headers
#define PROTOCOL_TIMEOUT     20.0
#define MAX_CONNECT_FAILURES 20 // notify user of network problems after this many connect failures in a row
#define CHECKPOINT_COUNT     (sizeof(checkpoint_array)/sizeof(*checkpoint_array))
#define GENESIS_BLOCK_HASH   ([NSString stringWithUTF8String:checkpoint_array[0].hash].hexToData.reverse)

#if DASH_TESTNET

static const struct { uint32_t height; char *hash; time_t timestamp; uint32_t target; } checkpoint_array[] = {
    {      261, "00000c26026d0815a7e2ce4fa270775f61403c040647ff2c3091f99e894a4618", 1296688602, 0x1d00ffffu }
};

static const char *dns_seeds[] = {
    "test.dnsseed.masternode.io","testnet-seed.darkcoin.qa","testnet-seed.dashpay.io"
};

#else // main net

// blockchain checkpoints - these are also used as starting points for partial chain downloads, so they need to be at
// difficulty transition boundaries in order to verify the block difficulty at the immediately following transition
static const struct { uint32_t height; char *hash; time_t timestamp; uint32_t target; } checkpoint_array[] = {
    {      0, "00000ffd590b1485b3caadc19b22e6379c733355108f107a430458cdf3407ab6", 1390095618, 0x1e0ffff0u },//dash
    {   1500, "000000aaf0300f59f49bc3e970bad15c11f961fe2347accffff19d96ec9778e3", 1390109863, 0x1e00ffffu },//dash
    {   4991, "000000003b01809551952460744d5dbb8fcbd6cbae3c220267bf7fa43f837367", 1390271049, 0x1c426980u },//dash
    {   9918, "00000000213e229f332c0ffbe34defdaa9e74de87f2d8d1f01af8d121c3c170b", 1391392449, 0x1c41cc20u },//dash
    {  16912, "00000000075c0d10371d55a60634da70f197548dbbfa4123e12abfcbc5738af9", 1392328997, 0x1c07cc3bu },//dash
    {  23912, "0000000000335eac6703f3b1732ec8b2f89c3ba3a7889e5767b090556bb9a276", 1393373461, 0x1c0177efu },//dash
    {  35457, "0000000000b0ae211be59b048df14820475ad0dd53b9ff83b010f71a77342d9f", 1395110315, 0x1c00da53u },//dash
    {  45479, "000000000063d411655d590590e16960f15ceea4257122ac430c6fbe39fbf02d", 1396620889, 0x1c009c80u },//dash
    {  55895, "0000000000ae4c53a43639a4ca027282f69da9c67ba951768a20415b6439a2d7", 1398190161, 0x1c00bae3u },//dash
    {  68899, "0000000000194ab4d3d9eeb1f2f792f21bb39ff767cb547fe977640f969d77b7", 1400148293, 0x1b25df16u },//dash
    {  74619, "000000000011d28f38f05d01650a502cc3f4d0e793fbc26e2a2ca71f07dc3842", 1401048723, 0x1b1905e3u },//dash
    {  75095, "0000000000193d12f6ad352a9996ee58ef8bdc4946818a5fec5ce99c11b87f0d", 1401126238, 0x1b2587e3u },//dash
    {  88805, "00000000001392f1652e9bf45cd8bc79dc60fe935277cd11538565b4a94fa85f", 1403283082, 0x1b194dfbu },//dash
    { 107996, "00000000000a23840ac16115407488267aa3da2b9bc843e301185b7d17e4dc40", 1406300692, 0x1b11c217u },//dash
    { 137993, "00000000000cf69ce152b1bffdeddc59188d7a80879210d6e5c9503011929c3c", 1411014812, 0x1b1142abu },//dash
    { 167996, "000000000009486020a80f7f2cc065342b0c2fb59af5e090cd813dba68ab0fed", 1415730882, 0x1b112d94u },//dash
    { 207992, "00000000000d85c22be098f74576ef00b7aa00c05777e966aff68a270f1e01a5", 1422026638, 0x1b113c01u },//dash
    { 217752, "00000000000a7baeb2148272a7e14edf5af99a64af456c0afc23d15a0918b704", 1423563332, 0x1b10c9b6u }//dash
};

static const char *dns_seeds[] = {
    "dnsseed.masternode.io","dnsseed.darkcoin.qa","dnsseed.dashpay.io"
};

#endif

@interface BRPeerManager ()

@property (nonatomic, strong) NSMutableOrderedSet *peers;
@property (nonatomic, strong) NSMutableSet *connectedPeers, *misbehavinPeers, *txHashes;
@property (nonatomic, strong) BRPeer *downloadPeer;
@property (nonatomic, assign) uint32_t tweak, syncStartHeight, filterUpdateHeight;
@property (nonatomic, strong) BRBloomFilter *bloomFilter;
@property (nonatomic, assign) double fpRate;
@property (nonatomic, assign) NSUInteger taskId, connectFailures, misbehavinCount;
@property (nonatomic, assign) NSTimeInterval earliestKeyTime, lastRelayTime;
@property (nonatomic, strong) NSMutableDictionary *blocks, *orphans, *checkpoints, *txRelays;
@property (nonatomic, strong) NSMutableDictionary *publishedTx, *publishedCallback;
@property (nonatomic, strong) BRMerkleBlock *lastBlock, *lastOrphan;
@property (nonatomic, strong) dispatch_queue_t q;
@property (nonatomic, strong) id backgroundObserver, seedObserver;

@end

@implementation BRPeerManager

+ (instancetype)sharedInstance
{
    static id singleton = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        singleton = [self new];
    });
    
    return singleton;
}

- (instancetype)init
{
    if (! (self = [super init])) return nil;

    self.earliestKeyTime = [[BRWalletManager sharedInstance] seedCreationTime];
    self.connectedPeers = [NSMutableSet set];
    self.misbehavinPeers = [NSMutableSet set];
    self.tweak = arc4random();
    self.taskId = UIBackgroundTaskInvalid;
    self.q = dispatch_queue_create("peermanager", NULL);
    self.orphans = [NSMutableDictionary dictionary];
    self.txHashes = [NSMutableSet set];
    self.txRelays = [NSMutableDictionary dictionary];
    self.publishedTx = [NSMutableDictionary dictionary];
    self.publishedCallback = [NSMutableDictionary dictionary];

    dispatch_async(self.q, ^{
        for (BRTransaction *tx in [[[BRWalletManager sharedInstance] wallet] recentTransactions]) {
            if (tx.blockHeight == TX_UNCONFIRMED) self.publishedTx[tx.txHash] = tx; // add unconfirmed tx to mempool
            [self.txHashes addObject:tx.txHash];
        }
    });

    self.backgroundObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil
        queue:nil usingBlock:^(NSNotification *note) {
            [self savePeers];
            [self saveBlocks];
            [BRMerkleBlockEntity saveContext];

            if (self.taskId == UIBackgroundTaskInvalid) {
                self.misbehavinCount = 0;
                [self.connectedPeers makeObjectsPerformSelector:@selector(disconnect)];
            }
        }];

    self.seedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletManagerSeedChangedNotification object:nil
        queue:nil usingBlock:^(NSNotification *note) {
            self.earliestKeyTime = [[BRWalletManager sharedInstance] seedCreationTime];
            self.syncStartHeight = 0;
            [self.txHashes removeAllObjects];
            [self.txRelays removeAllObjects];
            [self.publishedTx removeAllObjects];
            [self.publishedCallback removeAllObjects];
            [BRMerkleBlockEntity deleteObjects:[BRMerkleBlockEntity allObjects]];
            [BRMerkleBlockEntity saveContext];
            _blocks = nil;
            _bloomFilter = nil;
            _lastBlock = nil;
            [self.connectedPeers makeObjectsPerformSelector:@selector(disconnect)];
        }];

    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.backgroundObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.backgroundObserver];
    if (self.seedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.seedObserver];
}

- (NSMutableOrderedSet *)peers
{
    if (_peers.count >= PEER_MAX_CONNECTIONS) return _peers;

    @synchronized(self) {
        if (_peers.count >= PEER_MAX_CONNECTIONS) return _peers;
        _peers = [NSMutableOrderedSet orderedSet];

        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];

        [[BRPeerEntity context] performBlockAndWait:^{
            for (BRPeerEntity *e in [BRPeerEntity allObjects]) {
                if (e.misbehavin == 0) [_peers addObject:[e peer]];
                else [self.misbehavinPeers addObject:[e peer]];
            }
        }];

        [self sortPeers];

        if (_peers.count < PEER_MAX_CONNECTIONS || [_peers[PEER_MAX_CONNECTIONS - 1] timestamp] < now - 3*24*60*60) {
            for (int i = 0; i < sizeof(dns_seeds)/sizeof(*dns_seeds); i++) { // DNS peer discovery
                NSLog(@"DNS lookup %s", dns_seeds[i]);
                
                struct hostent *h = gethostbyname(dns_seeds[i]);

                for (int j = 0; h != NULL && h->h_addr_list[j] != NULL; j++) {
                    uint32_t addr = CFSwapInt32BigToHost(((struct in_addr *)h->h_addr_list[j])->s_addr);

                    // give dns peers a timestamp between 3 and 7 days ago
                    [_peers addObject:[[BRPeer alloc] initWithAddress:addr port:DASH_STANDARD_PORT
                                       timestamp:now - (3*24*60*60 + arc4random_uniform(4*24*60*60))
                                       services:NODE_NETWORK]];
                }
            }

#if DASH_TESTNET
            [self sortPeers];
            return _peers;
#endif
            if (_peers.count < PEER_MAX_CONNECTIONS) {
                NSAssert(FALSE, @"we need to do this");
                // if DNS peer discovery fails, fall back on a hard coded list of peers (list taken from satoshi client)
//                for (NSNumber *address in [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]
//                                           pathForResource:FIXED_PEERS ofType:@"plist"]]) {
//                    // give hard coded peers a timestamp between 7 and 14 days ago
//                    [_peers addObject:[[BRPeer alloc] initWithAddress:address.intValue port:DASH_STANDARD_PORT
//                                       timestamp:now - (7*24*60*60 + arc4random_uniform(7*24*60*60))
//                                       services:NODE_NETWORK]];
//                }
            }
            
            [self sortPeers];
        }

        return _peers;
    }
}

- (NSMutableDictionary *)blocks
{
    if (_blocks.count > 0) return _blocks;

    [[BRMerkleBlockEntity context] performBlockAndWait:^{
        if (_blocks.count > 0) return;
        _blocks = [NSMutableDictionary dictionary];
        self.checkpoints = [NSMutableDictionary dictionary];

        for (int i = 0; i < CHECKPOINT_COUNT; i++) { // add checkpoints to the block collection
            NSData *hash = [NSString stringWithUTF8String:checkpoint_array[i].hash].hexToData.reverse;

            _blocks[hash] = [[BRMerkleBlock alloc] initWithBlockHash:hash version:1 prevBlock:nil merkleRoot:nil
                             timestamp:checkpoint_array[i].timestamp - NSTimeIntervalSince1970
                             target:checkpoint_array[i].target nonce:0 totalTransactions:0 hashes:nil flags:nil
                             height:checkpoint_array[i].height];
            self.checkpoints[@(checkpoint_array[i].height)] = hash;
        }

        for (BRMerkleBlockEntity *e in [BRMerkleBlockEntity allObjects]) {
            BRMerkleBlock *b = e.merkleBlock;

            _blocks[e.blockHash] = b;
            
            // track moving average transactions per block using a 1% low pass filter
            if (b.totalTransactions > 0) _averageTxPerBlock = _averageTxPerBlock*0.99 + b.totalTransactions*0.01;
        };
        
        [[BRWalletManager sharedInstance] setAverageBlockSize:self.averageTxPerBlock*TX_AVERAGE_SIZE];
    }];

    return _blocks;
}

// this is used as part of a getblocks or getheaders request
- (NSArray *)blockLocatorArray
{
    // append 10 most recent block hashes, decending, then continue appending, doubling the step back each time,
    // finishing with the genisis block (top, -1, -2, -3, -4, -5, -6, -7, -8, -9, -11, -15, -23, -39, -71, -135, ..., 0)
    NSMutableArray *locators = [NSMutableArray array];
    int32_t step = 1, start = 0;
    BRMerkleBlock *b = self.lastBlock;

    while (b && b.height > 0) {
        [locators addObject:b.blockHash];
        if (++start >= 10) step *= 2;

        for (int32_t i = 0; b && i < step; i++) {
            b = self.blocks[b.prevBlock];
        }
    }

    [locators addObject:GENESIS_BLOCK_HASH];
    return locators;
}

- (BRMerkleBlock *)lastBlock
{
    if (_lastBlock) return _lastBlock;

    NSFetchRequest *req = [BRMerkleBlockEntity fetchRequest];

    req.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"height" ascending:NO]];
    req.predicate = [NSPredicate predicateWithFormat:@"height >= 0 && height != %d", BLOCK_UNKOWN_HEIGHT];
    req.fetchLimit = 1;
    _lastBlock = [[BRMerkleBlockEntity fetchObjects:req].lastObject merkleBlock];

    // if we don't have any blocks yet, use the latest checkpoint that's at least a week older than earliestKeyTime
    for (int i = CHECKPOINT_COUNT - 1; ! _lastBlock && i >= 0; i--) {
        if (i == 0 || checkpoint_array[i].timestamp + 7*24*60*60 - NSTimeIntervalSince1970 < self.earliestKeyTime) {
            _lastBlock = [[BRMerkleBlock alloc]
                          initWithBlockHash:[NSString stringWithUTF8String:checkpoint_array[i].hash].hexToData.reverse
                          version:1 prevBlock:nil merkleRoot:nil
                          timestamp:checkpoint_array[i].timestamp - NSTimeIntervalSince1970
                          target:checkpoint_array[i].target nonce:0 totalTransactions:0 hashes:nil flags:nil
                          height:checkpoint_array[i].height];
        }
    }

    return _lastBlock;
}

- (uint32_t)lastBlockHeight
{
    return self.lastBlock.height;
}

- (uint32_t)estimatedBlockHeight
{
    if (self.downloadPeer.lastblock > self.lastBlockHeight) return self.downloadPeer.lastblock;
    return self.lastBlockHeight + ([NSDate timeIntervalSinceReferenceDate] - self.lastBlock.timestamp)/(10*60);
}

- (double)syncProgress
{
    if (! self.downloadPeer) return (self.syncStartHeight == self.lastBlockHeight) ? 0.05 : 0.0;
    if (self.lastBlockHeight >= self.downloadPeer.lastblock) return 1.0;
    return 0.1 + 0.9*(self.lastBlockHeight - self.syncStartHeight)/(self.downloadPeer.lastblock - self.syncStartHeight);
}

// number of connected peers
- (NSUInteger)peerCount
{
    NSUInteger count = 0;

    for (BRPeer *peer in self.connectedPeers) {
        if (peer.status == BRPeerStatusConnected) count++;
    }

    return count;
}

- (BRBloomFilter *)bloomFilter
{
    if (_bloomFilter) return _bloomFilter;

    // every time a new wallet address is added, the bloom filter has to be rebuilt, and each address is only used for
    // one transaction, so here we generate some spare addresses to avoid rebuilding the filter each time a wallet
    // transaction is encountered during the blockchain download (generates 5x the external gap limit for both chains)
    [[[BRWalletManager sharedInstance] wallet] addressesWithGapLimit:SEQUENCE_GAP_LIMIT_EXTERNAL*5 internal:NO];
    [[[BRWalletManager sharedInstance] wallet] addressesWithGapLimit:SEQUENCE_GAP_LIMIT_EXTERNAL*5 internal:YES];

    [self.orphans removeAllObjects]; // clear out orphans that may have been received on an old filter
    self.lastOrphan = nil;
    self.filterUpdateHeight = self.lastBlockHeight;
    self.fpRate = BLOOM_DEFAULT_FALSEPOSITIVE_RATE;
    if (self.lastBlockHeight + 500 < self.estimatedBlockHeight) self.fpRate = BLOOM_REDUCED_FALSEPOSITIVE_RATE;

    BRWalletManager *m = [BRWalletManager sharedInstance];
    NSUInteger elemCount = m.wallet.addresses.count + m.wallet.unspentOutputs.count;
    BRBloomFilter *filter = [[BRBloomFilter alloc] initWithFalsePositiveRate:self.fpRate
                             forElementCount:(elemCount < 200 ? elemCount*1.5 : elemCount + 100)
                             tweak:self.tweak flags:BLOOM_UPDATE_ALL];

    for (NSString *address in m.wallet.addresses) { // add addresses to watch for any tx receiveing money to the wallet
        NSData *hash = address.addressToHash160;

        if (hash && ! [filter containsData:hash]) [filter insertData:hash];
    }

    // add unspent outputs to watch for tx sending money from the wallet
    for (NSData *utxo in m.wallet.unspentOutputs) if (! [filter containsData:utxo]) [filter insertData:utxo];
    _bloomFilter = filter;
    return _bloomFilter;
}

- (void)connect
{
    if ([[BRWalletManager sharedInstance] noWallet]) return; // check to make sure the wallet has been created
    if (self.connectFailures >= MAX_CONNECT_FAILURES) self.connectFailures = 0; // this attempt is a manual retry
    
    if (self.syncProgress < 1.0) {
        if (self.syncStartHeight == 0) self.syncStartHeight = self.lastBlockHeight;

        if (self.taskId == UIBackgroundTaskInvalid) { // start a background task for the chain sync
            // TODO: XXXX handle task expiration cleanly
            self.taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerSyncStartedNotification object:nil];
        });
    }

    dispatch_async(self.q, ^{
        [self.connectedPeers minusSet:[self.connectedPeers objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            return ([obj status] == BRPeerStatusDisconnected) ? YES : NO;
        }]];

        if (self.connectedPeers.count >= PEER_MAX_CONNECTIONS) return; //already connected to PEER_MAX_CONNECTIONS peers

        NSMutableOrderedSet *peers = [NSMutableOrderedSet orderedSetWithOrderedSet:self.peers];

        if (peers.count > 100) [peers removeObjectsInRange:NSMakeRange(100, peers.count - 100)];

        while (peers.count > 0 && self.connectedPeers.count < PEER_MAX_CONNECTIONS) {
            // pick a random peer biased towards peers with more recent timestamps
            BRPeer *p = peers[(NSUInteger)(pow(arc4random_uniform((uint32_t)peers.count), 2)/peers.count)];

            if (p && ! [self.connectedPeers containsObject:p]) {
                [p setDelegate:self queue:self.q];
                p.earliestKeyTime = self.earliestKeyTime;
                [self.connectedPeers addObject:p];
                [p connect];
            }

            [peers removeObject:p];
        }

        [self bloomFilter]; // initialize wallet and bloomFilter while connecting

        if (self.connectedPeers.count == 0) {
            [self syncStopped];

            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"BreadWallet" code:1 userInfo:@{NSLocalizedDescriptionKey:
                                  NSLocalizedString(@"no peers found", nil)}];

                [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerSyncFailedNotification
                 object:nil userInfo:@{@"error":error}];
            });
        }
    });
}

// rescans blocks and transactions after earliestKeyTime, a new random download peer is also selected due to the
// possibility that a malicious node might lie by omitting transactions that match the bloom filter
- (void)rescan
{
    if (! self.connected) return;

    dispatch_async(self.q, ^{
        _lastBlock = nil;

        // start the chain download from the most recent checkpoint that's at least a week older than earliestKeyTime
        for (int i = CHECKPOINT_COUNT - 1; ! _lastBlock && i >= 0; i--) {
            if (i == 0 || checkpoint_array[i].timestamp + 7*24*60*60 - NSTimeIntervalSince1970 < self.earliestKeyTime) {
                _lastBlock = self.blocks[[NSString stringWithUTF8String:checkpoint_array[i].hash].hexToData.reverse];
            }
        }

        if (self.downloadPeer) { // disconnect the current download peer so a new random one will be selected
            [self.peers removeObject:self.downloadPeer];
            [self.downloadPeer disconnect];
        }

        self.syncStartHeight = self.lastBlockHeight;
        [self connect];
    });
}

- (void)publishTransaction:(BRTransaction *)transaction completion:(void (^)(NSError *error))completion
{
    if (! [transaction isSigned]) {
        if (completion) {
            completion([NSError errorWithDomain:@"BreadWallet" code:401 userInfo:@{NSLocalizedDescriptionKey:
                        NSLocalizedString(@"bitcoin transaction not signed", nil)}]);
        }
        
        return;
    }
    else if (! self.connected) {
        if (completion) {
            completion([NSError errorWithDomain:@"BreadWallet" code:-1009 userInfo:@{NSLocalizedDescriptionKey:
                        NSLocalizedString(@"not connected to the bitcoin network", nil)}]);
        }
        
        return;
    }

    self.publishedTx[transaction.txHash] = transaction;
    if (completion) self.publishedCallback[transaction.txHash] = completion;

    NSMutableSet *peers = [NSMutableSet setWithSet:self.connectedPeers];
    NSArray *txHashes = self.publishedTx.allKeys;

    // instead of publishing to all peers, leave out the download peer to see if the tx propogates and gets relayed back
    // TODO: XXX connect to a random peer with an empty or fake bloom filter just for publishing
    if (self.peerCount > 1) [peers removeObject:self.downloadPeer];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(txTimeout:) withObject:transaction.txHash afterDelay:PROTOCOL_TIMEOUT];

        for (BRPeer *p in peers) {
            [p sendInvMessageWithTxHashes:txHashes];
            [p sendPingMessageWithPongHandler:^(BOOL success) {
                if (success) [p sendGetdataMessageWithTxHashes:txHashes andBlockHashes:nil];
            }];
        }
    });
}

// number of connected peers that have relayed the transaction
- (NSUInteger)relayCountForTransaction:(NSData *)txHash
{
    return [self.txRelays[txHash] count];
}

// seconds since reference date, 00:00:00 01/01/01 GMT
// NOTE: this is only accurate for the last two weeks worth of blocks, other timestamps are estimated from checkpoints
// BUG: this just doesn't work very well... we need to start storing tx metadata
- (NSTimeInterval)timestampForBlockHeight:(uint32_t)blockHeight
{
    if (blockHeight == TX_UNCONFIRMED) return self.lastBlock.timestamp + 10*60; // assume next block

    if (blockHeight > self.lastBlockHeight) { // future block, assume 10 minutes per block after last block
        return self.lastBlock.timestamp + (blockHeight - self.lastBlockHeight)*10*60;
    }

    if (_blocks.count > 0) {
        if (blockHeight >= self.lastBlockHeight /*- BLOCK_DIFFICULTY_INTERVAL*/*2) { // recent block we have the header for
            BRMerkleBlock *block = self.lastBlock;

            while (block && block.height > blockHeight) block = self.blocks[block.prevBlock];
            if (block) return block.timestamp;
        }
    }
    else [[BRMerkleBlockEntity context] performBlock:^{ [self blocks]; }];

    uint32_t h = self.lastBlockHeight;
    NSTimeInterval t = self.lastBlock.timestamp + NSTimeIntervalSince1970;

    for (int i = CHECKPOINT_COUNT - 1; i >= 0; i--) { // estimate from checkpoints
        if (checkpoint_array[i].height <= blockHeight) {
            t = checkpoint_array[i].timestamp + (t - checkpoint_array[i].timestamp)*
                (blockHeight - checkpoint_array[i].height)/(h - checkpoint_array[i].height);
            return t - NSTimeIntervalSince1970;
        }

        h = checkpoint_array[i].height;
        t = checkpoint_array[i].timestamp;
    }

    return checkpoint_array[0].timestamp - NSTimeIntervalSince1970;
}

- (void)setBlockHeight:(int32_t)height andTimestamp:(NSTimeInterval)timestamp forTxHashes:(NSArray *)txHashes
{
    [[[BRWalletManager sharedInstance] wallet] setBlockHeight:height andTimestamp:timestamp forTxHashes:txHashes];
    
    if (height != TX_UNCONFIRMED) { // remove confirmed tx from publish list and relay counts
        [self.publishedTx removeObjectsForKeys:txHashes];
        [self.publishedCallback removeObjectsForKeys:txHashes];
        [self.txRelays removeObjectsForKeys:txHashes];
    }
}

- (void)txTimeout:(NSData *)txHash
{
    void (^callback)(NSError *error) = self.publishedCallback[txHash];

    [self.publishedTx removeObjectForKey:txHash];
    [self.publishedCallback removeObjectForKey:txHash];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(txTimeout:) object:txHash];

    if (callback) {
        callback([NSError errorWithDomain:@"BreadWallet" code:DASH_TIMEOUT_CODE userInfo:@{NSLocalizedDescriptionKey:
                  NSLocalizedString(@"transaction canceled, network timeout", nil)}]);
    }
}

- (void)syncTimeout
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];

    if (now - self.lastRelayTime < PROTOCOL_TIMEOUT) { // the download peer relayed something in time, so restart timer
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncTimeout) object:nil];
        [self performSelector:@selector(syncTimeout) withObject:nil
         afterDelay:PROTOCOL_TIMEOUT - (now - self.lastRelayTime)];
        return;
    }

    dispatch_async(self.q, ^{
        if (! self.downloadPeer) return;
        NSLog(@"%@:%d chain sync timed out", self.downloadPeer.host, self.downloadPeer.port);
        [self.peers removeObject:self.downloadPeer];
        [self.downloadPeer disconnect];
    });
}

- (void)syncStopped
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        [self.connectedPeers makeObjectsPerformSelector:@selector(disconnect)];
        [self.connectedPeers removeAllObjects];
    }

    if (self.taskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.taskId];
        self.taskId = UIBackgroundTaskInvalid;
        
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
            for (BRPeer *p in self.connectedPeers) { // after syncing, load filters and get mempools from other peers
                if (p != self.downloadPeer) [p sendFilterloadMessage:self.bloomFilter.data];
                [p sendInvMessageWithTxHashes:self.publishedTx.allKeys]; // publish unconfirmed tx
                [p sendMempoolMessage];
                [p sendPingMessageWithPongHandler:^(BOOL success) {
                    if (! success) return;
                    p.synced = YES;
                    [p sendGetaddrMessage]; // request a list of other bitcoin peers
                    [self removeUnrelayedTransactions];
                }];
            }
        }
    }

    self.syncStartHeight = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncTimeout) object:nil];
    });
}

// unconfirmed transactions that aren't in the mempools of any of connected peers have likely dropped off the network
- (void)removeUnrelayedTransactions
{
    BRWalletManager *m = [BRWalletManager sharedInstance];
    BOOL rescan = NO;

    // don't remove transactions until we're connected to PEER_MAX_CONNECTION peers
    if (self.connectedPeers.count < PEER_MAX_CONNECTIONS) return;
    
    for (BRPeer *p in self.connectedPeers) { // don't remove tx until all peers have finished relaying their mempools
        if (! p.synced) return;
    }

    for (BRTransaction *tx in m.wallet.recentTransactions) {
        if (tx.blockHeight != TX_UNCONFIRMED) break;

        if ([self.txRelays[tx.txHash] count] == 0) {
            // if this is for a transaction we sent, and inputs were all confirmed, and it wasn't already known to be
            // invalid, then recommend a rescan
            if (! rescan && [m.wallet amountSentByTransaction:tx] > 0 && [m.wallet transactionIsValid:tx]) {
                rescan = YES;
                
                for (NSData *hash in tx.inputHashes) {
                    if ([[m.wallet transactionForHash:hash] blockHeight] != TX_UNCONFIRMED) continue;
                    rescan = NO;
                    break;
                }
            }
            
            [m.wallet removeTransaction:tx.txHash];
        }
    }
    
    if (rescan) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"transaction rejected", nil)
              message:NSLocalizedString(@"Your wallet may be out of sync.\n"
                                        "This can often be fixed by rescanning the blockchain.", nil) delegate:self
              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
              otherButtonTitles:NSLocalizedString(@"rescan", nil), nil] show];
        });
    }
}

- (void)updateFilter
{
    if (self.downloadPeer.needsFilterUpdate) return;
    self.downloadPeer.needsFilterUpdate = YES;
    NSLog(@"filter update needed, waiting for pong");
    
    [self.downloadPeer sendPingMessageWithPongHandler:^(BOOL success) { // wait for pong so we include already sent tx
        if (! success) return;
        if (! _bloomFilter) NSLog(@"updating filter with newly created wallet addresses");
        _bloomFilter = nil;

        if (self.lastBlockHeight < self.downloadPeer.lastblock) { // if we're syncing, only update download peer
            [self.downloadPeer sendFilterloadMessage:self.bloomFilter.data];
            [self.downloadPeer sendPingMessageWithPongHandler:^(BOOL success) { // wait for pong so filter is loaded
                if (! success) return;
                self.downloadPeer.needsFilterUpdate = NO;
                [self.downloadPeer rerequestBlocksFrom:self.lastBlock.blockHash];
                [self.downloadPeer sendPingMessageWithPongHandler:^(BOOL success) {
                    if (! success || self.downloadPeer.needsFilterUpdate) return;
                    [self.downloadPeer sendGetblocksMessageWithLocators:[self blockLocatorArray] andHashStop:nil];
                }];
            }];
        }
        else {
            for (BRPeer *p in self.connectedPeers) {
                [p sendFilterloadMessage:self.bloomFilter.data];
                [p sendPingMessageWithPongHandler:^(BOOL success) { // wait for pong so we know filter is loaded
                    if (! success) return;
                    p.needsFilterUpdate = NO;
                    [p sendMempoolMessage];
                }];
            }
        }
    }];
}

- (void)peerMisbehavin:(BRPeer *)peer
{
    peer.misbehavin++;
    [self.peers removeObject:peer];
    [self.misbehavinPeers addObject:peer];

    if (++self.misbehavinCount >= 10) { // clear out stored peers so we get a fresh list from DNS for next connect
        self.misbehavinCount = 0;
        [self.misbehavinPeers removeAllObjects];
        [BRPeerEntity deleteObjects:[BRPeerEntity allObjects]];
        _peers = nil;
    }
    
    [peer disconnect];
    [self connect];
}

- (void)sortPeers
{
    [_peers sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 timestamp] > [obj2 timestamp]) return NSOrderedAscending;
        if ([obj1 timestamp] < [obj2 timestamp]) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

- (void)savePeers
{
    NSMutableSet *peers = [[self.peers.set setByAddingObjectsFromSet:self.misbehavinPeers] mutableCopy];
    NSMutableSet *addrs = [NSMutableSet set];

    for (BRPeer *p in peers) [addrs addObject:@((int32_t)p.address)];

    [[BRPeerEntity context] performBlock:^{
        [BRPeerEntity deleteObjects:[BRPeerEntity objectsMatching:@"! (address in %@)", addrs]]; // remove deleted peers

        for (BRPeerEntity *e in [BRPeerEntity objectsMatching:@"address in %@", addrs]) { // update existing peers
            BRPeer *p = [peers member:[e peer]];

            if (p) {
                e.timestamp = p.timestamp;
                e.services = p.services;
                e.misbehavin = p.misbehavin;
                [peers removeObject:p];
            }
            else [e deleteObject];
        }

        for (BRPeer *p in peers) [[BRPeerEntity managedObject] setAttributesFromPeer:p]; // add new peers
    }];
}

- (void)saveBlocks
{
    NSMutableSet *blockHashes = [NSMutableSet set];
    BRMerkleBlock *b = self.lastBlock;

    while (b) {
        [blockHashes addObject:b.blockHash];
        b = self.blocks[b.prevBlock];
    }

    [[BRMerkleBlockEntity context] performBlock:^{
        [BRMerkleBlockEntity deleteObjects:[BRMerkleBlockEntity objectsMatching:@"! (blockHash in %@)", blockHashes]];

        for (BRMerkleBlockEntity *e in [BRMerkleBlockEntity objectsMatching:@"blockHash in %@", blockHashes]) {
            [e setAttributesFromBlock:self.blocks[e.blockHash]];
            [blockHashes removeObject:e.blockHash];
        }

        for (NSData *hash in blockHashes) {
            [[BRMerkleBlockEntity managedObject] setAttributesFromBlock:self.blocks[hash]];
        }
    }];
}

#pragma mark - BRPeerDelegate

- (void)peerConnected:(BRPeer *)peer
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (peer.timestamp > now + 2*60*60 || peer.timestamp < now - 2*60*60) peer.timestamp = now; //timestamp sanity check
    self.connectFailures = 0;
    NSLog(@"%@:%d connected with lastblock %d", peer.host, peer.port, peer.lastblock);
    
    if (peer.lastblock + 10 < self.lastBlockHeight) { // drop peers that aren't synced yet, we can't help them
        [peer disconnect];
        return;
    }

    if (self.connected && (self.downloadPeer.lastblock >= peer.lastblock || self.lastBlockHeight >= peer.lastblock)) {
        if (self.lastBlockHeight < self.downloadPeer.lastblock) return; // don't load bloom filter yet if we're syncing
        [peer sendFilterloadMessage:self.bloomFilter.data];
        [peer sendInvMessageWithTxHashes:self.publishedTx.allKeys]; // publish unconfirmed tx
        [peer sendMempoolMessage];
        [peer sendPingMessageWithPongHandler:^(BOOL success) {
            if (! success) return;
            peer.synced = YES;
            [peer sendGetaddrMessage]; // request a list of other bitcoin peers
            [self removeUnrelayedTransactions];
        }];

        return; // we're already connected to a download peer
    }

    // select the peer with the lowest ping time to download the chain from if we're behind
    // BUG: XXX a malicious peer can report a higher lastblock to make us select them as the download peer, if two
    // peers agree on lastblock, use one of them instead
    for (BRPeer *p in self.connectedPeers) {
        if ((p.pingTime < peer.pingTime && p.lastblock >= peer.lastblock) || p.lastblock > peer.lastblock) peer = p;
    }

    [self.downloadPeer disconnect];
    self.downloadPeer = peer;
    _connected = YES;
    _bloomFilter = nil; // make sure the bloom filter is updated with any newly generated addresses
    [peer sendFilterloadMessage:self.bloomFilter.data];
    peer.currentBlockHeight = self.lastBlockHeight;
    
    if (self.lastBlockHeight < peer.lastblock) { // start blockchain sync
        self.lastRelayTime = 0;

        dispatch_async(dispatch_get_main_queue(), ^{ // setup a timer to detect if the sync stalls
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncTimeout) object:nil];
            [self performSelector:@selector(syncTimeout) withObject:nil afterDelay:PROTOCOL_TIMEOUT];

            dispatch_async(self.q, ^{
                // request just block headers up to a week before earliestKeyTime, and then merkleblocks after that
                // BUG: XXXX headers can timeout on slow connections (each message is over 160k)
                if (self.lastBlock.timestamp + 7*24*60*60 >= self.earliestKeyTime) {
                    [peer sendGetblocksMessageWithLocators:[self blockLocatorArray] andHashStop:nil];
                }
                else [peer sendGetheadersMessageWithLocators:[self blockLocatorArray] andHashStop:nil];
            });
        });
    }
    else { // we're already synced
        [self syncStopped];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerSyncFinishedNotification
             object:nil];
        });
    }
}

- (void)peer:(BRPeer *)peer disconnectedWithError:(NSError *)error
{
    NSLog(@"%@:%d disconnected%@%@", peer.host, peer.port, (error ? @", " : @""), (error ? error : @""));
    
    if ([error.domain isEqual:@"BreadWallet"] && error.code != DASH_TIMEOUT_CODE) {
        [self peerMisbehavin:peer]; // if it's protocol error other than timeout, the peer isn't following the rules
    }
    else if (error) { // timeout or some non-protocol related network error
        [self.peers removeObject:peer];
        self.connectFailures++;
    }

    for (NSData *txHash in self.txRelays.allKeys) {
        [self.txRelays[txHash] removeObject:peer];
    }

    if ([self.downloadPeer isEqual:peer]) { // download peer disconnected
        _connected = NO;
        self.downloadPeer = nil;
        if (self.connectFailures > MAX_CONNECT_FAILURES) self.connectFailures = MAX_CONNECT_FAILURES;
    }

    if (! self.connected && self.connectFailures == MAX_CONNECT_FAILURES) {
        [self syncStopped];
        
        // clear out stored peers so we get a fresh list from DNS on next connect attempt
        [self.misbehavinPeers removeAllObjects];
        [BRPeerEntity deleteObjects:[BRPeerEntity allObjects]];
        _peers = nil;

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerSyncFailedNotification
             object:nil userInfo:(error) ? @{@"error":error} : nil];
        });
    }
    else if (self.connectFailures < MAX_CONNECT_FAILURES && (self.taskId != UIBackgroundTaskInvalid ||
             [[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)) {
        [self connect]; // try connecting to another peer
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerTxStatusNotification object:nil];
    });
}

- (void)peer:(BRPeer *)peer relayedPeers:(NSArray *)peers
{
    NSLog(@"%@:%d relayed %d peer(s)", peer.host, peer.port, (int)peers.count);
    [self.peers addObjectsFromArray:peers];
    [self.peers minusSet:self.misbehavinPeers];
    [self sortPeers];

    // limit total to 2500 peers
    if (self.peers.count > 2500) [self.peers removeObjectsInRange:NSMakeRange(2500, self.peers.count - 2500)];

    NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate] - 3*60*60;

    // remove peers more than 3 hours old, or until there are only 1000 left
    while (self.peers.count > 1000 && [self.peers.lastObject timestamp] < t) {
        [self.peers removeObject:self.peers.lastObject];
    }

    if (peers.count > 1 && peers.count < 1000) [self savePeers]; // peer relaying is complete when we receive <1000
}

- (void)peer:(BRPeer *)peer relayedTransaction:(BRTransaction *)transaction
{
    BRWalletManager *m = [BRWalletManager sharedInstance];
    NSData *txHash = transaction.txHash;
    void (^callback)(NSError *error) = self.publishedCallback[txHash];

    NSLog(@"%@:%d relayed transaction %@", peer.host, peer.port, txHash);

    transaction.timestamp = [NSDate timeIntervalSinceReferenceDate];
    if (! [m.wallet registerTransaction:transaction]) return;
    if (peer == self.downloadPeer) self.lastRelayTime = [NSDate timeIntervalSinceReferenceDate];
    [self.txHashes addObject:txHash];
    self.publishedTx[txHash] = transaction;
        
    // keep track of how many peers have or relay a tx, this indicates how likely the tx is to confirm
    if (callback || ! [self.txRelays[txHash] containsObject:peer]) {
        if (! self.txRelays[txHash]) self.txRelays[txHash] = [NSMutableSet set];
        [self.txRelays[txHash] addObject:peer];
        if (callback) [self.publishedCallback removeObjectForKey:txHash];

        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(txTimeout:) object:txHash];
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerTxStatusNotification object:nil];
            if (callback) callback(nil);
        });
    }
    
    if (! _bloomFilter) return; // bloom filter is aready being updated

    // the transaction likely consumed one or more wallet addresses, so check that at least the next <gap limit>
    // unused addresses are still matched by the bloom filter
    NSArray *external = [m.wallet addressesWithGapLimit:SEQUENCE_GAP_LIMIT_EXTERNAL internal:NO],
            *internal = [m.wallet addressesWithGapLimit:SEQUENCE_GAP_LIMIT_INTERNAL internal:YES];
        
    for (NSString *address in [external arrayByAddingObjectsFromArray:internal]) {
        NSData *hash = address.addressToHash160;

        if (! hash || [_bloomFilter containsData:hash]) continue;
        _bloomFilter = nil; // reset bloom filter so it's recreated with new wallet addresses
        [self updateFilter];
        break;
    }
}

- (void)peer:(BRPeer *)peer hasTransaction:(NSData *)txHash
{
    BRWalletManager *m = [BRWalletManager sharedInstance];
    BRTransaction *tx = self.publishedTx[txHash];
    void (^callback)(NSError *error) = self.publishedCallback[txHash];
    
    NSLog(@"%@:%d has transaction %@", peer.host, peer.port, txHash);
    if ((! tx || ! [m.wallet registerTransaction:tx]) && ! [m.wallet transactionForHash:txHash]) return;
    if (peer == self.downloadPeer) self.lastRelayTime = [NSDate timeIntervalSinceReferenceDate];
        
    // keep track of how many peers have or relay a tx, this indicates how likely the tx is to confirm
    if (callback || ! [self.txRelays[txHash] containsObject:peer]) {
        if (! self.txRelays[txHash]) self.txRelays[txHash] = [NSMutableSet set];
        [self.txRelays[txHash] addObject:peer];
        if (callback) [self.publishedCallback removeObjectForKey:txHash];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(txTimeout:) object:txHash];
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerTxStatusNotification object:nil];
            if (callback) callback(nil);
        });
    }
}

- (void)peer:(BRPeer *)peer rejectedTransaction:(NSData *)txHash withCode:(uint8_t)code
{
    if ([self.txRelays[txHash] containsObject:peer]) {
        [self.txRelays[txHash] removeObject:peer];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerTxStatusNotification object:nil];
        });
    }
}

- (void)peer:(BRPeer *)peer relayedBlock:(BRMerkleBlock *)block
{
    // ignore block headers that are newer than one week before earliestKeyTime (headers have 0 totalTransactions)
    if (block.totalTransactions == 0 && block.timestamp + 7*24*60*60 > self.earliestKeyTime + 2*60*60) return;

    // track the observed bloom filter false positive rate using a low pass filter to smooth out variance
    if (peer == self.downloadPeer && block.totalTransactions > 0) {
        NSMutableSet *fp = [NSMutableSet setWithArray:block.txHashes];
    
        // 1% low pass filter, also weights each block by total transactions, using 600 tx per block as typical
        [fp minusSet:self.txHashes];
        self.fpRate = self.fpRate*(1.0 - 0.01*block.totalTransactions/600) + 0.01*fp.count/600;

        // false positive rate sanity check
        if (self.downloadPeer.status == BRPeerStatusConnected && self.fpRate > BLOOM_DEFAULT_FALSEPOSITIVE_RATE*10.0) {
            NSLog(@"%@:%d bloom filter false positive rate %f too high after %d blocks, disconnecting...", peer.host,
                  peer.port, self.fpRate, self.lastBlockHeight + 1 - self.filterUpdateHeight);
            self.tweak = arc4random(); // new random filter tweak in case we matched satoshidice or something
            [self.downloadPeer disconnect];
        }
        else if (self.lastBlockHeight + 500 < peer.lastblock && self.fpRate > BLOOM_REDUCED_FALSEPOSITIVE_RATE*10.0) {
            [self updateFilter]; // rebuild bloom filter when it starts to degrade
        }
    }

    if (! _bloomFilter) { // ingore potentially incomplete blocks when a filter update is pending
        if (peer == self.downloadPeer) self.lastRelayTime = [NSDate timeIntervalSinceReferenceDate];
        return;
    }

    BRMerkleBlock *prev = self.blocks[block.prevBlock];
    NSTimeInterval transitionTime = 0, txTimestamp = 0;

    if (! prev) { // block is an orphan
        NSLog(@"%@:%d relayed orphan block %@, previous %@, last block is %@, height %d", peer.host, peer.port,
              block.blockHash, block.prevBlock, self.lastBlock.blockHash, self.lastBlockHeight);

        // ignore orphans older than one week ago
        if (block.timestamp < [NSDate timeIntervalSinceReferenceDate] - 7*24*60*60) return;

        // call getblocks, unless we already did with the previous block, or we're still downloading the chain
        if (self.lastBlockHeight >= peer.lastblock && ! [self.lastOrphan.blockHash isEqual:block.prevBlock]) {
            NSLog(@"%@:%d calling getblocks", peer.host, peer.port);
            [peer sendGetblocksMessageWithLocators:[self blockLocatorArray] andHashStop:nil];
        }

        self.orphans[block.prevBlock] = block; // orphans are indexed by previous block rather than their own hash
        self.lastOrphan = block;
        return;
    }

    block.height = prev.height + 1;
    txTimestamp = (block.timestamp + prev.timestamp)/2;
    
//    BRMerkleBlock *b = block;
//    
//    for (uint32_t i = 0; b && i < 2100; i++) {
//        b = self.blocks[b.prevBlock];
//    }
//    
//    while (b) { // free up some memory
//        b = self.blocks[b.prevBlock];
//        if (b) [self.blocks removeObjectForKey:b.blockHash];
//    }

    // verify block difficulty if block is past last checkpoint
    if (block.height > checkpoint_array[CHECKPOINT_COUNT - 1].height && ![block verifyDifficultyWithPreviousBlocks:self.blocks]) {
        NSLog(@"%@:%d relayed block with invalid difficulty height %d target %x, blockHash: %@", peer.host, peer.port,
              block.height,block.target, block.blockHash);
        [self peerMisbehavin:peer];
        return;
    }

    // verify block chain checkpoints
    if (self.checkpoints[@(block.height)] && ! [block.blockHash isEqual:self.checkpoints[@(block.height)]]) {
        NSLog(@"%@:%d relayed a block that differs from the checkpoint at height %d, blockHash: %@, expected: %@",
              peer.host, peer.port, block.height, block.blockHash, self.checkpoints[@(block.height)]);
        [self peerMisbehavin:peer];
        return;
    }

    if ([block.prevBlock isEqual:self.lastBlock.blockHash]) { // new block extends main chain
        if ((block.height % 500) == 0 || block.txHashes.count > 0 || block.height > peer.lastblock) {
            NSLog(@"adding block at height: %d, false positive rate: %f", block.height, self.fpRate);
        }

        self.blocks[block.blockHash] = block;
        self.lastBlock = block;
        [self setBlockHeight:block.height andTimestamp:txTimestamp forTxHashes:block.txHashes];
        if (peer == self.downloadPeer) self.lastRelayTime = [NSDate timeIntervalSinceReferenceDate];
        self.downloadPeer.currentBlockHeight = block.height;

        // track moving average transactions per block using a 1% low pass filter
        if (block.totalTransactions > 0) _averageTxPerBlock = _averageTxPerBlock*0.99 + block.totalTransactions*0.01;
    }
    else if (self.blocks[block.blockHash] != nil) { // we already have the block (or at least the header)
        if ((block.height % 500) == 0 || block.txHashes.count > 0 || block.height > peer.lastblock) {
            NSLog(@"%@:%d relayed existing block at height %d", peer.host, peer.port, block.height);
        }

        self.blocks[block.blockHash] = block;

        BRMerkleBlock *b = self.lastBlock;

        while (b && b.height > block.height) b = self.blocks[b.prevBlock]; // check if block is in main chain

        if ([b.blockHash isEqual:block.blockHash]) { // if it's not on a fork, set block heights for its transactions
            [self setBlockHeight:block.height andTimestamp:txTimestamp forTxHashes:block.txHashes];
            if (block.height == self.lastBlockHeight) self.lastBlock = block;
        }
    }
    else { // new block is on a fork
        if (block.height <= checkpoint_array[CHECKPOINT_COUNT - 1].height) { // fork is older than last checkpoint
            NSLog(@"ignoring block on fork older than most recent checkpoint, fork height: %d, blockHash: %@",
                  block.height, block.blockHash);
            return;
        }

        // special case, if a new block is mined while we're rescanning the chain, mark as orphan til we're caught up
        if (self.lastBlockHeight < peer.lastblock && block.height > self.lastBlockHeight + 1) {
            NSLog(@"marking new block at height %d as orphan until rescan completes", block.height);
            self.orphans[block.prevBlock] = block;
            self.lastOrphan = block;
            return;
        }

        NSLog(@"chain fork to height %d", block.height);
        self.blocks[block.blockHash] = block;
        if (block.height <= self.lastBlockHeight) return; // if fork is shorter than main chain, ingore it for now

        NSMutableArray *txHashes = [NSMutableArray array];
        BRMerkleBlock *b = block, *b2 = self.lastBlock;

        while (b && b2 && ! [b.blockHash isEqual:b2.blockHash]) { // walk back to where the fork joins the main chain
            b = self.blocks[b.prevBlock];
            if (b.height < b2.height) b2 = self.blocks[b2.prevBlock];
        }

        NSLog(@"reorganizing chain from height %d, new height is %d", b.height, block.height);

        // mark transactions after the join point as unconfirmed
        for (BRTransaction *tx in [[[BRWalletManager sharedInstance] wallet] recentTransactions]) {
            if (tx.blockHeight <= b.height) break;
            [txHashes addObject:tx.txHash];
        }

        [self setBlockHeight:TX_UNCONFIRMED andTimestamp:0 forTxHashes:txHashes];
        b = block;

        while (b.height > b2.height) { // set transaction heights for new main chain
            [self setBlockHeight:b.height andTimestamp:txTimestamp forTxHashes:b.txHashes];
            b = self.blocks[b.prevBlock];
            txTimestamp = (b.timestamp + [self.blocks[b.prevBlock] timestamp])/2;
        }

        self.lastBlock = block;
    }
    
    if (block.height == peer.lastblock && block == self.lastBlock) { // chain download is complete
        [self saveBlocks];
        [BRMerkleBlockEntity saveContext];
        [self syncStopped];
        [[BRWalletManager sharedInstance] setAverageBlockSize:self.averageTxPerBlock*TX_AVERAGE_SIZE];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerSyncFinishedNotification
             object:nil];
        });
    }

    if (block == self.lastBlock && self.orphans[block.blockHash]) { // check if the next block was received as an orphan
        BRMerkleBlock *b = self.orphans[block.blockHash];

        [self.orphans removeObjectForKey:block.blockHash];
        [self peer:peer relayedBlock:b];
    }

    if (block.height > peer.lastblock) { // notify that transaction confirmations may have changed
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerTxStatusNotification object:nil];
        });
    }
}

- (BRTransaction *)peer:(BRPeer *)peer requestedTransaction:(NSData *)txHash
{
    return self.publishedTx[txHash];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) return;
    [self rescan];
}

@end
