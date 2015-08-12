//
//  BRAmountViewController.m
//  DashWallet
//
//  Created by Aaron Voisine on 6/4/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BRAmountViewController.h"
#import "BRPaymentRequest.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"
#import "BRTransaction.h"

@interface BRAmountViewController ()

@property (nonatomic, strong) IBOutlet UITextField *amountField;
@property (nonatomic, strong) IBOutlet UILabel *localCurrencyLabel, *addressLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *payButton, *lock;
@property (nonatomic, strong) IBOutlet UIButton *delButton, *decimalButton;
@property (nonatomic, strong) IBOutlet UIImageView *wallpaper;
@property (nonatomic, strong) IBOutlet UIView *logo;

@property (nonatomic, assign) uint64_t amount;
@property (nonatomic, strong) NSCharacterSet *charset;
@property (nonatomic, strong) UILabel *swapLeftLabel, *swapRightLabel;
@property (nonatomic, assign) BOOL swapped;
@property (nonatomic, strong) id balanceObserver, backgroundObserver;

@end

@implementation BRAmountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    BRWalletManager *m = [BRWalletManager sharedInstance];
    NSMutableCharacterSet *charset = [NSMutableCharacterSet decimalDigitCharacterSet];

    [charset addCharactersInString:m.format.currencyDecimalSeparator];
    self.charset = charset;

    self.payButton = [[UIBarButtonItem alloc] initWithTitle:self.usingShapeshift?@"Shapeshift!":NSLocalizedString(@"pay", nil)
                      style:UIBarButtonItemStyleBordered target:self action:@selector(pay:)];
    self.amountField.attributedPlaceholder = [m attributedDashStringForAmount:0];
    [self.decimalButton setTitle:m.format.currencyDecimalSeparator forState:UIControlStateNormal];

    self.swapLeftLabel = [UILabel new];
    self.swapLeftLabel.font = self.localCurrencyLabel.font;
    self.swapLeftLabel.alpha = self.localCurrencyLabel.alpha;
    self.swapLeftLabel.textAlignment = self.localCurrencyLabel.textAlignment;
    self.swapLeftLabel.hidden = YES;

    self.swapRightLabel = [UILabel new];
    self.swapRightLabel.font = self.amountField.font;
    self.swapRightLabel.alpha = self.amountField.alpha;
    self.swapRightLabel.textAlignment = self.amountField.textAlignment;
    self.swapRightLabel.hidden = YES;

    [self updateLocalCurrencyLabel];
    
    self.balanceObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification object:nil queue:nil
        usingBlock:^(NSNotification *note) {
            if ([[BRPeerManager sharedInstance] syncProgress] < 1.0) return; // wait for sync before updating balance
            [self updateTitleView];
        }];
    
    self.backgroundObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil
        queue:nil usingBlock:^(NSNotification *note) {
            self.navigationItem.titleView = self.logo;
        }];
    if (self.usingShapeshift) {
        [self swapCurrency:self];
    }
}

- (void)dealloc
{
    if (self.balanceObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.balanceObserver];
    if (self.backgroundObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.backgroundObserver];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.usingShapeshift) {
        self.addressLabel.text = (self.to.length > 0) ?
                             [NSString stringWithFormat:NSLocalizedString(@"to: %@ (via Shapeshift)", nil), self.to] : nil;
    } else {
        self.addressLabel.text = (self.to.length > 0) ?
        [NSString stringWithFormat:NSLocalizedString(@"to: %@", nil), self.to] : nil;
    }
    self.wallpaper.hidden = NO;

    if (self.navigationController.viewControllers.firstObject != self) {
        self.navigationItem.leftBarButtonItem = nil;
        if ([[BRWalletManager sharedInstance] didAuthenticate]) [self unlock:nil];
    }
    else {
        self.payButton.title = NSLocalizedString(@"request", nil);
        self.navigationItem.rightBarButtonItem = self.payButton;
    }

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.amount = 0;
    if (self.navigationController.viewControllers.firstObject != self) self.wallpaper.hidden = animated;

    [super viewWillDisappear:animated];
}

