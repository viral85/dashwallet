//
//  DWSporkManager.m
//  dashwallet
//
//  Created by Sam Westrich on 10/18/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "DWSporkManager.h"
#import "DWSpork.h"
#import "DWSporkEntity.h"
#import "NSManagedObject+Sugar.h"

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
    NSArray * sporkEntities = [DWSporkEntity allObjects];
    for (DWSporkEntity * sporkEntity in sporkEntities) {
        DWSpork * spork = [[DWSpork alloc] initWithIdentifier:sporkEntity.identifier value:sporkEntity.value timeSigned:sporkEntity.timeSigned signature:sporkEntity.signature];
        self.sporkDictionary[@(spork.identifier)] = spork;
    }
    return self;
}
    
-(BOOL)instantSendActive {
    DWSpork * instantSendSpork = self.sporkDictionary[@(Spork2InstantSendEnabled)];
    if (!instantSendSpork) return TRUE;//assume true
    return !!instantSendSpork.value;
}
    
- (void)peer:(BRPeer *)peer relayedSpork:(DWSpork *)spork {
    if (!spork.isValid) return; //sanity check
    DWSpork * currentSpork = self.sporkDictionary[@(spork.identifier)];
    BOOL updatedSpork = FALSE;
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] init];
    if (currentSpork) {
        //there was already a spork
        if (![currentSpork isEqualToSpork:spork]) {
            self.sporkDictionary[@(spork.identifier)] = spork; //set it to new one
            updatedSpork = TRUE;
            [dictionary setObject:currentSpork forKey:@"old"];
        } else {
            return; //nothing more to do
        }
    }
    [dictionary setObject:spork forKey:@"new"];
    
    if (!currentSpork || updatedSpork) {
        @autoreleasepool {
            [[DWSporkEntity managedObject] setAttributesFromSpork:spork]; // add new peers
        }
        [DWSporkEntity saveContext];
        [[NSNotificationCenter defaultCenter] postNotificationName:DWSporkManagerSporkUpdateNotification object:nil userInfo:dictionary];
    }
}
    
@end
