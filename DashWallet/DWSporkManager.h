//
//  DWSporkManager.h
//  dashwallet
//
//  Created by Sam Westrich on 10/18/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWSpork.h"

FOUNDATION_EXPORT NSString* _Nonnull const DWSporkManagerSporkUpdateNotification;

@class BRPeer;

@interface DWSporkManager : NSObject
    
@property (nonatomic,assign) BOOL instantSendActive;

+ (instancetype _Nullable)sharedInstance;

- (void)peer:(BRPeer * _Nullable)peer relayedSpork:(DWSpork * _Nonnull)spork;

@end
