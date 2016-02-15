//
//  PHHashService.h
//  PhotoHashService
//
//  Created by naru on 2016/02/14.
//  Copyright © 2016年 naru. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - PHHashedObject

@interface PHHashedObject : NSObject

@property (nonatomic, copy) NSString *localIdentifier;

@property (nonatomic, copy) NSString *hashString;

@end


/**
 Calculate hash for image data and store them.
 */
#pragma mark - PHHashService

/**
 Get hash string and store them for all local image data.
 */
@interface PHHashService : NSObject

/**
 Return shared instance.
 */
+ (instancetype)sharedService;

/**
 Calculate hash string for all local image data on background thread.
 Results are automatically stored on user defaults when calculation finished.
 */
- (void)run;

/**
 Store current data if changes to store exists.
 Recommend to call this method at applicationWillTerminate:.
 */
- (void)store;

/**
 Clear all stored data and cancel current procedure.
 */
- (void)clear;

/**
 Return all hashed objects.
 */
- (NSArray <PHHashedObject *> *)allHashedObjects;

/**
 Return all local identifiers having any given hash strings.
 */
- (NSArray <NSString *> *)localIdentifiersForHashStrings:(NSArray <NSString *> *)hashStrings;

@end
