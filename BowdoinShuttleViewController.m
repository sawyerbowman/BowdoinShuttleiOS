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

/**
 *Does a lot of initialization. Sets up Google Maps. Updates map with pin moving
 *for time intervals.
 */

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
    [self getLocation];
    self.location2 = [[CLLocation alloc] init];
    [self getLocation2];
    self.follow = false;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:.04 target:self selector:@selector(updateMapWithMotionQuadratic) userInfo:nil repeats:YES];
    
    // display warning if not running
    [BowdoinShuttleViewController isRunning];
}

/**
 *An updated method to simulate smooth movement of the shuttle's pin. It uses
 *a quadratic formula to do so.
 */

-(void)updateMapWithMotionQuadratic {
    //double finalLat = self.location2.coordinate.latitude;
    //double finalLon = self.location2.coordinate.longitude;
    //NSLog(@"%f %f", self.location2.coordinate.latitude, self.location2.coordinate.longitude);
    if (self.location2.coordinate.latitude == 0 && self.location2.coordinate.longitude == 0){
        [self getLocation2];
        return;
    }
    
    double changeInLat = self.location2.coordinate.latitude - self.location.coordinate.latitude;
    double changeInLon = self.location2.coordinate.longitude - self.location.coordinate.longitude;
    
    double curLat = 0;
    double curLon = 0;
    
    if (self.t <= 5){
        curLat = self.location.coordinate.latitude + changeInLat / 50 * self.t * self.t;
        curLon = self.location.coordinate.longitude + changeInLon / 50 * self.t * self.t;
        self.t += .04;
    }
    else{
        curLat = self.location.coordinate.latitude + changeInLat / 2 + changeInLat * (self.t-5) / 5 - changeInLat * (self.t-5) * (self.t-5) / 50;
        curLon =  self.location.coordinate.longitude + changeInLon / 2 + changeInLon * (self.t-5) / 5 - changeInLon * (self.t-5) * (self.t-5) / 50;
        self.t += .04;
    }
    if (self.t >= 10){
        self.marker.position = self.location2.coordinate;
        self.location = [self.location initWithLatitude:self.location2.coordinate.latitude longitude:self.location2.coordinate.longitude];
        [self getLocation2];
        self.t = 0;
    }
    
    [self setUpMarkerWithLat:curLat andLon:curLon];
    
    [self updateCenter];
}

/**
 *Get's the first location and sets up the marker.
 */

-(void)getLocation {
    self.location = [self parseAndAssignCoordinateTo:self.location];
    NSLog(@"%f, %f", self.location.coordinate.latitude, self.location.coordinate.longitude);
    [self setUpMarkerWithLat:self.location.coordinate.latitude andLon:self.location.coordinate.longitude];
}

/**
 *Gets the second location, continuously making calls until it finds a location
 *that is different from the first location.
 */

-(void)getLocation2{
    if ((self.location.coordinate.latitude  == self.location2.coordinate.latitude && self.location.coordinate.longitude == self.location2.coordinate.longitude) || (self.location2.coordinate.latitude == 0 && self.location2.coordinate.longitude == 0) ){
        self.location2 = [self parseAndAssignCoordinateTo:self.location2];
    }
}

/**
 *Sets up the marker and puts it on the map.
 */

-(void) setUpMarkerWithLat:(double)lat andLon:(double)lon {
    self.marker.title = @"Shuttle 1";
    self.marker.snippet = @"Bowdoin College";
    self.marker.icon = [UIImage imageNamed:@"b_pin.png"];
    self.marker.position = CLLocationCoordinate2DMake(lat, lon);
    self.marker.map = mapView_;
}

/**
 *Parses the webpage responsible for getting the shuttle coordinates and returns it.
 */

-(CLLocation *)parseAndAssignCoordinateTo:(CLLocation *) location {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSString *urlString = @"http://shuttle.bowdoinimg.net/van_l.php?van=0";
    //Use this string for testing
    //NSString *urlString = @"http://shuttle.bowdoinimg.net/van_l_r.php?van=0";
    NSURL *urlAddress = [[NSURL alloc] initWithString:urlString];
    NSString *coordinates = [self stringWithUrl:urlAddress];
    NSArray *coordinatesDivided = [coordinates componentsSeparatedByString:@","];
    
    NSNumber *vanLatitude = (NSNumber*) coordinatesDivided[0];
    NSNumber *vanLongitude = (NSNumber*) coordinatesDivided[1];
    
    double curLat = [vanLatitude doubleValue];
    double curLon = [vanLongitude doubleValue];
    location = [location initWithLatitude:curLat longitude:curLon];
    return location;
}

/**
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

/**
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

/**
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
    }
    else {
        self.follow = false;
        [sender setTitle:@"Follow"];
        UIColor *color = [UIColor colorWithRed:23/255.0f green:204/255.0f blue:0/255.0f alpha:1.0f];
        [sender setTintColor:color];
    }
}

/**
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

/**
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
