//
//  BRConstant.h
//  DashWallet
//
//  Created by Viral on 17/11/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#ifndef BRConstant_h
#define BRConstant_h



/*----- Webservice Methods -----*/
#define kAFClient [AFAPIClient sharedClient]


/*----- Webservice Method Name -----*/
//TEST
//#define MAIN_URL @"http://woc.reference.genitrust.com/api/"
//LIVE
#define MAIN_URL @"https://wallofcoins.com/api/"


#define DiscoveryInputs MAIN_URL@"v1/discoveryInputs/"
#define GetOffers MAIN_URL@"v1/discoveryInputs/"
#define CreateHold MAIN_URL@"v1/holds/"
#define GetOrderList MAIN_URL@"v1/orders/"

#define GetAdsList MAIN_URL@"v1/ad"
#define GetCurrency MAIN_URL@"v1/currency/"
#define GetBankList MAIN_URL@"v1/banks"


#define SomthingErrorMsg @"Something went wrong"
#define Not_CorrectFormate @"Sorry, response is not in readable formate"

#endif /* BRConstant_h */
