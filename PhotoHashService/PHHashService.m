//
//  PHHashService.m
//  PhotoHashService
//
//  Created by naru on 2016/02/14.
//  Copyright © 2016年 naru. All rights reserved.
//

@import Photos;
#import "PHHashService.h"
#import "NSData+Hash.h"

static NSString * const StoredHashedObjectsKey = @"com.jpn.naru.hash_service.stored";

@interface PHHashedObject () <NSCoding>

@end

@implementation PHHashedObject

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.localIdentifier forKey:@"localIdentifier"];
    [aCoder encodeObject:self.hashString forKey:@"hashString"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _localIdentifier = [[aDecoder decodeObjectForKey:@"localIdentifier"] copy];
        _hashString = [[aDecoder decodeObjectForKey:@"hashString"] copy];
    }
    return self;
}

- (instancetype)initWithLocalIdentifier:(NSString * _Nonnull)localIdentifier hashString:(NSString * _Nonnull)hashString {
    if (self = [super init]) {
        _localIdentifier = [localIdentifier copy];
        _hashString = [hashString copy];
    }
    return self;
}

+ (instancetype)hashedObjectWithLocalIdentifier:(NSString * _Nonnull)localIdentifier hashString:(NSString * _Nonnull)hashString {
    PHHashedObject *hashedOject = [[PHHashedObject alloc] initWithLocalIdentifier:localIdentifier hashString:hashString];
    return hashedOject;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, localIdentifier: %@, hashString: %@>", self.class, &self, self.localIdentifier, self.hashString];
}

@end


#define PHHASHSERVICE_CANCEL_GUARD if (_cancelled) { \
    *stop = YES; \
    return; \
} \

@interface PHHashService ()

@property (nonatomic) NSMutableArray <PHHashedObject *> *hashedObjects;
@property (nonatomic) NSMutableSet <NSString *> *completedLocalIdentifiers;
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) NSLock *lock;

@end

@implementation PHHashService {
    __block BOOL _isHashing;
    __block BOOL _hasChanges;
    __block BOOL _cancelled;
}

+ (instancetype)sharedService {
    static dispatch_once_t token;
    static PHHashService *sharedService = nil;
    dispatch_once(&token, ^{
        sharedService = [PHHashService new];
    });
    return sharedService;
}

- (instancetype)init {
    if (self = [super init]) {
        self.queue = dispatch_queue_create("com.jpn.naru.hash_service", DISPATCH_QUEUE_SERIAL);
        self.lock = [NSLock new];
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:StoredHashedObjectsKey];
        if (data != nil) {
            // load stored data
            NSMutableArray *hashedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            self.hashedObjects = hashedObjects;
            self.completedLocalIdentifiers = [NSMutableSet set];
            for (PHHashedObject *hashedObject in self.hashedObjects) {
                [self.completedLocalIdentifiers addObject:hashedObject.localIdentifier];
            }
        } else {
            // create new data
            self.hashedObjects = [NSMutableArray array];
            self.completedLocalIdentifiers = [NSMutableSet set];
        }
    }
    return self;
}

#pragma mark - hash 

- (void)run {
    
    if (_isHashing) {
        NSLog(@"Hash service is already hashing...");
        return;
    }
    _isHashing = YES;
    _hasChanges = NO;
    _cancelled = NO;
    NSLog(@"Hash service starts to hash.");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
        PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
        NSInteger count = result.count;
        
        [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop){
            
            PHHASHSERVICE_CANCEL_GUARD;
            
            // return here if content is already hashed
            if ([self.completedLocalIdentifiers containsObject:asset.localIdentifier]) {
                // finish
                if (idx+1 == count) {
                    [self completeHash];
                }
                return;
            }
            
            dispatch_async(self.queue, ^{
                
                PHImageRequestOptions *options = [PHImageRequestOptions new];
                options.synchronous = YES;
                options.networkAccessAllowed = YES;
                options.version = PHImageRequestOptionsVersionCurrent;
                options.resizeMode = PHImageRequestOptionsResizeModeNone;
                
                @autoreleasepool {
                    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info){
                        
                        PHHASHSERVICE_CANCEL_GUARD;
                        
                        if (imageData != nil) {
                        
                            NSString *identifier = asset.localIdentifier;
                            NSString *md5Hash = imageData.MD5Hash;
                            PHHashedObject *hashedObject = [PHHashedObject hashedObjectWithLocalIdentifier:identifier hashString:md5Hash];
                            
                            PHHASHSERVICE_CANCEL_GUARD;
                            
                            // add hashed object
                            [self.lock lock];
                            [self.hashedObjects addObject:hashedObject];
                            [self.completedLocalIdentifiers addObject:identifier];
                            _hasChanges = YES;
                            [self.lock unlock];
                        }
                        
                        NSLog(@"%ld / %ld", idx+1, count);
                    }];
                }
                
                // finish
                if (idx+1 == count) {
                    [self completeHash];
                }
            });
        }];
    });
}

- (void)completeHash {
    NSLog(@"Hash service completes to hash.");
    [self store];
    _isHashing = NO;
}

- (void)store {
    if (_hasChanges) {
        // store result
        [self.lock lock];
        NSData *object = [NSKeyedArchiver archivedDataWithRootObject:self.hashedObjects];
        [[NSUserDefaults standardUserDefaults] setObject:object forKey:StoredHashedObjectsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _hasChanges = NO;
        [self.lock unlock];
        NSLog(@"Hash service stored results.");
    } else {
        // no changes to store
        NSLog(@"Hash service has no changes to store.");
    }
}

- (void)clear {
    
    _cancelled = YES;
    
    self.hashedObjects = [NSMutableArray array];
    self.completedLocalIdentifiers = [NSMutableSet set];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:StoredHashedObjectsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (_isHashing) {
        NSLog(@"Hash service cancelled procedure and cleared all stored data.");
    } else {
        NSLog(@"Hash service cleared all stored data.");
    }
    _isHashing = NO;
}

#pragma mark - return hashed obejcts

- (NSArray *)allHashedObjects {
    NSArray *allHashedObjects = nil;
    [self.lock lock];
    allHashedObjects = [NSArray arrayWithArray:self.hashedObjects];
    [self.lock unlock];
    return allHashedObjects;
}

#pragma mark - return local identifiers

- (NSArray <NSString *> *)localIdentifiersForHashStrings:(NSArray *)hashStrings {
    
    // Use NSSet instead of NSArray. 'containsObject' of NSSet if faster than that of NSArray.
    NSSet *excludedHashSet = [NSSet setWithArray:hashStrings];
    NSMutableArray *localIdentifiers = [NSMutableArray array];
    
    [self.lock lock];
    for (PHHashedObject *hashedObject in self.hashedObjects) {
        if ([excludedHashSet containsObject:hashedObject.hashString]) {
            [localIdentifiers addObject:hashedObject.localIdentifier];
        }
    }
    [self.lock unlock];
    
    return localIdentifiers;
}

@end
