//
//  DWSporkManager.m
//  dashwallet
//
//  Created by Sam Westrich on 10/18/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "DWSporkManager.h"
#import "BRPeer.h"

@interface DWSporkManager()

@property (nonatomic,strong) NSMutableDictionary * sporkDictionary;

@end

@implementation DWSporkManager

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
    self.sporkDictionary = [NSMutableDictionary dictionary];
    return self;
}

- (void)peer:(BRPeer *)peer relayedSpork:(DWSpork *)spork {
    self.sporkDictionary[@(spork.identifier)] = spork;
}

@end
