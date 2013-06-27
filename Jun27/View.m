//
//  View.m
//  Jun27
//
//  Created by david morton on 6/21/13.
//  Copyright (c) 2013 David Morton Enterprises. All rights reserved.
//

#import <CoreLocation/CLLocation.h>	//for CLLocationCoordinate2D
#import "View.h"

@implementation View

- (id) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];
    if (self) {
        // Initialization code
		_counter=0;
		_directionIsUp=YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void) drawRect: (CGRect) rect
{
	NSError *error = nil;
	NSString* path = [[NSBundle mainBundle] pathForResource:@"mexico"
													 ofType:@"coords"];
	NSString* content = [NSString stringWithContentsOfFile:path
												  encoding:NSUTF8StringEncoding
													 error:&error];	
	if(error) NSLog(@"ERROR while loading from file: %@", error);
	
	NSArray *b =
	[content componentsSeparatedByCharactersInSet:
	 [NSCharacterSet newlineCharacterSet]];
		
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	  
	UIImage *image = [UIImage imageNamed: @"mexico-flag.gif"];	
	if (image == nil) {
		NSLog(@"could not find the image");
	}else{
		CGPoint point = CGPointMake(0,0);
		[image drawAtPoint: point];
	}
	
	CGContextSetShadow(c, CGSizeMake(6+_counter, -10+_counter), 4);
	
	CGSize s = self.bounds.size;
	CGContextTranslateCTM(c, s.width / 2, s.height / 2);
	
	//Location of Mexico City 19.1300° N, 99.4000° W
	 CGFloat xtranslate = 102.40;
	 CGFloat ytranslate = -20.965;
 
	
	CGFloat scale = 10;	//pixels per degree of latitude
    
	CGContextScaleCTM(c, scale * cos(ytranslate * M_PI / 180), -scale);
	CGContextTranslateCTM(c, xtranslate, ytranslate);
    
	
	CGContextBeginPath(c);
	for (NSUInteger j = 0; j < [b count]; ++j) {
		NSArray* foo = [b[j] componentsSeparatedByString: @","];
				
		if(j==0) CGContextMoveToPoint(c, [foo[1] floatValue], [foo[0] floatValue] );
		else CGContextAddLineToPoint(c, [foo[1] floatValue], [foo[0] floatValue]);
	}
	
	CGContextClosePath(c);
	CGContextSetRGBFillColor(c, 1.0, 0.0, 0.0, 1.0);	//opaque red
	CGContextFillPath(c);
	
	[self performSelector: @selector(setNeedsDisplay) withObject: nil afterDelay: .05];
	
	if(_directionIsUp){
		if(_counter==10){
			_directionIsUp=NO;
			_counter--;
		}else{
			_counter++;
		}
	}else{
		if(_counter==0){
			_directionIsUp=YES;
			_counter++;
		}else{
			_counter--;
		}

	}
	
}
/*
 //was starting to play with found image resizing code
- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
		
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
	
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
	
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
	
    CGContextRef bitmap;
	
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
		
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
		
    }
	
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
		
        CGContextRotateCTM (bitmap, M_PI_2); // + 90 degrees
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
		
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
		
        CGContextRotateCTM (bitmap, -M_PI_2); // - 90 degrees
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
		
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, -M_PI); // - 180 degrees
    }
	
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
	
    CGContextRelease(bitmap);
    CGImageRelease(ref);
	
    return newImage; 
}
*/
@end