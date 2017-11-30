//
//  BRConfirmViewController.h
//  dashwallet
//
//  Created by Viral on 22/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRConfirmViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblInst;
@property (weak, nonatomic) IBOutlet UITextField *txtCode;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;

@property(nonatomic, strong)NSString *holdiD;

- (IBAction)selConfirm:(id)sender;

@end
