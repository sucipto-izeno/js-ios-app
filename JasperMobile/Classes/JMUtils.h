//
//  JMViewControllerHelper.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/7/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMResourceClientHolder.h"

@interface JMUtils : NSObject

/**
 Injects all required dependencies into navigation view controller that implements 
 JMResourceClientHolder protocol. Also sets title equals to resource's name or 
 profile's alias if resource is <b>nil</b>
 
 @param viewController A viewController to configure
 */
+ (void)awakeFromNibForResourceViewController:(UIViewController <JMResourceClientHolder>*)viewController;

/**
 Sets background images to the button.
 
 @param button The button for which background images will be set
 @param imageName A name of the image for button's normal state (can be "nil")
 @param highlightedImageName A name of the image for button's highlighted state (can be "nil")
 @param edgesInset An inset for all edges
 */
+ (void)setBackgroundImagesForButton:(UIButton *)button imageName:(NSString *)imageName highlightedImageName:(NSString *)highlightedImageName edgesInset:(CGFloat)edgesInset;

@end