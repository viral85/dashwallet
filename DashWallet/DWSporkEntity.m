//
//  DWSporkEntity.m
//  dashwallet
//
//  Created by Sam Westrich on 10/20/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "DWSporkEntity.h"
#import "DWSpork.h"

@implementation DWSporkEntity
    
@dynamic signature;
@dynamic timeSigned;
@dynamic value;
@dynamic identifier;

- (instancetype)setAttributesFromSpork:(DWSpork *)spork
{
    [self.managedObjectContext performBlockAndWait:^{
        self.identifier = spork.identifier;
        self.signature = spork.signature;
        self.timeSigned = spork.timeSigned;
        self.value = spork.value;
    }];
    
    return self;
}

@end
