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
//  JMRepositoryTableViewController.m
//  Jaspersoft Corporation
//

#import "JMBaseRepositoryTableViewController.h"
#import "JMConstants.h"
#import "JMUtils.h"
#import <Objection-iOS/Objection.h>

NSInteger const kJMResourcesLimit = 40;
static NSString * const kJMShowResourceInfoSegue = @"ShowResourceInfo";
static NSString * const kJMUnknownCell = @"UnknownCell";

@interface JMBaseRepositoryTableViewController ()
@property (nonatomic, strong, readonly) NSDictionary *cellsIdentifiers;

- (JSResourceLookup *)resourceLookupForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)cellIdentifierForResourceType:(NSString *)resourceType;
@end

@implementation JMBaseRepositoryTableViewController
objection_requires(@"resourceClient", @"constants")
inject_default_rotation()

- (BOOL)isNeedsToReloadData
{
    return self.resources.count == 0;
}

- (void)changeServerProfile
{
    if (self.resources) {
        self.resources = nil;
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.tableView reloadData];
    }
}

#pragma mark - Accessors

@synthesize constants = _constants;
@synthesize cellsIdentifiers = _cellsIdentifiers;
@synthesize resourceClient = _resourceClient;
@synthesize resourceLookup = _resourceLookup;
@synthesize resourceDescriptor = _resourceDescriptor;

- (NSDictionary *)cellsIdentifiers
{
    if (!_cellsIdentifiers) {
        _cellsIdentifiers = @{
            self.constants.WS_TYPE_FOLDER : @"FolderCell",
            self.constants.WS_TYPE_IMG : @"ImageCell",
            self.constants.WS_TYPE_REPORT_UNIT : @"ReportCell",
            self.constants.WS_TYPE_DASHBOARD : @"DashboardCell",
            self.constants.WS_TYPE_CSS : @"TextCell",
            self.constants.WS_TYPE_XML : @"TextCell"
        };
    }
    
    return _cellsIdentifiers;
}

- (NSMutableArray *)resources
{
    if (!_resources) {
        _resources = [NSMutableArray array];
    }

    return  _resources;
}

- (BOOL)isPaginationAvailable
{
    return self.resourceClient.serverProfile.serverInfo.versionAsInteger >= self.constants.VERSION_CODE_EMERALD_TWO;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:kJMShowResourceInfoSegue sender:cell];
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];

    // Add observer to refresh controller after profile was changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeServerProfile)
                                                 name:kJMChangeServerProfileNotification
                                               object:nil];
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [JMUtils setTitleForResourceViewController:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    
    if ([destinationViewController conformsToProtocol:@protocol(JMResourceClientHolder)]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        JSResourceLookup *resourceLookup = [self resourceLookupForIndexPath:indexPath];
        [destinationViewController setResourceLookup:resourceLookup];
        [destinationViewController setResourceClient:self.resourceClient];
    }
}

- (void)didReceiveMemoryWarning
{
    if (![JMUtils isViewControllerVisible:self]) {
        self.resources = nil;
        self.resourceLookup = nil;
        [self.tableView reloadData];
        _cellsIdentifiers = nil;
    }
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resources count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSResourceLookup *resourceLookup = [self resourceLookupForIndexPath:indexPath];
    NSString *cellIdentifier = [self cellIdentifierForResourceType:resourceLookup.resourceType];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.textLabel.text = resourceLookup.label;
    cell.detailTextLabel.text = resourceLookup.uri;
        
    return cell;
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    if (!self.isPaginationAvailable) {
        for (JSResourceDescriptor *resourceDescriptor in result.objects) {
            NSString *type = resourceDescriptor.wsType;
            // Show only folder, report and dashboard resources
            if ([type isEqualToString:self.constants.WS_TYPE_FOLDER] ||
                [type isEqualToString:self.constants.WS_TYPE_REPORT_UNIT] ||
                [type isEqualToString:self.constants.WS_TYPE_DASHBOARD]) {
            
                JSResourceLookup *resourceLookup = [[JSResourceLookup alloc] init];
                resourceLookup.label = resourceDescriptor.label;
                resourceLookup.resourceDescription = resourceDescriptor.resourceDescription;
                resourceLookup.resourceType = type;
                resourceLookup.uri = resourceDescriptor.uriString;
                [self.resources addObject:resourceLookup];
            }
        }
    } else {
        [self.resources addObjectsFromArray:result.objects];
    }
    
    // TODO: move comparator to sdk
    [self.resources sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 resourceType] == self.constants.WS_TYPE_FOLDER) {
            if ([obj2 resourceType] != self.constants.WS_TYPE_FOLDER) {
                return NSOrderedDescending;
            }
        } else {
            if ([obj2 resourceType] == self.constants.WS_TYPE_FOLDER) {
                return NSOrderedAscending;
            }
        }
        
        return [[obj1 label] compare:[obj2 label] options:NSCaseInsensitiveSearch];
    }];
    
    [self.tableView reloadData];
}

#pragma mark - Private

- (JSResourceLookup *)resourceLookupForIndexPath:(NSIndexPath *)indexPath
{
    return [self.resources objectAtIndex:indexPath.row];
}

- (NSString *)cellIdentifierForResourceType:(NSString *)resourceType
{
    return [self.cellsIdentifiers objectForKey:resourceType] ?: kJMUnknownCell;
}

@end
