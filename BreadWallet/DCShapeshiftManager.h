//
//  DCShapeshiftManager.h
//  DashWallet
//
//  Created by  Quantum Exploreron 7/14/15.
//  Copyright (c) 2015 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCShapeshiftManager : NSObject

@property (nonatomic,strong) NSDate * lastMarketInfoCheck;
@property (nonatomic,assign) double rate;
@property (nonatomic,assign) unsigned long long limit;
@property (nonatomic,assign) unsigned long long min;

+ (instancetype)sharedInstance;

////////////////////////////////////////////////////////////////////
/*
    url: shapeshift.io/marketinfo/dash_btc
    method: GET

    Success Output:
    {
        "pair"     : "dash_btc",
        "rate"     : 130.12345678,
        "limit"    : 1.2345,
        "min"      : 0.02621232,
        "minerFee" : 0.0001
    }
*/
////////////////////////////////////////////////////////////////////
-(void)GET_marketInfo:(void (^)(NSDictionary *marketInfo, NSError *error))completionBlock;


////////////////////////////////////////////////////////////////////
/*
    url:  shapeshift.io/shift
    method: POST
    data type: JSON
    data required:
    withdrawal     = the address for resulting coin to be sent to
    pair       = what coins are being exchanged in the form [input coin]_[output coin]  ie btc_ltc
    returnAddress  = (Optional) address to return deposit to if anything goes wrong with exchange
    destTag    = (Optional) Destination tag that you want appended to a Ripple payment to you
    rsAddress  = (Optional) For new NXT accounts to be funded, you supply this on NXT payment to you
    apiKey     = (Optional) Your affiliate PUBLIC KEY, for volume tracking, affiliate payments, split-shifts, etc...

    example data: {"withdrawal":"AAAAAAAAAAAAA", "pair":"btc_ltc", returnAddress:"BBBBBBBBBBB"}

    Success Output:
    {
    deposit: [Deposit Address (or memo field if input coin is BTS / BITUSD)],
    depositType: [Deposit Type (input coin symbol)],
    withdrawal: [Withdrawal Address], //-- will match address submitted in post
    withdrawalType: [Withdrawal Type (output coin symbol)],
    public: [NXT RS-Address pubkey (if input coin is NXT)],
        xrpDestTag : [xrpDestTag (if input coin is XRP)],
    apiPubKey: [public API attached to this shift, if one was given]
    }
 */
////////////////////////////////////////////////////////////////////

-(void)POST_ShiftWithAddress:(NSString*)withdrawalAddress returnAddress:(NSString*)returnAddress completionBlock:(void (^)(NSDictionary *shiftInfo, NSError *error))completionBlock;

////////////////////////////////////////////////////////////////////
/*
    url: shapeshift.io/sendamount
    method: POST
    data type: JSON

    //1. Send amount request


    Data required:

    amount          = the amount to be sent to the withdrawal address
    withdrawal      = the address for coin to be sent to
    pair            = what coins are being exchanged in the form [input coin]_[output coin]  ie ltc_btc
    returnAddress   = (Optional) address to return deposit to if anything goes wrong with exchange
    destTag         = (Optional) Destination tag that you want appended to a Ripple payment to you
    rsAddress       = (Optional) For new NXT accounts to be funded, supply this on NXT payment to you
    apiKey          = (Optional) Your affiliate PUBLIC KEY, for volume tracking, affiliate payments, split-shifts, etc...

    example data {"amount":123, "withdrawal":"123ABC", "pair":"ltc_btc", returnAddress:"BBBBBBB"}


    Success Output:


    {
    success:
        {
        pair: [pair],
        withdrawal: [Withdrawal Address], //-- will match address submitted in post
        withdrawalAmount: [Withdrawal Amount], // Amount of the output coin you will receive
        deposit: [Deposit Address (or memo field if input coin is BTS / BITUSD)],
        depositAmount: [Deposit Amount], // Exact amount of input coin to send in
        expiration: [timestamp when this will expire],
        quotedRate: [the exchange rate to be honored]
        apiPubKey: [public API attached to this shift, if one was given]
        }
    }

*/
////////////////////////////////////////////////////////////////////

-(void)POST_SendAmount:(NSNumber*)amount withAddress:(NSString*)withdrawalAddress returnAddress:(NSString*)returnAddress completionBlock:(void (^)(NSDictionary *shiftInfo, NSError *error))completionBlock;

////////////////////////////////////////////////////////////////////
/*
    url: shapeshift.io/txStat/[address]
    method: GET
     
    [address] is the deposit address to look up.
     
    Success Output:  (various depending on status)
     
    Status: No Deposits Received
        {
                status:"no_deposits",
                address:[address]           //matches address submitted
            }
     
    Status: Received (we see a new deposit but have not finished processing it)
        {
                status:"received",
                address:[address]           //matches address submitted
            }
     
    Status: Complete
    {
            status : "complete",
            address: [address],
            withdraw: [withdrawal address],
            incomingCoin: [amount deposited],
            incomingType: [coin type of deposit],
            outgoingCoin: [amount sent to withdrawal address],
            outgoingType: [coin type of withdrawal],
            transaction: [transaction id of coin sent to withdrawal address]
    }
     
    Status: Failed
    {
            status : "failed",
            error: [Text describing failure]
    }
*/
////////////////////////////////////////////////////////////////////

-(void)GET_transactionStatusWithAddress:(NSString*)withdrawalAddress completionBlock:(void (^)(NSDictionary *transactionInfo, NSError *error))completionBlock;

@end
