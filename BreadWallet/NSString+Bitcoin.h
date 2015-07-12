//
//  NSString+Bitcoin.h
//  DashWallet
//
//  Created by  Quantum Exploreron 7/11/15.
//  Copyright (c) 2015 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BITCOIN_PUBKEY_ADDRESS      0
#define BITCOIN_SCRIPT_ADDRESS      5
#define BITCOIN_PUBKEY_ADDRESS_TEST 111
#define BITCOIN_SCRIPT_ADDRESS_TEST 196
#define BITCOIN_PRIVKEY             128
#define BITCOIN_PRIVKEY_TEST        239

@interface NSString (Bitcoin)

- (BOOL)isValidBitcoinAddress;
- (BOOL)isValidBitcoinPrivateKey;
- (BOOL)isValidBitcoinBIP38Key; // BIP38 encrypted keys: https://github.com/bitcoin/bips/blob/master/bip-0038.mediawiki

@end
