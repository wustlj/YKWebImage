//
//  YKImageCache.h
//  YKWebImage
//
//  Created by lijian on 16/2/22.
//  Copyright © 2016年 youku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YKImageCache : NSObject

/**
 *  是否混存到内存中，默认YES
 **/
@property(nonatomic, assign) BOOL shouldCacheInMemory;

+ (YKImageCache *)shareInstance;

- (void)storeImage:(UIImage *)image forKey:(NSString *)key;

- (void)removeImageForKey:(NSString *)key;

- (UIImage *)imageFromCacheForKey:(NSString *)key;

/**
 * 清除所有缓存(内存+文件)
 **/
- (void)cleanCache;

@end
