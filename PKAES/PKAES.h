//
//  PKAES.h
//  PKAES
//
//  Created by Philip Kluz on 10/24/15.
//  Copyright © 2015 nsexceptional.com. All rights reserved.
//

@import UIKit;
@import Security;

NS_ASSUME_NONNULL_BEGIN

/// AES Key Size in Bytes.
typedef NS_ENUM(NSUInteger, PKAESKeySize) {
    PKAESKeySize128 = 16,
    PKAESKeySize192 = 24,
    PKAESKeySize256 = 32
};

typedef void(^PKAESCompletion)(NSData *result);

@interface PKAES : NSObject

+ (NSData *)encryptData:(NSData *)data key:(NSData *)key initializationVector:(NSData *)iv;
+ (NSData *)decryptData:(NSData *)data key:(NSData *)key initializationVector:(NSData *)iv;

+ (void)encryptData:(NSData *)data key:(NSData *)key initializationVector:(NSData *)iv completion:(PKAESCompletion)completion;
+ (void)decryptData:(NSData *)data key:(NSData *)key initializationVector:(NSData *)iv completion:(PKAESCompletion)completion;

+ (NSData *)randomKeyWithSize:(PKAESKeySize)size;
+ (NSData *)randomInitializationVector;
+ (NSData *)secureRandomDataWithLength:(NSUInteger)randomByteCount;

@end

NS_ASSUME_NONNULL_END
