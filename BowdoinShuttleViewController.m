//
//  BowdoinShuttleViewController.m
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 1/9/14.
//  Copyright (c) 2014 Sawyer Bowman. All rights reserved.
//

#import "BowdoinShuttleViewController.h"
#import <GoogleMaps/GoogleMaps.h>

#define kStringArray [NSArray arrayWithObjects:@"Shuttle 1", @"Shuttle 2", nil]
#define kImageArray [NSArray arrayWithObjects:[UIImage imageNamed:@"success"], [UIImage imageNamed:@"error"], nil]

@implementation BowdoinShuttleViewController {
    GMSMapView *mapView_;
}

- (void)viewDidLoad {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate, and tells us the center
    self.camera = [GMSCameraPosition cameraWithLatitude:43.9083823
                                                            longitude:-69.9608962
                                                                 zoom:16];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:self.camera];
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
    mapView_.settings.rotateGestures = NO;
    self.view = mapView_;
    // Creates a marker in the map.
    self.marker = [[GMSMarker alloc] init];
    self.location = [[CLLocation alloc] init];
    self.start = [[NSDate alloc] init];
    self.follow = false;
    self.testing = false;
    self.firstTimeThrough = true;
    
    [self updateMapWithMotion];
    if (self.firstTimeThrough) {
        self.start = [NSDate date];
    }
    //[self updateMap];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(updateMapWithMotion) userInfo:nil repeats:YES];
    // display warning if not running
    [BowdoinShuttleViewController isRunning];
}

/*
 *This method is responsible for moving the pin. On the first run through, it waits 10 seconds
 *(the delay between stops from Track My Track). Then, it will move the Bowdoin pin from point
 *to point.
 */


-(void)updateMapWithMotion {
    
    [self updateCenter];
    self.timeInterval = (-1)*[self.start timeIntervalSinceNow];
    
    if (self.firstTimeThrough || self.timeInterval >= 10) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        //NSString *urlString = @"http://necstats.org/shuttle/van_l.php";
        NSString *urlString = @"http://shuttle.bowdoinimg.net/van_l.php?van=0";
        NSURL *urlAddress = [[NSURL alloc] initWithString:urlString];
        NSString *coordinates = [self stringWithUrl:urlAddress];
        NSArray *coordinatesDivided = [coordinates componentsSeparatedByString:@","];
    
        NSNumber *vanLatitude = (NSNumber*) coordinatesDivided[0];
        NSNumber *vanLongitude = (NSNumber*) coordinatesDivided[1];
        
        double curLat = [vanLatitude doubleValue];
        double curLon = [vanLongitude doubleValue];
        
        self.timeInterval = (-1)*[self.start timeIntervalSinceNow];
        
        if (self.timeInterval >= 10) {
            self.location2 = [[CLLocation alloc] init];
            self.location2 = [self.location2 initWithLatitude:curLat longitude:curLon];
            
            //These lines are used to demonstrate the shuttle moving (when shuttle isn't running)
//            if (self.testing) {
//                self.location2 = [self.location2 initWithLatitude:43.9154663085938 longitude:-69.964973449707];
//            }
//            else {
//                self.location2 = [self.location2 initWithLatitude:43.9126892089844 longitude:-69.9608001708984];
//                self.testing = true;
//            }
            
            self.start = [[NSDate alloc] init];
        }
        else if (self.firstTimeThrough) {
            self.location = [self.location initWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude];
            self.location = [self.location initWithLatitude:curLat longitude:curLon];
            //self.location = [self.location initWithLatitude:43.9111557006836 longitude:-69.9614891967773];
            self.marker.position = CLLocationCoordinate2DMake(curLat, curLon);
            //self.marker.position = CLLocationCoordinate2DMake(43.9111557006836, -69.9614891967773);
            self.marker.title = @"Shuttle 1";
            self.marker.snippet = @"Bowdoin College";
            self.marker.icon = [UIImage imageNamed:@"b_pin.png"];
            self.marker.map = mapView_;
            self.firstTimeThrough = false;
            self.start = [NSDate date];
        }
        
    }
    self.timeInterval = (-1)*[self.start timeIntervalSinceNow];
    if (self.timeInterval < 10 && self.location2 != nil) {
        double latitude = self.location.coordinate.latitude;
        double latitude2 = self.location2.coordinate.latitude;
        double longitude = self.location.coordinate.longitude;
        double longitude2 = self.location2.coordinate.longitude;
        self.rise = latitude2 - latitude;
        self.run = longitude2 - longitude;
        
        self.timeInterval = (-1)*[self.start timeIntervalSinceNow];
        double multiplier = self.timeInterval*.04;
        double fraction = (10/multiplier);
        double latFraction = self.rise/fraction;
        double lonFraction = self.run/fraction;
        latitude += latFraction;
        longitude += lonFraction;
        
        self.location = [self.location initWithLatitude:latitude longitude:longitude];
        
        self.marker.position = CLLocationCoordinate2DMake(latitude, longitude);
        self.marker.title = @"Shuttle 1";
        self.marker.snippet = @"Bowdoin College";
        self.marker.icon = [UIImage imageNamed:@"b_pin.png"];
        self.marker.map = mapView_;
        
        [self updateCenter];
    }
}

