//
//  DWSporkEntity.h
//  dashwallet
//
//  Created by Sam Westrich on 10/20/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DWSpork;

@interface DWSporkEntity : NSManagedObject
    
@property (nonatomic,retain) NSData * signature;
@property (nonatomic) int64_t timeSigned;
@property (nonatomic) int64_t value;
@property (nonatomic) int32_t identifier;
    
- (instancetype)setAttributesFromSpork:(DWSpork *)spork;

@end
