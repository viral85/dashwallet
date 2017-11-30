//
//  BROfferCell.m
//  dashwallet
//
//  Created by Viral on 21/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BROfferCell.h"

@implementation BROfferCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.imgIcon.layer.cornerRadius = 5.0;
    self.imgIcon.layer.masksToBounds = YES;
    
    self.btnOrder.layer.cornerRadius = 5.0;
    self.btnOrder.layer.masksToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
