//
//  DashWalletTests.m
//  DashWalletTests
//
//  Created by Aaron Voisine on 5/8/13.
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

#import "DashWalletTests.h"
#import "BRWalletManager.h"
#import "BRBIP32Sequence.h"
#import "BRBIP39Mnemonic.h"
#import "BRTransaction.h"
#import "BRKey.h"
#import "BRKey+BIP38.h"
#import "BRBloomFilter.h"
#import "BRMerkleBlock.h"
#import "BRPaymentRequest.h"
#import "BRPaymentProtocol.h"
#import "NSData+Dash.h"
#import "NSMutableData+Bitcoin.h"
#import "NSString+Dash.h"
#import "NSData+Blake.h"
#import "NSData+Bmw.h"
#import "NSData+CubeHash.h"
#import "NSData+Echo.h"
#import "NSData+Keccak.h"

#define SKIP_BIP38 1

@implementation DashWalletTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - X11

-(void)testBlake
{
    NSString * fox = @"The quick brown fox jumps over the lazy dog";
    NSData * foxData = [fox dataUsingEncoding:NSASCIIStringEncoding];
    NSData * blaked = [foxData blake512];
    NSString * blakedString = [blaked hexadecimalString];
    XCTAssertEqualObjects([blakedString uppercaseString], @"1F7E26F63B6AD25A0896FD978FD050A1766391D2FD0471A77AFB975E5034B7AD2D9CCF8DFB47ABBBE656E1B82FBC634BA42CE186E8DC5E1CE09A885D41F43451",@"[NSData blake512]"); //verified by wikipedia
}

-(void)testCubehash
{
    NSString * hello = @"Hello";
    NSData * helloData = [hello dataUsingEncoding:NSASCIIStringEncoding];
    NSData * cubeHashed = [helloData cubehash512];
    NSString * cubeHashedString = [cubeHashed hexadecimalString];
    XCTAssertEqualObjects(cubeHashedString,@"dcc0503aae279a3c8c95fa1181d37c418783204e2e3048a081392fd61bace883a1f7c4c96b16b4060c42104f1ce45a622f1a9abaeb994beb107fed53a78f588c",@"[NSData cubehash512]");
    
}

-(void)testKeccak
{
    NSString * string = @"";
    NSData * stringData = [string dataUsingEncoding:NSASCIIStringEncoding];
    NSData * hashed = [stringData keccak512];
    NSString * hashedString = [hashed hexadecimalString];
    XCTAssertEqualObjects(hashedString,@"0eab42de4c3ceb9235fc91acffe746b29c29a8c366b7c60e4e67c466f36a4304c00fa9caf9d87976ba469bcbe06713b435f091ef2769fb160cdab33d3670680e",@"[NSData keccak512]");
    
}

-(void)testX11
{
    NSString * x11 = @"020000002cc0081be5039a54b686d24d5d8747ee9770d9973ec1ace02e5c0500000000008d7139724b11c52995db4370284c998b9114154b120ad3486f1a360a1d4253d310d40e55b8f70a1be8e32300";
    NSData * x11Data = [NSData dataFromHexString:x11];
    NSData * x11ed = [x11Data x11];
    NSString * x11edString = [x11ed hexadecimalString];
    XCTAssertEqualObjects(x11edString,@"f29c0f286fd8071669286c6987eb941181134ff5f3978bf89f34070000000000",@"[NSData x11]");//not verified
}

#pragma mark - testBase58

- (void)testBase58
{
    // test bad input
    NSString *s = [NSString base58WithData:[BTC @"#&$@*^(*#!^" base58ToData]];

    XCTAssertTrue(s.length == 0, @"[NSString base58WithData:]");
    
    s = [NSString base58WithData:[@"" base58ToData]];
    XCTAssertEqualObjects(@"", s, @"[NSString base58WithData:]");

    s = [NSString base58WithData:[@"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz" base58ToData]];
    XCTAssertEqualObjects(@"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz", s,
                          @"[NSString base58WithData:]");

    s = [NSString base58WithData:[@"1111111111111111111111111111111111111111111111111111111111111111111" base58ToData]];
    XCTAssertEqualObjects(@"1111111111111111111111111111111111111111111111111111111111111111111", s,
                          @"[NSString base58WithData:]");
    
    s = [NSString base58WithData:[@"111111111111111111111111111111111111111111111111111111111111111111z" base58ToData]];
    XCTAssertEqualObjects(@"111111111111111111111111111111111111111111111111111111111111111111z", s,
                          @"[NSString base58WithData:]");

    s = [NSString base58WithData:[@"z" base58ToData]];
    XCTAssertEqualObjects(@"z", s, @"[NSString base58WithData:]");
    
    s = [NSString base58checkWithData:nil];
    XCTAssertTrue(s == nil, @"[NSString base58checkWithData:]");

    s = [NSString base58checkWithData:@"".hexToData];
    XCTAssertEqualObjects([NSData data], [s base58checkToData], @"[NSString base58checkWithData:]");

    s = [NSString base58checkWithData:@"000000000000000000000000000000000000000000".hexToData];
    XCTAssertEqualObjects(@"000000000000000000000000000000000000000000".hexToData, [s base58checkToData],
                          @"[NSString base58checkWithData:]");

    s = [NSString base58checkWithData:@"000000000000000000000000000000000000000001".hexToData];
    XCTAssertEqualObjects(@"000000000000000000000000000000000000000001".hexToData, [s base58checkToData],
                          @"[NSString base58checkWithData:]");

    s = [NSString base58checkWithData:@"05FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF".hexToData];
    XCTAssertEqualObjects(@"05FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF".hexToData, [s base58checkToData],
                          @"[NSString base58checkWithData:]");
}

#pragma mark - testRMD160

- (void)testRMD160
{
    NSData *d = [@"Free online RIPEMD160 Calculator, type text here..." dataUsingEncoding:NSUTF8StringEncoding].RMD160;
    
    XCTAssertEqualObjects(@"9501a56fb829132b8748f0ccc491f0ecbc7f945b".hexToData, d, @"[NSData RMD160]");
    
    d = [@"this is some text to test the ripemd160 implementation with more than 64bytes of data since it's internal "
         "digest buffer is 64bytes in size" dataUsingEncoding:NSUTF8StringEncoding].RMD160;
    XCTAssertEqualObjects(@"4402eff42157106a5d92e4d946185856fbc50e09".hexToData, d, @"[NSData RMD160]");

    d = [@"123456789012345678901234567890123456789012345678901234567890"
         dataUsingEncoding:NSUTF8StringEncoding].RMD160;
    XCTAssertEqualObjects(@"00263b999714e756fa5d02814b842a2634dd31ac".hexToData, d, @"[NSData RMD160]");

    d = [@"1234567890123456789012345678901234567890123456789012345678901234"
         dataUsingEncoding:NSUTF8StringEncoding].RMD160; // a message exactly 64bytes long (internal buffer size)
    XCTAssertEqualObjects(@"fa8c1a78eb763bb97d5ea14ce9303d1ce2f33454".hexToData, d, @"[NSData RMD160]");

    d = [NSData data].RMD160; // empty
    XCTAssertEqualObjects(@"9c1185a5c5e9fc54612808977ee8f548b2258d31".hexToData, d, @"[NSData RMD160]");
    
    d = [@"a" dataUsingEncoding:NSUTF8StringEncoding].RMD160;
    XCTAssertEqualObjects(@"0bdc9d2d256b3ee9daae347be6f4dc835a467ffe".hexToData, d, @"[NSData RMD160]");
}

@end
