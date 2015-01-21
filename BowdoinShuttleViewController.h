//
//  BowdoinShuttleViewController.h
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 1/9/14.
//  Copyright (c) 2014 Sawyer Bowman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "ShuttlePopover.h"
#import "PopoverView.h"

@interface BowdoinShuttleViewController : UIViewController <PopoverViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    PopoverView *pv;
    
    UILabel *tapAnywhereLabel;
    CGPoint point;
}

@property (nonatomic, strong) GMSCameraPosition *camera;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) GMSMarker *marker;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) CLLocation *location2;

@property NSDate *start;
@property NSTimeInterval timeInterval;

@property bool curSet;
@property bool testing;
@property bool firstTimeThrough;
@property bool follow;

@property double rise;
@property double run;

@property NSString *selectedShuttle;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *followButton;


- (IBAction)followShuttle:(id)sender;
+ (bool)isRunning;


@end