/*
 *This method gets the coordinates of the shuttle from Track My Truck.
 */

- (NSString *)stringWithUrl:(NSURL *)url
{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                            timeoutInterval:30];
    // Fetch the JSON response
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    
    // Construct a String around the Data from the response
    return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

/*
 *This method determines whether the shuttle is running based on the current day and time.
 */

+ (bool)isRunning
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *day = [dateFormatter stringFromDate:today];
    
    [dateFormatter setDateFormat:@"HH"];
    NSString *hour = [dateFormatter stringFromDate:today];
    int currentHour = [hour intValue];
    
    if ([day isEqualToString:@"Thursday"] || [day isEqualToString:@"Friday"] || [day isEqualToString:@"Saturday"]) {
        if (currentHour < 18 && currentHour > 3){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"The Shuttle is not running right now." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return false;
        }
    }
    else {
        if (currentHour < 18 && currentHour > 02) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"The Shuttle is not running right now." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return false;
        }
    }
    return true;
}

/*
 *This method first creates a popup that allows the user to select which shuttle to follow (only one for now)
 *Then the map centers on the shuttle and keeps it centered as it moves.
 */

- (IBAction)followShuttle:(id)sender {
    if (!self.follow){
        point.x = 320;
        
        pv = [PopoverView showPopoverAtPoint:point
                                      inView:self.view
                                   withTitle:@"Follow which shuttle?"
                             withStringArray:kStringArray
                                    delegate:self];
        //want to set once follow is true
//        [sender setTitle:@"Unfollow"];
//        [sender setTintColor:[UIColor redColor]];
    }
    else {
        self.follow = false;
        [sender setTitle:@"Follow"];
        UIColor *color = [UIColor colorWithRed:23/255.0f green:204/255.0f blue:0/255.0f alpha:1.0f];
        [sender setTintColor:color];
    }
}

/*
 *This method keeps the center updates when we are following a particular shuttle.
 */

-(void)updateCenter {
    if (self.follow) {
        if ([self.selectedShuttle isEqualToString:@"Shuttle 1"]){
        
            //CLLocationCoordinate2D current = CLLocationCoordinate2DMake(self.location.coordinate.latitude,self.location.coordinate.longitude);
            CLLocationCoordinate2D current = CLLocationCoordinate2DMake(self.marker.position.latitude,self.marker.position.longitude);
            GMSCameraUpdate *currentCam = [GMSCameraUpdate setTarget:current];
            [mapView_ animateWithCameraUpdate:currentCam];
        }
    }
}

/*
 *This method uses PopoverView (opensource code) to create a popup for the follow shuttle option.
 */

- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"%s item:%d", __PRETTY_FUNCTION__, index);
    
    // Figure out which string was selected, store in "string"
    self.selectedShuttle = [kStringArray objectAtIndex:index];
    NSLog(@"%@",self.selectedShuttle);
    
    self.follow = true;
    [self.followButton setTitle:@"Unfollow"];
    [self.followButton setTintColor:[UIColor redColor]];
    
    // Show a success image, with the string from the array
    //[popoverView showImage:[UIImage imageNamed:@"success"] withMessage:string];
    
    // alternatively, you can use
    // [popoverView showSuccess];
    // or
    // [popoverView showError];
    
    // Dismiss the PopoverView after 0.5 seconds
    [popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.5f];
}

@end