- (void)updateLocalCurrencyLabel
{
    BRWalletManager *m = [BRWalletManager sharedInstance];
    uint64_t amount;
    if (self.usingShapeshift) {
        amount = (self.swapped) ? [m amountForBitcoinCurrencyString:self.amountField.text] * 1.035 :
        [m amountForString:self.amountField.text] * 0.97;
    } else {
        amount = (self.swapped) ? [m amountForLocalCurrencyString:self.amountField.text] :
                      [m amountForString:self.amountField.text];
    }

    self.swapLeftLabel.hidden = YES;
    self.localCurrencyLabel.hidden = NO;
    if (self.usingShapeshift) {
        self.localCurrencyLabel.text = [NSString stringWithFormat:@"(~%@)", (self.swapped) ? [m attributedDashStringForAmount:amount]:[m bitcoinCurrencyStringForAmount:amount]];
    } else {
        self.localCurrencyLabel.text = [NSString stringWithFormat:@"(%@)", (self.swapped) ? [m attributedDashStringForAmount:amount]:[m localCurrencyStringForAmount:amount]];
    }
    self.localCurrencyLabel.textColor = (amount > 0) ? [UIColor grayColor] : [UIColor colorWithWhite:0.75 alpha:1.0];
}

-(void)updateTitleView {
    BRWalletManager *m = [BRWalletManager sharedInstance];
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 100)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    NSMutableAttributedString * attributedDashString = [[m attributedDashStringForAmount:m.wallet.balance] mutableCopy];
    NSString * titleString = [NSString stringWithFormat:@" (%@)",
                              [m localCurrencyStringForAmount:m.wallet.balance]];
    [attributedDashString appendAttributedString:[[NSAttributedString alloc] initWithString:titleString]];
    titleLabel.attributedText = attributedDashString;
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - IBAction

- (IBAction)unlock:(id)sender
{
    BRWalletManager *m = [BRWalletManager sharedInstance];
    
    if (sender && ! m.didAuthenticate && ! [m authenticateWithPrompt:nil andTouchId:YES]) return;
    
    self.navigationItem.titleView = nil;
    [self.navigationItem setRightBarButtonItem:self.payButton animated:(sender) ? YES : NO];
}

- (IBAction)number:(id)sender
{
    NSUInteger l = [self.amountField.text rangeOfCharacterFromSet:self.charset options:NSBackwardsSearch].location;

    l = (l < self.amountField.text.length) ? l + 1 : self.amountField.text.length;
    [self textField:self.amountField shouldChangeCharactersInRange:NSMakeRange(l, 0)
     replacementString:[(UIButton *)sender titleLabel].text];
}

- (IBAction)del:(id)sender
{
    NSUInteger l = [self.amountField.text rangeOfCharacterFromSet:self.charset options:NSBackwardsSearch].location;

    if (l < self.amountField.text.length) {
        [self textField:self.amountField shouldChangeCharactersInRange:NSMakeRange(l, 1) replacementString:@""];
    }
}

- (IBAction)pay:(id)sender
{
    if (self.usingShapeshift) {
        BRWalletManager *m = [BRWalletManager sharedInstance];
        
        self.amount = (self.swapped) ? [m amountForBitcoinString:self.amountField.text]:
        [m amountForString:self.amountField.text];
        
        if (self.amount == 0) return;
        if (self.swapped)
            [self.delegate amountViewController:self shapeshiftBitcoinAmount:self.amount approximateDashAmount:[m amountForBitcoinCurrencyString:self.amountField.text]];
        else
            [self.delegate amountViewController:self shapeshiftDashAmount:self.amount];
    } else {
        BRWalletManager *m = [BRWalletManager sharedInstance];

        self.amount = (self.swapped) ? [m amountForLocalCurrencyString:self.amountField.text] :
                      [m amountForString:self.amountField.text];

        if (self.amount == 0) return;
        
        [self.delegate amountViewController:self selectedAmount:self.amount];
    }
}

