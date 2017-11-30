//
//  BROfferCell.h
//  dashwallet
//
//  Created by Viral on 21/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BROfferCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblFirst;
@property (weak, nonatomic) IBOutlet UILabel *lblSecond;
@property (weak, nonatomic) IBOutlet UILabel *lblThird;
@property (weak, nonatomic) IBOutlet UILabel *lblFour;
@property (weak, nonatomic) IBOutlet UILabel *lblFive;
@property (weak, nonatomic) IBOutlet UIButton *btnOrder;

@end
