//
//  BRAuthSecondViewController.h
//  dashwallet
//
//  Created by Viral on 22/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRAuthSecondViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblInstruction;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property(nonatomic, assign)NSInteger userAvability;

@property(nonatomic, strong)NSMutableDictionary *offerDict;

@property(nonatomic, strong)NSString *phoneNumber;

- (IBAction)selNext:(id)sender;

@end
