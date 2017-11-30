//
//  BRSellDashAdsViewController.h
//  dashwallet
//
//  Created by Viral on 29/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRSellDashAdsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btnSelectAccount;
@property (weak, nonatomic) IBOutlet UITextField *txtAccountName;
@property (weak, nonatomic) IBOutlet UITextField *txtAccountNo;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmAcc;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectPrice;

@property(nonatomic, strong)NSMutableArray *ArrayAds;
@property(nonatomic, strong)NSMutableArray *ArrayCurrency;
@property(nonatomic, strong)NSDictionary *DictCurrency;
@property (weak, nonatomic) IBOutlet UIView *viewNoDynamic;
@property (weak, nonatomic) IBOutlet UIButton *btnDynamicSel;
@property (weak, nonatomic) IBOutlet UILabel *lblDynamic;
@property (weak, nonatomic) IBOutlet UIButton *btnCreateAd;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hightTopviewConstraint;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectCurrency;
@property (weak, nonatomic) IBOutlet UITextField *txtDashAmount;
@property (weak, nonatomic) IBOutlet UIView *viewDynamic;
@property (weak, nonatomic) IBOutlet UIButton *btnPriMarkt;
@property (weak, nonatomic) IBOutlet UIButton *btnSecdMarkt;
@property (weak, nonatomic) IBOutlet UIButton *btnMinCurr;
@property (weak, nonatomic) IBOutlet UITextField *txtMinCurr;
@property (weak, nonatomic) IBOutlet UIButton *btnMaxCurr;
@property (weak, nonatomic) IBOutlet UITextField *txtMaxCurr;
@property (weak, nonatomic) IBOutlet UITextField *txtSellerFee;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topCreateAdConstraint;

- (IBAction)selAccountAct:(id)sender;
- (IBAction)selCreateAdAct:(id)sender;
- (IBAction)selPrimarktAct:(id)sender;
- (IBAction)selSecdmerktAct:(id)sender;
- (IBAction)selCurrAct:(id)sender;
@end
