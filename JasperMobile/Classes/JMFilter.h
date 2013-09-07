/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */

//
//  JMFilter.h
//  Jaspersoft Corporation
//

#import <Foundation/Foundation.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.6
 */
@interface JMFilter : NSObject <JSRequestDelegate, UIAlertViewDelegate>

/**
 Sets view controller that will be dismissed if any request with JMFilter as delegate will fail

 @param viewController A view controller that will be dismissed
 */
+ (void)setViewControllerToDismiss:(UIViewController *)viewController;

/**
 Passes a request result to final delegate object if request was successful. Otherwise displays
 alert view dialog with error message
 
 @param delegate A delegate object
 @param viewController A view controller that will be dismissed if any request with JMFilter as delegate will fail
 */
+ (JMFilter *)checkRequestResultForDelegate:(id <JSRequestDelegate>)delegate viewControllerToDismiss:(UIViewController *)viewController;

/**
 Displays alert view dialog with provided status code or error code

 @param statusCode The response HTTP code
 @param errorCode The receiver’s error code.
 */
+ (void)showAlertViewDialogForStatusCode:(NSInteger)statusCode orErrorCode:(NSInteger)errorCode;


@end
