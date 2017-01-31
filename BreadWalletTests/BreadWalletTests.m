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

#import "BreadWalletTests.h"
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
#import "NSData+Groestl.h"
#import "NSData+Jh.h"
#import "NSData+Keccak.h"
#import "NSData+Luffa.h"
#import "NSData+Shavite.h"
#import "NSData+Simd.h"
#import "NSData+Skein.h"

#define SKIP_BIP38 1
#define SAMPLE_SIZE 10000

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

//-(void)testBlakea
//{
//    NSString * fox = @"";
//    NSData * foxData = [fox dataUsingEncoding:NSASCIIStringEncoding];
//    NSData * blaked = [foxData blake512];
//    NSString * blakedString = [blaked hexadecimalString];
//    XCTAssertEqualObjects([blakedString lowercaseString], @"780fca7981665e2dc073ad3e64699401a8503d62a18742ad5de7c42bf2cf269a1805df497d4e8b148d91a04a6128986ce4e4d29fb97952446868b2f5d915d9e5",@"[NSData blake512]"); //verified by wikipedia
//}

-(void)testBlake
{
    NSString * fox = @"The quick brown fox jumps over the lazy dog";
    NSData * foxData = [fox dataUsingEncoding:NSASCIIStringEncoding];
    [self measureBlock:^{
        NSData * blaked = [foxData blake512];
        
        NSString * blakedString = [blaked hexadecimalString];
        XCTAssertEqualObjects([blakedString lowercaseString], @"1f7e26f63b6ad25a0896fd978fd050a1766391d2fd0471a77afb975e5034b7ad2d9ccf8dfb47abbbe656e1b82fbc634ba42ce186e8dc5e1ce09a885d41f43451",@"[NSData blake512]"); //verified by wikipedia
    }];
}

-(void)testBmw
{
    NSString * fox = @"The quick brown fox jumps over the lazy dog";
    NSData * foxData = [fox dataUsingEncoding:NSASCIIStringEncoding];
    [self measureBlock:^{
        NSData * bmwed = [foxData bmw512];
        NSString * bmwedString = [bmwed hexadecimalString];
        XCTAssertEqualObjects([bmwedString lowercaseString], @"2998d4cb31323e1169b458ab03a54d0b68e411a3c7cc7612adbf05bf901b8197dfd852c1c0099c09717d2fad3537207e737c6159c31d377d1ab8f5ed1ceeea06",@"[NSData blake512]"); //verified by wikipedia
    }];
}

-(void)testCubehash
{
    NSString * cubehash = @"The quick brown fox jumps over the lazy dog";
    NSData * cubehashData = [cubehash dataUsingEncoding:NSASCIIStringEncoding];
    [self measureBlock:^{
        NSData * cubeHashed = [cubehashData cubehash512];
        NSString * cubeHashedString = [cubeHashed hexadecimalString];
        XCTAssertEqualObjects(cubeHashedString,@"bdba44a28cd16b774bdf3c9511def1a2baf39d4ef98b92c27cf5e37beb8990b7cdb6575dae1a548330780810618b8a5c351c1368904db7ebdf8857d596083a86",@"[NSData cubehash512]");
    }];
    
}

-(void)testEcho
{
    NSString * echo = @"The quick brown fox jumps over the lazy dog";
    NSData * echoData = [echo dataUsingEncoding:NSASCIIStringEncoding];
    [self measureBlock:^{
        NSData * echoed = [echoData echo512];
        NSString * echoedString = [echoed hexadecimalString];
        XCTAssertEqualObjects(echoedString,@"fe61eba97bdfcaa027ded44a5f883fcb900b97449596d7b4a7187c76e71ad750e6117b529bd69992bec015bef862d16d62c384b600cb300d486e565f94202abf",@"[NSData cubehash512]");
    }];
    
}

-(void)testGroestl
{
    NSString * groestl = @"The quick brown fox jumps over the lazy dog";
    NSData * groestlData = [groestl dataUsingEncoding:NSASCIIStringEncoding];
    [self measureBlock:^{
        NSData * groestled = [groestlData groestl512];
        for (int i = 0;i<SAMPLE_SIZE;i++) {
            groestled = [groestled groestl512];
        }
        NSString * groestledString = [groestled hexadecimalString];
        XCTAssertEqualObjects(groestledString,@"d8d025e497122a0070dc58e8eab8fd9ec70bc67139d75283e46765f6c3c693bc715953ce1da0352c0da170830c3171ec26f6b35b51062d1308b5da1878855080",@"[NSData groestl512]");
        
        //XCTAssertEqualObjects(groestledString,@"badc1f70ccd69e0cf3760c3f93884289da84ec13c70b3d12a53a7a8a4a513f99715d46288f55e1dbf926e6d084a0538e4eebfc91cf2b21452921ccde9131718d",@"[NSData groestl512]");
    }];
    
}

