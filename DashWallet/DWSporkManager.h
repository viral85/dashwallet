//
//  DWSporkManager.h
//  dashwallet
//
//  Created by Sam Westrich on 10/18/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWSpork.h"

@class BRPeer;

@interface DWSporkManager : NSObject

+ (instancetype _Nullable)sharedInstance;

- (void)peer:(BRPeer * _Nullable)peer relayedSpork:(DWSpork * _Nonnull)spork;

@end
