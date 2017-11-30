//
//  BRBuyDashViewController.h
//  dashwallet
//
//  Created on 16/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRBuyDashViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblLooking;
@property (weak, nonatomic) IBOutlet UITextField *txtFirst;
@property (weak, nonatomic) IBOutlet UILabel *lblOr;
@property (weak, nonatomic) IBOutlet UITextField *txtSecond;

@property (weak, nonatomic) IBOutlet UITextField *txtZipCode;
@property (weak, nonatomic) IBOutlet UIButton *btnGetOffers;
@property (weak, nonatomic) IBOutlet UIView *orderView;
@property (weak, nonatomic) IBOutlet UIView *viewBuyMore;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hightBuyMoreConstraint;
@property (weak, nonatomic) IBOutlet UIButton *btnBuyMore;
@property (weak, nonatomic) IBOutlet UITableView *tblOrder;
- (IBAction)SelBuyMore:(id)sender;

- (IBAction)SelGetOffers:(id)sender;
@end
