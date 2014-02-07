//
//  BowdoinShuttleViewController.h
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 1/9/14.
//  Copyright (c) 2014 Sawyer Bowman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface BowdoinShuttleViewController : UIViewController
@property (nonatomic, strong) GMSCameraPosition *camera;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) GMSMarker *marker;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) CLLocation *location2;

@property NSDate *start;
@property NSTimeInterval timeInterval;

@property bool curSet;
@property bool firstTimeThrough;
@property bool follow;

@property double rise;
@property double run;

- (IBAction)followShuttle:(id)sender;


@end