- (IBAction)done:(id)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)swapCurrency:(id)sender
{
    self.swapped = ! self.swapped;

    if (self.swapLeftLabel.hidden) {
        self.swapLeftLabel.text = self.localCurrencyLabel.text;
        self.swapLeftLabel.textColor = (self.amountField.text.length > 0) ? self.amountField.textColor :
                                       [UIColor colorWithWhite:0.75 alpha:1.0];
        self.swapLeftLabel.frame = self.localCurrencyLabel.frame;
        [self.localCurrencyLabel.superview addSubview:self.swapLeftLabel];
        self.swapLeftLabel.hidden = NO;
        self.localCurrencyLabel.hidden = YES;
    }

    if (self.swapRightLabel.hidden) {
        self.swapRightLabel.text = (self.amountField.text.length > 0) ? self.amountField.text :
                                   self.amountField.placeholder;
        self.swapRightLabel.textColor = (self.amountField.text.length > 0) ? self.amountField.textColor :
                                        [UIColor colorWithWhite:0.75 alpha:1.0];
        self.swapRightLabel.frame = self.amountField.frame;
        [self.amountField.superview addSubview:self.swapRightLabel];
        self.swapRightLabel.hidden = NO;
        self.amountField.hidden = YES;
    }

    CGFloat scale = self.swapRightLabel.font.pointSize/self.swapLeftLabel.font.pointSize;
    BRWalletManager *m = [BRWalletManager sharedInstance];
    NSString *s = (self.swapped) ? self.localCurrencyLabel.text : self.amountField.text;
    uint64_t amount =
        [m amountForLocalCurrencyString:(self.swapped) ? [s substringWithRange:NSMakeRange(1, s.length - 2)] : s];

    if (self.usingShapeshift) {
        self.localCurrencyLabel.text = [NSString stringWithFormat:@"(~%@)", (self.swapped) ? [m attributedDashStringForAmount:amount] :
                                        [m bitcoinCurrencyStringForAmount:amount]];
        self.amountField.attributedText = (self.swapped) ? [[NSAttributedString alloc] initWithString:[m bitcoinCurrencyStringForAmount:amount]]:[m attributedDashStringForAmount:amount];
    } else {
        self.localCurrencyLabel.text = [NSString stringWithFormat:@"(%@)", (self.swapped) ? [m attributedDashStringForAmount:amount] :
                                    [m localCurrencyStringForAmount:amount]];
        self.amountField.attributedText = (self.swapped) ? [[NSAttributedString alloc] initWithString:[m localCurrencyStringForAmount:amount]]:[m attributedDashStringForAmount:amount];
    }

    if (amount == 0) {
        self.amountField.placeholder = self.amountField.text;
        self.amountField.text = nil;
    }
    else self.amountField.placeholder = nil;

    [self.view layoutIfNeeded];
    
    CGPoint p = CGPointMake(self.localCurrencyLabel.frame.origin.x + self.localCurrencyLabel.bounds.size.width/2.0 +
                            self.amountField.bounds.size.width/2.0,
                            self.localCurrencyLabel.center.y/2.0 + self.amountField.center.y/2.0);

    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.swapLeftLabel.transform = CGAffineTransformMakeScale(scale/0.85, scale/0.85);
        self.swapRightLabel.transform = CGAffineTransformMakeScale(0.85/scale, 0.85/scale);
    } completion:nil];

    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.swapLeftLabel.center = self.swapRightLabel.center = p;
    } completion:^(BOOL finished) {
        self.swapLeftLabel.transform = CGAffineTransformMakeScale(0.85, 0.85);
        self.swapRightLabel.transform = CGAffineTransformMakeScale(1.0/0.85, 1.0/0.85);
        self.swapLeftLabel.text = self.localCurrencyLabel.text;
        self.swapRightLabel.text = (self.amountField.text.length > 0) ? self.amountField.text :
                                   self.amountField.placeholder;
        self.swapLeftLabel.textColor = self.localCurrencyLabel.textColor;
        self.swapRightLabel.textColor = (self.amountField.text.length > 0) ? self.amountField.textColor :
                                        [UIColor colorWithWhite:0.75 alpha:1.0];
        [self.swapLeftLabel sizeToFit];
        [self.swapRightLabel sizeToFit];
        self.swapLeftLabel.center = self.swapRightLabel.center = p;

        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0
        options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.swapLeftLabel.transform = CGAffineTransformIdentity;
            self.swapRightLabel.transform = CGAffineTransformIdentity;
        } completion:nil];

        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0
        options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.swapLeftLabel.frame = self.localCurrencyLabel.frame;
            self.swapRightLabel.frame = self.amountField.frame;
        } completion:nil];
    }];
}

