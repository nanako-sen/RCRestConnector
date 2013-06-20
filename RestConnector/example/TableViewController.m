//
//  TableViewController.m
//  RestConnector
//
//  Created by Anna Walser on 26/02/13.
//  Copyright (c) 2013 Anna Walser. All rights reserved.
//

#import "TableViewController.h"
#import "FBPublicPostManager.h"
#import "FBPublicPost.h"
#import "FBGroup.h"

@interface TableViewController (){
    FBPublicPostManager *_peopleManager;
    NSArray *_people;
}

@end

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _peopleManager = [[FBPublicPostManager alloc] initWithDelegate:(id)self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/search?q=watermelon&type=post"];
//    NSDictionary *mapp = @{@"likes": @{@"likes":@{@"data":@"name"}}, @"postId":@"id", @"name":@{@"from": @"name"}};
//    [_peopleManager GETDataFromURL:url forClass:@"FBPublicPost" atKey:@"data" withMappingDictionary:mapp];
    
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/search?q=programming&type=group"];
    NSDictionary *mapp = @{@"groupId" : @"id", @"name": @"name"};
    _peopleManager.cachingEnabled = YES;
    _peopleManager.cacheRefreshInterval = 10;
    [_peopleManager GETDataFromURL:url forClass:@"FBGroup" atKey:@"data" withMappingDictionary:mapp];
    
    


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RCDataManager Delegate

- (void)dataObjectCreated:(id)object
{
    _people = [(NSSet*)object allObjects];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_people count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    FBGroup* post = [_people objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", post.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"likes: %@",post.groupId];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
