//
//  SelectShuttleViewController.m
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 2/8/14.
//  Copyright (c) 2014 Sawyer Bowman. All rights reserved.
//

#import "SelectShuttleViewController.h"

@interface SelectShuttleViewController ()

@end

@implementation SelectShuttleViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    if ([super initWithStyle:style] != nil){
        self.shuttles = [NSMutableArray array];
        
        [self.shuttles addObject:@"Shuttle 1"];
        
        self.clearsSelectionOnViewWillAppear = NO;
        
        //Calculate how tall the view should be by multiplying
        //the individual row height by the total number of rows.
        NSInteger rowsCount = [self.shuttles count];
        NSInteger singleRowHeight = [self.tableView.delegate tableView:self.tableView
                                               heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        NSInteger totalRowsHeight = rowsCount * singleRowHeight;
        
        //Calculate how wide the view should be by finding how
        //wide each string is expected to be
        CGFloat largestLabelWidth = 0;
        for (NSString *colorName in self.shuttles) {
            //Checks size of text using the default font for UITableViewCell's textLabel.
            CGSize labelSize = [colorName sizeWithFont:[UIFont boldSystemFontOfSize:20.0f]];
            if (labelSize.width > largestLabelWidth) {
                largestLabelWidth = labelSize.width;
            }
        }
        
        //Add a little padding to the width
        CGFloat popoverWidth = largestLabelWidth + 100;
        
        //Set the property to tell the popover container how big this view will be.
        self.contentSizeForViewInPopover = CGSizeMake(popoverWidth, totalRowsHeight);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.shuttles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [self.shuttles objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedShuttle = [self.shuttles objectAtIndex:indexPath.row];
    
    //Create a variable to hold the color, making its default
    //color something annoying and obvious so you can see if
    //you've missed a case here.
    NSString *shuttle = @"Error";
    
    //Set the color object based on the selected color name.
    if ([selectedShuttle isEqualToString:@"Shuttle 1"]) {
        shuttle = @"Shuttle 1";
    }
    else if ([selectedShuttle isEqualToString:@"Shuttle 2"]) {
        shuttle = @"Shuttle 2";
    }
    else if ([selectedShuttle isEqualToString:@"Shuttle 3"]) {
        shuttle = @"Shuttle 3";
    }
    //Notify the delegate if it exists.
    if (self.delegate != nil) {
        [self.delegate selectedShuttle:shuttle];
    }
}

@end
