//
//  PKAES.h
//  PKAES
//
//  Created by Philip Kluz on 10/24/15.
//  Copyright © 2015 nsexceptional.com. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>

#import "PKAES.h"

typedef NS_ENUM(NSUInteger, PKAESOperation) {
    PKAESOperationEncrypt,
    PKAESOperationDecrypt
};

@implementation PKAES

+ (NSData *)encryptData:(NSData *)data key:(NSData *)key initializationVector:(NSData *)iv
{
    NSData *encryptedData = [PKAES performOperation:PKAESOperationEncrypt
                                             onData:data
                                                key:key
                               initializationVector:iv];
    return encryptedData;
}

+ (NSData *)decryptData:(NSData *)data key:(NSData *)key initializationVector:(NSData *)iv
{
    NSData *decryptedData = [PKAES performOperation:PKAESOperationDecrypt
                                             onData:data
                                                key:key
                               initializationVector:iv];
    return decryptedData;
}

+ (void)encryptData:(NSData *)data
                key:(NSData *)key
initializationVector:(NSData *)iv
         completion:(PKAESCompletion)completion
{
    NSParameterAssert(completion);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *result = [PKAES performOperation:PKAESOperationEncrypt
                                        onData:data
                                           key:key
                          initializationVector:iv];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });
    });
}

+ (void)decryptData:(NSData *)data
                key:(NSData *)key
initializationVector:(NSData *)iv
         completion:(PKAESCompletion)completion
{
    NSParameterAssert(completion);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *result = [PKAES performOperation:PKAESOperationDecrypt
                                        onData:data
                                           key:key
                          initializationVector:iv];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });
    });
}

+ (NSData *)performOperation:(PKAESOperation)op onData:(NSData *)data key:(NSData *)key initializationVector:(NSData *)iv
{
    NSParameterAssert(data);
    NSParameterAssert(key);
    NSParameterAssert(iv);
    
    NSUInteger keySize = [key length];
    
    if ([data length] == 0) {
        NSLog(@"PKAES > No Data to %@.", (op == PKAESOperationEncrypt) ? @"Encrypt" : @"Decrypt");
        return nil;
    }
    
    if (keySize != PKAESKeySize128 && keySize != PKAESKeySize192 && keySize != PKAESKeySize256) {
        NSLog(@"PKAES > Key Size Incorrect.");
        return nil;
    }
    
    if ([iv length] != kCCBlockSizeAES128) {
        NSLog(@"PKAES > Initialization Vector Size Incorrect.");
        return nil;
    }
    
    CCCryptorRef cryptor = nil;
    
    CCCryptorStatus status = CCCryptorCreate((op == PKAESOperationEncrypt) ? kCCEncrypt : kCCDecrypt,
                                             kCCAlgorithmAES128,
                                             kCCOptionPKCS7Padding,
                                             [key bytes],
                                             [key length],
                                             [iv bytes],
                                             &cryptor);
    if (status != kCCSuccess) {
        NSLog(@"PKAES > Cryptor Creation Failed.");
        return nil;
    }
    
    NSUInteger outputLength = CCCryptorGetOutputLength(cryptor, [data length], true);
    NSMutableData *result = [NSMutableData dataWithCapacity:outputLength];
    NSMutableData *buffer = [NSMutableData dataWithLength:outputLength];
    
    size_t dataOutMovedUpdate;
    status = CCCryptorUpdate(cryptor,
                             [data bytes],
                             [data length],
                             [buffer mutableBytes],
                             [buffer length],
                             &dataOutMovedUpdate);
    
    if (status != kCCSuccess) {
        NSLog(@"PKAES > Failed to %@ Data.", (op == PKAESOperationEncrypt) ? @"Encrypt" : @"Decrypt");
        return nil;
    }
    
    NSData *encryptedData = [buffer subdataWithRange:NSMakeRange(0, dataOutMovedUpdate)];
    [result appendData:encryptedData];
    
    size_t dataOutMovedFinal;
    status = CCCryptorFinal(cryptor, [buffer mutableBytes], [buffer length], &dataOutMovedFinal);
    
    if (status != kCCSuccess) {
        NSLog(@"PKAES > Failed to Finish %@ (and Obtain Final Data Output).", (op == PKAESOperationEncrypt) ? @"Encryption" : @"Decryption");
        return nil;
    }
    
    NSData *finishData = [buffer subdataWithRange:NSMakeRange(0, dataOutMovedFinal)];
    [result appendData:finishData];
    
    CCCryptorRelease(cryptor);
    
    return [result copy];
}

+ (NSData *)randomInitializationVector
{
    return [self secureRandomDataWithLength:kCCBlockSizeAES128];
}

+ (NSData *)randomKeyWithSize:(PKAESKeySize)size
{
    return [self secureRandomDataWithLength:size];
}

+ (NSData *)secureRandomDataWithLength:(NSUInteger)randomByteCount
{
    NSMutableData *result = [NSMutableData dataWithLength:randomByteCount];
    int success = SecRandomCopyBytes(kSecRandomDefault, randomByteCount, [result mutableBytes]);
    
    if (success == -1) {
        return nil;
    }
    
    return [result copy];
}

@end
