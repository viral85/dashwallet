//
//  BRTableSelViewController.h
//  dashwallet
//
//  Created by Viral on 29/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRTableSelViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tblOpt;

@property(nonatomic, strong)NSMutableArray *ArrayOpt;
@property(nonatomic, assign)NSInteger tblType;
@property(nonatomic, assign)NSInteger selectedCell;

- (IBAction)closeAct:(id)sender;
- (IBAction)doneAct:(id)sender;

@end
