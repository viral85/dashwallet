//
//  DCDarksendQueue.h
//  BreadWallet
//
//  Created by  Quantum Exploreron 4/27/15.
//  Copyright (c) 2015 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDarksendQueue : NSObject


CTxIn vin;
int64_t time;
int nDenom;
bool ready; //ready for submit
std::vector<unsigned char> vchSig;

CDarksendQueue()
{
    nDenom = 0;
    vin = CTxIn();
    time = 0;
    vchSig.clear();
    ready = false;
}

IMPLEMENT_SERIALIZE
(
 READWRITE(nDenom);
 READWRITE(vin);
 READWRITE(time);
 READWRITE(ready);
 READWRITE(vchSig);
 )

bool GetAddress(CService &addr)
{
    CMasternode* pmn = mnodeman.Find(vin);
    if(pmn != NULL)
    {
        addr = pmn->addr;
        return true;
    }
    return false;
}

/// Get the protocol version
bool GetProtocolVersion(int &protocolVersion)
{
    CMasternode* pmn = mnodeman.Find(vin);
    if(pmn != NULL)
    {
        protocolVersion = pmn->protocolVersion;
        return true;
    }
    return false;
}

/** Sign this Darksend transaction
 *  \return true if all conditions are met:
 *     1) we have an active Masternode,
 *     2) we have a valid Masternode private key,
 *     3) we signed the message successfully, and
 *     4) we verified the message successfully
 */
bool Sign();

bool Relay();

/// Is this Darksend expired?
bool IsExpired()
{
    return (GetTime() - time) > DARKSEND_QUEUE_TIMEOUT;// 120 seconds
}

/// Check if we have a valid Masternode address
bool CheckSignature();

};

@end
