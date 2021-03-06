//
//  CallListViewController.m
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 9/15/14.
//  Copyright (c) 2014 Sawyer Bowman. All rights reserved.
//

#import "CallListViewController.h"

@interface CallListViewController ()

@end

@implementation CallListViewController
{
    NSUInteger selectedIndex;
}

/**
 *
 */

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

/**
 *
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
}

/**
 *Determines if cancel button and track buttom should appear. Gets all calls to
 *display.
 */

-(void)viewWillAppear:(BOOL)animated {
    [self showCancelButton];
    [self getAllCalls];
}

/**
 *
 */

- (void)viewDidUnload
{

}

/**
 *This method cancels the user's call.
 */

- (IBAction)cancelVanCall:(id)sender {
    NSString *passUrl = [NSString stringWithFormat:@"http://shuttle.bowdoinimg.net/netdirect/cancel_d.php?bh=%@", self.hashVal];
    NSString* response = [GetRequest getDataFrom:passUrl];
    
    if ([[response substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Call canceled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self getAllCalls];
        [self showCancelButton];
        [self.tableView reloadData];
    }
    else {
        NSScanner *scanner = [NSScanner scannerWithString:response];
        NSString *preMessage = [[NSString alloc] init];
        NSString *postMessage = [[NSString alloc] init];
        
        [scanner scanUpToString:@"message=" intoString:&preMessage];
        [scanner scanString:@"message=" intoString:nil];
        postMessage = [response substringFromIndex:scanner.scanLocation];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:postMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

/**
 *This method checks to see if the user has a call that can be cancelled. If not,
 *the cancel call button will not be displayed.
 */

-(void)showCancelButton{
    NSString *passUrl = [NSString stringWithFormat:@"http://shuttle.bowdoinimg.net/netdirect/call_check_d.php?bh=%@", self.hashVal];
    NSString *data = [GetRequest getDataFrom:passUrl];
    
    //If call not made, don't show any buttons
    if ([data containsString:@"code=0"]){
        self.cancelButton.enabled = false;
        self.trackButton.enabled = false;
    }
    //If call made, can cancel
    else if ([data containsString:@"code=1"]) {
        self.cancelButton.enabled = true;
        //If dispatched, can track shuttle
        if ([data containsString:@"dispatched=1"]){
            self.trackButton.enabled = true;
        }
    }
}

/**
 *This method is responsible for obtaining each request and reformatting them.
 */

- (void)getAllCalls{
    self.calls = [[NSMutableArray alloc] init];
    NSString *passUrl = [NSString stringWithFormat:@"http://shuttle.bowdoinimg.net/netdirect/track_d.php?bh=%@", self.hashVal];
    NSString *data = [GetRequest getDataFrom:passUrl];
    if ([data isEqualToString:@""]){
        [self.tableView reloadData];
        return;
    }
    else if ([data containsString:@"This van"]){
        NSRange range = [data rangeOfString:@"This van"];
        self.waitingCalls.text = [data substringFromIndex:range.location];
    }
    else if ([data containsString:@"There are"]){
        self.waitingCalls.text = data;
    }
    NSLog(@"%@", data);
    NSArray *rawData = [self generateArray:data];
    for (NSString *element in rawData){
        Request *newRequest = [self parseEntry:element];
        [self.calls addObject:newRequest];
    }
    [self.tableView reloadData];
}

- (NSArray*)generateArray:(NSString*)data{
    NSArray *rawData = [data componentsSeparatedByString:@"\n"];
    return rawData;
}

/**
 *This method parses each line returned from the network call to the list of calls.
 *Right now, we are only displaying origin, destination, and number of passengers, as
 *multiple vans have not been implemented.
 */

- (Request*)parseEntry:(NSString*)entry {
    NSArray *rawData = [entry componentsSeparatedByString:@"&"];
    Request *newRequest = [[Request alloc] init];
    for (NSString *element in rawData){
        if ([element isEqualToString:@""]){
            continue;
        }
        if ([element hasPrefix:@"ID="]){
            NSString *prefix = @"ID=";
            NSString *ID = [element substringWithRange:NSMakeRange(prefix.length, element.length-prefix.length)];
        }
        else if ([element hasPrefix:@"van="]){
            NSString *prefix = @"van=";
            NSString *van = [element substringWithRange:NSMakeRange(prefix.length, element.length-prefix.length)];
        }
        else if ([element hasPrefix:@"source="]){
            NSString *prefix = @"source=";
            NSString *source = [element substringWithRange:NSMakeRange(prefix.length, element.length-prefix.length)];
            newRequest.origin = source;
        }
        else if ([element hasPrefix:@"destination="]){
            NSString *prefix = @"destination=";
            NSString *destination = [element substringWithRange:NSMakeRange(prefix.length, element.length-prefix.length)];
            newRequest.destination = destination;
        }
        else if ([element hasPrefix:@"people="]){
            NSString *prefix = @"people=";
            NSString *people = [element substringWithRange:NSMakeRange(prefix.length, element.length-prefix.length)];
            newRequest.passengers = people;
        }
        else if ([element hasPrefix:@"group_with="]){
            NSString *prefix = @"group_with=";
            NSString *groupwith = [element substringWithRange:NSMakeRange(prefix.length, element.length-prefix.length)];
        }
        else if ([element hasPrefix:@"picked_up="]){
            NSString *prefix = @"picked_up=";
            NSString *pickedup = [element substringWithRange:NSMakeRange(prefix.length, element.length-prefix.length)];
        }
    }
    return newRequest;
}

/**
 *
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

/**
 *
 */

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.calls count];
}

/**
 *
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"CallListCell"];
    NSString* finalText = [[((Request*)[self.calls objectAtIndex:indexPath.row]).origin stringByAppendingString:@" to "] stringByAppendingString:((Request*)[self.calls objectAtIndex:indexPath.row]).destination];
	cell.textLabel.text = finalText;

    cell.accessoryType = UITableViewCellAccessoryNone;
	return cell;
}

/**
 *
 */

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (selectedIndex != NSNotFound)
	{
		UITableViewCell *cell = [tableView
                                 cellForRowAtIndexPath:[NSIndexPath
                                                        indexPathForRow:selectedIndex inSection:0]];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	selectedIndex = indexPath.row;
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
}

/**
 *Delegate method to return from shuttle tracker view
 */

- (void)bowdoinShuttleViewController:(BowdoinShuttleViewController *)controller{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *This method selects the next page to display depending on the button clicked.
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TrackShuttle"])
    {
        BowdoinShuttleViewController *bowdoinShuttleViewController = segue.destinationViewController;
        bowdoinShuttleViewController.delegate = self;
    }
    
}

/**
 *Performs the track shuttle segue when navigation button is clicked
 */

- (IBAction)trackShuttle:(id)sender {
    [self performSegueWithIdentifier:@"TrackShuttle" sender:sender];
}
@end