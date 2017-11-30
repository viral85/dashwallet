//
//  BROrderCell.h
//  dashwallet
//
//  Created by Viral on 23/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BROrderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *viewBack;
@property (weak, nonatomic) IBOutlet UIImageView *imgBank;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblSPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblSStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblSNameAcc;
@property (weak, nonatomic) IBOutlet UILabel *lblNameAcc;
@property (weak, nonatomic) IBOutlet UILabel *lblSAcc;
@property (weak, nonatomic) IBOutlet UILabel *lblAcc;
@property (weak, nonatomic) IBOutlet UILabel *lblSCashDep;
@property (weak, nonatomic) IBOutlet UILabel *lblCashDep;
@property (weak, nonatomic) IBOutlet UILabel *lblSDepDue;
@property (weak, nonatomic) IBOutlet UILabel *lblDepDue;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *btnDeposite;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hightBottomViewConstraint;

@end
