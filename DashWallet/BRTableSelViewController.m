//
//  BRTableSelViewController.m
//  dashwallet
//
//  Created by Viral on 29/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRTableSelViewController.h"
#import "BRImportClasses.h"

@interface BRTableSelViewController ()

@end

@implementation BRTableSelViewController

@synthesize tblOpt;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// MARK: - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ArrayOpt.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"OptCell";
    UITableViewCell *cell = nil;
    
    NSDictionary *objDict = [self.ArrayOpt objectAtIndex:indexPath.row];
    
    cell = [tblOpt dequeueReusableCellWithIdentifier:cellId];
    cell.textLabel.text = [objDict objectForKey:@"name"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (self.selectedCell == indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCell = indexPath.row;
    [tblOpt reloadData];
}

- (IBAction)closeAct:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneAct:(id)sender
{
    /*
     tblType:
     1 = Bank Name 
     */
    if (self.selectedCell >= 0)
    {
        if(self.tblType == 1)
        {
        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateBankName" object:self userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%ld",(long)self.selectedCell] forKey:@"SelObjIndex"]];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