- (IBAction)pressSwapButton:(id)sender
{
    if (self.swapLeftLabel.hidden) {
        self.swapLeftLabel.text = self.localCurrencyLabel.text;
        self.swapLeftLabel.frame = self.localCurrencyLabel.frame;
        [self.localCurrencyLabel.superview addSubview:self.swapLeftLabel];
        self.swapLeftLabel.hidden = NO;
        self.localCurrencyLabel.hidden = YES;
    }

    self.swapLeftLabel.textColor = self.localCurrencyLabel.textColor;

    if (self.swapRightLabel.hidden) {
        self.swapRightLabel.text = (self.amountField.text.length > 0) ? self.amountField.text :
                                   self.amountField.placeholder;
        self.swapRightLabel.frame = self.amountField.frame;
        [self.amountField.superview addSubview:self.swapRightLabel];
        self.swapRightLabel.hidden = NO;
        self.amountField.hidden = YES;
    }

    self.swapRightLabel.textColor = (self.amountField.text.length > 0) ? self.amountField.textColor :
                                    [UIColor colorWithWhite:0.75 alpha:1.0];

    [UIView animateWithDuration:0.1 animations:^{
        //self.swapLeftLabel.transform = CGAffineTransformMakeScale(0.85, 0.85);
        self.swapLeftLabel.textColor = self.swapRightLabel.textColor;
        self.swapRightLabel.textColor = self.localCurrencyLabel.textColor;
        if (self.usingShapeshift) {
            self.swapLeftLabel.text = [[self.swapLeftLabel.text stringByReplacingOccurrencesOfString:@"(~" withString:@""]
                                   stringByReplacingOccurrencesOfString:@")" withString:@""];
        } else {
            self.swapLeftLabel.text = [[self.swapLeftLabel.text stringByReplacingOccurrencesOfString:@"(" withString:@""]
                                       stringByReplacingOccurrencesOfString:@")" withString:@""];
        }
    }];
}

