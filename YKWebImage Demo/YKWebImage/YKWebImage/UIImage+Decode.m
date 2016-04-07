//
//  UIImage+Decode.m
//  YKWebImage
//
//  Created by lijian on 16/4/6.
//  Copyright © 2016年 youku. All rights reserved.
//

#import "UIImage+Decode.h"

@implementation UIImage (Decode)

+ (UIImage *)decodeImageWithImage:(UIImage *)image {
    @autoreleasepool {
        if (!image) return nil;

        CGImageRef imageRef = image.CGImage;
        
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
        BOOL alpha = alphaInfo == kCGImageAlphaPremultipliedLast ||
                     alphaInfo == kCGImageAlphaPremultipliedFirst ||
                     alphaInfo == kCGImageAlphaLast ||
                     alphaInfo == kCGImageAlphaFirst ||
                     alphaInfo == kCGImageAlphaOnly;
        
        if (alpha) return image;
        
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        
        CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef contentRef = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), 0, spaceRef, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
        
        CGColorSpaceRelease(spaceRef);
        
        UIImage *decodeImage = nil;
        
        if (contentRef) {
            CGContextDrawImage(contentRef, (CGRect){0, 0, width, height}, imageRef);
            CGImageRef newImageRef = CGBitmapContextCreateImage(contentRef);
            
            if (newImageRef) {
                decodeImage =  [UIImage imageWithCGImage:newImageRef scale:1.0 orientation:image.imageOrientation];
            }
            
            CGContextRelease(contentRef);
            CGImageRelease(newImageRef);
        }
        
        return decodeImage;
    }
}

@end