-(void)testJh
{
    NSString * jh = @"The quick brown fox jumps over the lazy dog";
    NSData * jhData = [jh dataUsingEncoding:NSASCIIStringEncoding];
    [self measureBlock:^{
        NSData * jhed = [jhData jh512];
        NSString * jhedString = [jhed hexadecimalString];
        XCTAssertEqualObjects(jhedString,@"043f14e7c0775e7b1ef5ad657b1e858250b21e2e61fd699783f8634cb86f3ff938451cabd0c8cdae91d4f659d3f9f6f654f1bfedca117ffba735c15fedda47a3",@"[NSData cubehash512]");
    }];
    
}

-(void)testKeccak
{
    NSString * string = @"The quick brown fox jumps over the lazy dog";
    NSData * stringData = [string dataUsingEncoding:NSASCIIStringEncoding];
    [self measureBlock:^{
        NSData * hashed = [stringData keccak512];
        for (int i = 0;i<SAMPLE_SIZE;i++) {
            hashed = [hashed groestl512];
        }
        NSString * hashedString = [hashed hexadecimalString];
        
        XCTAssertEqualObjects(hashedString,@"1c658b465c0c0bd53401a45504622e7d7922f63f696200dcab32f600963bf31c5fc27d97d9cb05904bdecc0e83515c450abe19051433886e901d360354162043",@"[NSData keccak512]");
        //XCTAssertEqualObjects(hashedString,@"d135bb84d0439dbac432247ee573a23ea7d3c9deb2a968eb31d47c4fb45f1ef4422d6c531b5b9bd6f449ebcc449ea94d0a8f05f62130fda612da53c79659f609",@"[NSData keccak512]");
    }];
    
}

-(void)testLuffa
{
    NSString * luffa = @"The quick brown fox jumps over the lazy dog";
    NSData * luffaData = [luffa dataUsingEncoding:NSASCIIStringEncoding];
    [self measureBlock:^{
        NSData * luffaed = [luffaData luffa512];
        NSString * luffaString = [luffaed hexadecimalString];
        XCTAssertEqualObjects(luffaString,@"459e2280a7cdb0c721d8d9dbeb9ed339659dc9e7b158e9dd2d328d946cb21474dc9177edfc93602f1aadb31944c795c9b5df859a3dc6132d4f0a4c476aaf797f",@"[NSData cubehash512]");
    }];
    
}

-(void)testShavite
{
    NSString * shavite = @"The quick brown fox jumps over the lazy dog";
    NSData * shaviteData = [shavite dataUsingEncoding:NSASCIIStringEncoding];
    [self measureBlock:^{
        NSData * shavited = [shaviteData shavite512];
        NSString * shaviteString = [shavited hexadecimalString];
        XCTAssertEqualObjects(shaviteString,@"4dbd97835c4e5cfa14799884a7adc96688dd808ff53d5c4cfe7db89a55ee98d0260791ec0c9b5466482ab3f6f236da7e65e1cb6d1ee624f61a5b2b79f63c4120",@"[NSData cubehash512]");
    }];
    
}

-(void)testSimd
{
    NSString * simd = @"The quick brown fox jumps over the lazy dog";
    NSData * simdData = [simd dataUsingEncoding:NSASCIIStringEncoding];
    [self measureBlock:^{
        NSData * simded = [simdData simd512];
        NSString * simdString = [simded hexadecimalString];
        XCTAssertEqualObjects(simdString,@"ca493ce78cc2a63b5a48393e61d113d59a930b3e76d062ab58177345c48b59890a08661d04dd6160a1b42d215f1e303d97ab0abb54e65f758f79aee2b182b34b",@"[NSData cubehash512]");
    }];
    
}

-(void)testSkein
{
    NSString * fox = @"The quick brown fox jumps over the lazy dog";
    NSData * foxData = [fox dataUsingEncoding:NSASCIIStringEncoding];
    [self measureBlock:^{
        NSData * skeined = [foxData skein512];
        NSString * skeinedString = [skeined hexadecimalString];
        XCTAssertEqualObjects([skeinedString lowercaseString], @"94c2ae036dba8783d0b3f7d6cc111ff810702f5c77707999be7e1c9486ff238a7044de734293147359b4ac7e1d09cd247c351d69826b78dcddd951f0ef912713",@"[NSData skein512]");
    }];
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
