//
//  BRSellDashViewController.m
//  dashwallet
//
//  Created on 16/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRSellDashViewController.h"
#import "BRImportClasses.h"
#import "BRSellDashPassViewController.h"

@interface BRSellDashViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>

{
    NSMutableArray *pickerArray;
    NSString *countryCode;
    NSDictionary *dictCurrency;
}

@end

@implementation BRSellDashViewController

@synthesize txtPhone,btnNext,btnCountyCode;

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Create tap gesture for hide keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Memory allocation
    pickerArray = [[NSMutableArray alloc]init];
    
    // Intial setup view
    [self intialSetupView];

    self.pickerObj.dataSource = self;
    self.pickerObj.delegate = self;

    // Get Country Code
    [self getCountyDataFromJson];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)intialSetupView
{
    self.lblInstruction.text = @"A mobile phone that can receive text message is required for order verification.";
    [self.btnNext setTitle:@"Next" forState:UIControlStateNormal];
    self.txtPhone.placeholder = @"Phone";
    [self.btnCountyCode setTitle:@"" forState:UIControlStateNormal];
  
    [self.pickerObj setHidden:TRUE];
    

    
}
-(void)dismissKeyboard
{
    [self.view endEditing:YES];
    [self.pickerObj setHidden:TRUE];
}
-(void)getCountyDataFromJson
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];

    if(data != NULL)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        pickerArray = [dict objectForKey:@"countries"];
        
        NSDictionary *countryDict = [pickerArray objectAtIndex:0];
        //NSLog(@"DIC  %@",countryDict);
        NSString *string = [NSString stringWithFormat:@"%@ (%@)",[countryDict objectForKey:@"name"],[countryDict objectForKey:@"code"]];
        [self.btnCountyCode setTitle:string forState:UIControlStateNormal];
        
        dictCurrency = countryDict.mutableCopy;

        countryCode = [countryDict objectForKey:@"code"];
    }
}

#pragma mark - UIAction Method
- (IBAction)selCountryCode:(id)sender
{
    [self.view endEditing:YES];
    [self.pickerObj setHidden:false];
}
- (IBAction)selNext:(id)sender
{
    [self.view endEditing:true];
    
    if([txtPhone.text length] == 0)
    {
        [BRHelprClass showAlertwithTitle:@"Dash" withMessage:@"Please enter mobile number" withViewController:self];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self CheckAuthApiCall1];
        });
        
    }
    
}

#pragma mark - UITextBox Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.pickerObj setHidden:TRUE];
    
    
    const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");
    
    if (isBackSpace == -8) {
        // NSLog(@"Backspace was pressed");
        return YES;
    }
    
    
    /*  limit to only numeric characters  */
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            return YES;
        }
    }
    
    return NO;
    
    /*  limit the users input to only 9 characters
    NSUInteger newLength = [customTextField.text length] + [string length] - range.length;
    return (newLength > 9) ? NO : YES;*/
}


#pragma mark - UIPickerView Delegate
// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerArray.count;
}
// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSDictionary *countryDict = [pickerArray objectAtIndex:row];
    //NSLog(@"DIC  %@",countryDict);
    NSString *string = [NSString stringWithFormat:@"%@ (%@)",[countryDict objectForKey:@"name"],[countryDict objectForKey:@"code"]];
    
    return string;
}
- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    
    //Here, like the table view you can get the each section of each row if you've multiple sections
   
    
    NSDictionary *countryDict = [pickerArray objectAtIndex:row];
    //NSLog(@"DIC  %@",countryDict);
    NSString *string = [NSString stringWithFormat:@"%@ (%@)",[countryDict objectForKey:@"name"],[countryDict objectForKey:@"code"]];
    
    dictCurrency = countryDict.mutableCopy;
    
    [self.btnCountyCode setTitle:string forState:UIControlStateNormal];
    countryCode = [countryDict objectForKey:@"code"];
    
    [UIView transitionWithView:self.pickerObj
                      duration:0.4
                   options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.pickerObj setHidden:TRUE];
                    }
                    completion:NULL];
    
   // [self.pickerObj setHidden:TRUE];
}
#pragma mark - WebServices Call
- (void)CheckAuthApiCall1
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //  NSMutableDictionary *dicParameters = [self setDiscoveryParameters];
    
    //https://wallofcoins.com/
    NSString *authUrl = [NSString stringWithFormat:@"https://wallofcoins.com/api/v1/auth/%@%@/",countryCode,txtPhone.text];
    
    // NSLog(@"Auth URL : %@",authUrl);
    
    //api/v1/auth/{phone}/
    
    
    [BRWebServices callGetWithURL:authUrl withParameters:nil withViewCtr:self withSuccessCompletionHandler:^(id responseObject) {
        
        if (responseObject) {
            [hud hideAnimated:YES];
            NSDictionary *dicResponse = (NSDictionary*)responseObject;
            
            // Existing User
            [self moveToPasswordView:1];
            
        }
        else{
            [hud hideAnimated:YES];
            [BRHelprClass showAlertwithTitle:DASH withMessage:SomthingErrorMsg withViewController:self];
        }
        
    } withFailureCompletionHandler:^(AFHTTPRequestOperation *operation, NSError *error, BOOL Failure) {
        
        // NSLog(@"CODE : %ld",(long)operation.response.statusCode);
        
        if (operation.response.statusCode == 404)
        {
            [hud hideAnimated:YES];
            //404 - Means New Register Move to Password Screen
            [self moveToPasswordView:0];
        }
        else if (Failure && ![operation isCancelled]) {
            [hud hideAnimated:YES];
            [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
        }
        else
        {
            [hud hideAnimated:YES];
            [BRHelprClass showAlertwithTitle:@"Dash" withMessage:SomthingErrorMsg withViewController:self];
        }
    }];
}
- (void)moveToPasswordView:(NSUInteger)userType
{
    [BREventManager saveEvent:@"sell_dash:get_auth_second"];
    BRSellDashPassViewController *authObj
    = [self.storyboard instantiateViewControllerWithIdentifier:@"BRSellDashPassVC"];
    
    authObj.userAvability = userType;
    authObj.phoneNumber = [NSString stringWithFormat:@"%@%@",countryCode,txtPhone.text];
    authObj.DictCurr = dictCurrency;
    
    [self.navigationController pushViewController:authObj animated:YES];
}
@end
