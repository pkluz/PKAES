//
//  PKAESTests.m
//  PKAESTests
//
//  Created by Philip Kluz on 10/26/15.
//  Copyright © 2015 nsexceptional.com. All rights reserved.
//

@import XCTest;
@import PKAES;

@interface PKAESTests : XCTestCase

@property (nonatomic, copy, readwrite) NSData *keyData;
@property (nonatomic, copy, readwrite) NSData *IVData;

@end

@implementation PKAESTests

- (void)setUp
{
    NSString *IVString = @"xekkRlu0UyuMe/QdpbCfcg==";
    NSString *keyString = @"4gxpR94i/Fwkl4o1xqF9z4vYigjWVpfMs6I4lj/I3Z8=";
    
    self.keyData = [[NSData alloc] initWithBase64EncodedString:keyString options:0];
    self.IVData = [[NSData alloc] initWithBase64EncodedString:IVString options:0];
}

- (void)testKeyGeneration
{
    NSData *keyData128 = [PKAES randomKeyWithSize:PKAESKeySize128];
    XCTAssert([keyData128 length] == PKAESKeySize128);
    
    NSData *keyData192 = [PKAES randomKeyWithSize:PKAESKeySize192];
    XCTAssert([keyData192 length] == PKAESKeySize192);
    
    NSData *keyData256 = [PKAES randomKeyWithSize:PKAESKeySize256];
    XCTAssert([keyData256 length] == PKAESKeySize256);
}

- (void)testIVGeneration
{
    NSData *iv = [PKAES randomInitializationVector];
    XCTAssert([iv length] == 16);
}

- (void)testEncryptionSync
{
    NSString *rawString = @"Hello World! - This Is A Plain Text String. And it has a lot of very interesting information that is supposed to be secure.";
    NSData *rawData = [rawString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *encryptedData = [PKAES encryptData:rawData
                                           key:self.keyData
                          initializationVector:self.IVData];
    
    NSString *expectedDataAsBase64 = @"TTWH61QsAeB1tyENVMV0urDhOnJ14VCX0r6yg8XVeN24AD9dQLGNqVKlsHj3+Hua08lhnXRIWup13cL3twzyd0HayMfUyQgJTXI+OQVg0jccUD3/uvln4pN65vrpillDRnh7q3dowXMB1aB82dnjea3vrGtrClChJGloVa4GpuE=";
    NSData *expectedData = [[NSData alloc] initWithBase64EncodedString:expectedDataAsBase64 options:0];
    
    XCTAssert([encryptedData isEqualToData:expectedData]);
}

- (void)testDecryptionSync
{
    NSString *originalString = @"Hello World! - This Is A Plain Text String. And it has a lot of very interesting information that is supposed to be secure.";
    
    NSString *encryptedDataAsBase64 = @"TTWH61QsAeB1tyENVMV0urDhOnJ14VCX0r6yg8XVeN24AD9dQLGNqVKlsHj3+Hua08lhnXRIWup13cL3twzyd0HayMfUyQgJTXI+OQVg0jccUD3/uvln4pN65vrpillDRnh7q3dowXMB1aB82dnjea3vrGtrClChJGloVa4GpuE=";
    NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:encryptedDataAsBase64 options:0];
    
    NSData *decryptedData = [PKAES decryptData:encryptedData
                                           key:self.keyData
                          initializationVector:self.IVData];
    
    NSString *decryptedString = [[NSString alloc] initWithData:decryptedData
                                                      encoding:NSUTF8StringEncoding];
    
    XCTAssert([decryptedString isEqualToString:originalString]);
}

@end