- (IBAction)releaseSwapButton:(id)sender
{
    [UIView animateWithDuration:0.1 animations:^{
        //self.swapLeftLabel.transform = CGAffineTransformIdentity;
        self.swapLeftLabel.textColor = self.localCurrencyLabel.textColor;
    } completion:^(BOOL finished) {
        self.swapLeftLabel.hidden = self.swapRightLabel.hidden = YES;
        self.localCurrencyLabel.hidden = self.amountField.hidden = NO;
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    BRWalletManager *m = [BRWalletManager sharedInstance];
    NSNumberFormatter *f;
    if (self.usingShapeshift) {
        f = (self.swapped) ? m.bitcoinFormat:m.format;
    } else {
        f = (self.swapped) ? m.localFormat:m.format;
    }
    NSUInteger mindigits = f.minimumFractionDigits;
    NSUInteger point = [textField.text rangeOfString:f.currencyDecimalSeparator].location, l;
    NSString *t = textField.text ? [textField.text stringByReplacingCharactersInRange:range withString:string] : string;

    f.minimumFractionDigits = 0;
    t = [f stringFromNumber:[f numberFromString:t]];
    l = [textField.text rangeOfCharacterFromSet:self.charset options:NSBackwardsSearch].location;
    l = (l < textField.text.length) ? l + 1 : textField.text.length;

    if (! string.length && point != NSNotFound) { // delete trailing char
        t = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([t isEqual:[f stringFromNumber:@0]]) t = @"";
    }
    else if ((string.length > 0 && textField.text.length > 0 && t == nil) ||
             (point != NSNotFound && l - point > f.maximumFractionDigits)) {
        f.minimumFractionDigits = mindigits;
        return NO; // too many digits
    }
    else if ([string isEqual:f.currencyDecimalSeparator] && (! textField.text.length || point == NSNotFound)) {
        if (! textField.text.length) t = [f stringFromNumber:@0]; // if first char is '.', prepend a zero
        l = [t rangeOfCharacterFromSet:self.charset options:NSBackwardsSearch].location;
        l = (l < t.length) ? l + 1 : t.length;
        t = [t stringByReplacingCharactersInRange:NSMakeRange(l, 0) withString:f.currencyDecimalSeparator];
    }
    else if ([string isEqual:@"0"]) {
        if (! textField.text.length) { // if first digit is zero, append a '.'
            t = [f stringFromNumber:@0];
            l = [t rangeOfCharacterFromSet:self.charset options:NSBackwardsSearch].location;
            l = (l < t.length) ? l + 1 : t.length;
            t = [t stringByReplacingCharactersInRange:NSMakeRange(l, 0) withString:f.currencyDecimalSeparator];
        }
        else if (point != NSNotFound) { // handle multiple zeros after '.'
            t = [textField.text stringByReplacingCharactersInRange:NSMakeRange(l, 0) withString:@"0"];
        }
    }

//    l = [t rangeOfCharacterFromSet:self.charset options:NSBackwardsSearch].location;
//    l = (l < t.length) ? l + 1 : t.length;
//
//    // don't allow values below TX_MIN_OUTPUT_AMOUNT
//    if (t.length > 0 && [t rangeOfString:f.currencyDecimalSeparator].location != NSNotFound &&
//        [m amountForString:[t stringByReplacingCharactersInRange:NSMakeRange(l, 0) withString:@"9"]] <
//        TX_MIN_OUTPUT_AMOUNT) {
//        return NO;
//    }
    f.minimumFractionDigits = mindigits;
    textField.text = t;
    if (t.length > 0 && textField.placeholder.length > 0) textField.placeholder = nil;

    if (t.length == 0 && textField.placeholder.length == 0) {
        if (self.usingShapeshift) {
            textField.attributedPlaceholder = (self.swapped) ? [[NSAttributedString alloc] initWithString:[m bitcoinCurrencyStringForAmount:0]]:[m attributedDashStringForAmount:0];
        } else {
            textField.attributedPlaceholder = (self.swapped) ? [[NSAttributedString alloc] initWithString:[m localCurrencyStringForAmount:0]]:[m attributedDashStringForAmount:0];
        }
    }
    
    if (self.navigationController.viewControllers.firstObject != self) {
        if (! m.didAuthenticate && t.length == 0 && self.navigationItem.rightBarButtonItem != self.lock) {
            [self.navigationItem setRightBarButtonItem:self.lock animated:YES];
        }
        else if (t.length > 0 && self.navigationItem.rightBarButtonItem != self.payButton) {
            [self.navigationItem setRightBarButtonItem:self.payButton animated:YES];
        }
    }

    self.swapRightLabel.hidden = YES;
    textField.hidden = NO;
    [self updateLocalCurrencyLabel];

    return NO;
}

@end
