//
//  NSData+Hash.m
//  PhotoHashService
//
//  Created by naru on 2016/02/14.
//  Copyright © 2016年 naru. All rights reserved.
//

#import "NSData+Hash.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (Hash)

- (NSString *)MD5Hash {
    if (self.length == 0) {
        return nil;
    }
    CC_LONG len = (CC_LONG)self.length;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, len, result);
    NSMutableString *ms = @"".mutableCopy;
    for (int i = 0; i < 16; i++) {
        [ms appendFormat:@"%02X",result[i]];
    }
    return ms;
}

@end
