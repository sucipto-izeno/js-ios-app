/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
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
//  JSDateInputControlCell.m
//  Jaspersoft Corporation
//

#import "JSDateInputControlCell.h"
#import "JSDateTimeSelectorViewController.h"

#define JS_LBL_TEXT_WIDTH 160.0f

@implementation JSDateInputControlCell

@synthesize dateFormat = _dateFormat;

- (id)initWithResourceDescriptor:(JSResourceDescriptor *)rd tableViewController: (UITableViewController *)tv {
	if (self = [super initWithResourceDescriptor: rd tableViewController: tv]) {
		if (!self.readonly) self.selectionStyle = UITableViewCellSelectionStyleBlue;
		label = [[UILabel alloc] initWithFrame:CGRectMake(JS_CELL_PADDING + JS_CONTENT_PADDING + JS_LBL_WIDTH, 10.0, 
																   JS_CELL_WIDTH - (2*JS_CELL_PADDING + JS_CONTENT_PADDING + JS_LBL_WIDTH)-20.0f, 21.0)];
		label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
		label.textAlignment = UITextAlignmentRight;
		label.tag = 100;
		label.font = [UIFont systemFontOfSize:14.0];
		label.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
		label.text = NSLocalizedString(@"ic.value.notset", nil);
        label.backgroundColor = [UIColor clearColor];
		if (!self.readonly) self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[self addSubview: label];
	}
	
	return self;
}

- (id)initWithInputControlDescriptor:(JSInputControlDescriptor *)icDescriptor resourceDescriptor:(JSResourceDescriptor *)resourceDescriptor tableViewController:(UITableViewController *)tv {
    if (self = [super initWithInputControlDescriptor:icDescriptor resourceDescriptor:resourceDescriptor tableViewController:tv]) {
		if (!self.readonly) self.selectionStyle = UITableViewCellSelectionStyleBlue;
		label = [[UILabel alloc] initWithFrame:CGRectMake(JS_CELL_PADDING + JS_CONTENT_PADDING + JS_LBL_WIDTH, 10.0,
                                                          JS_CELL_WIDTH - (2*JS_CELL_PADDING + JS_CONTENT_PADDING + JS_LBL_WIDTH)-20.0f, 21.0)];
		label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
		label.textAlignment = UITextAlignmentRight;
		label.tag = 100;
		label.font = [UIFont systemFontOfSize:14.0];
		label.textColor = [UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0];
		label.text = NSLocalizedString(@"ic.value.notset", nil);
        label.backgroundColor = [UIColor clearColor];
		
		if (!self.readonly) self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[self addSubview: label];
        self.dateFormat = icDescriptor.validationRules.dateTimeFormatValidationRule.format;
	}
	
	return self;
}


// Specifies if the user can select this cell
- (BOOL)selectable {
	return !self.readonly;
}

// Override the createNameLabel to adjust the label size...
- (void)createNameLabel {
	[super createNameLabel];
	
	// Adjust the label size...
	self.nameLabel.autoresizingMask = UIViewAutoresizingNone;
	CGRect rect = self.nameLabel.frame;
	
	rect.size.width = JS_LBL_TEXT_WIDTH;
	self.nameLabel.frame = rect;
}

- (void)setSelectedValue:(id)vals {
    if (vals && [vals isKindOfClass:[NSString class]]) {
        label.text = vals;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:self.dateFormat];
        vals = [dateFormatter dateFromString:vals];
        [super setSelectedValue:vals];
    } else {
        [super setSelectedValue:vals];
        if (self.selectedValue == nil) {
            label.text = NSLocalizedString(@"ic.value.notset", nil);
        } else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            if ([self.dateFormat length]) {
                [dateFormatter setDateFormat:self.dateFormat];
            } else {
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            }
            label.text = [dateFormatter stringFromDate: self.selectedValue];
        }
    }
}

- (void)cellDidSelected {
    if (self.icDescriptor && self.icDescriptor.state.value.length) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:self.dateFormat];
        self.selectedValue = [dateFormatter dateFromString:self.icDescriptor.state.value];
    }
    
	JSDateTimeSelectorViewController *rvc = [[JSDateTimeSelectorViewController alloc] initWithStyle:UITableViewStyleGrouped];
	rvc.selectionDelegate = self;
	rvc.dateOnly = YES;
	rvc.mandatory = self.mandatory;
	rvc.selectedValue = self.selectedValue;
	[self.tableViewController.navigationController pushViewController: rvc animated: YES];
}

- (id)formattedSelectedValue {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:self.dateFormat];
    return [dateFormatter stringFromDate:self.selectedValue];
}

@end
