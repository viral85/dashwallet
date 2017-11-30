//
//  BRSellDashViewController.h
//  dashwallet
//
//  Created on 16/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRSellDashViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblInstruction;
@property (weak, nonatomic) IBOutlet UIButton *btnCountyCode;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerObj;

@end
