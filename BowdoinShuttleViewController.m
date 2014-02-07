//
//  BowdoinShuttleViewController.m
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 1/9/14.
//  Copyright (c) 2014 Sawyer Bowman. All rights reserved.
//

#import "BowdoinShuttleViewController.h"
#import <GoogleMaps/GoogleMaps.h>

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
    self.view = mapView_;
    // Creates a marker in the map.
    self.marker = [[GMSMarker alloc] init];
    self.location = [[CLLocation alloc] init];
    self.start = [[NSDate alloc] init];
    self.follow = false;
    self.firstTimeThrough = true;
    
    [self updateMapWithMotion];
    if (self.firstTimeThrough) {
        self.start = [NSDate date];
    }
    
    //[self updateMap];
    //used to be 30 seconds... trying a delay
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.005 target:self selector:@selector(updateMapWithMotion) userInfo:nil repeats:YES];
    
    // display warning if not running
    [self isRunning];
}


-(void)updateMapWithMotion {
    
    [self updateCenter];
    self.timeInterval = (-1)*[self.start timeIntervalSinceNow];
    
    if (self.firstTimeThrough || self.timeInterval >= 30) {
    
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        NSString *urlString = @"http://necstats.org/shuttle/van_l.php";
        NSURL *urlAddress = [[NSURL alloc] initWithString:urlString];
        NSString *coordinates = [self stringWithUrl:urlAddress];
        NSArray *coordinatesDivided = [coordinates componentsSeparatedByString:@","];
    
        NSNumber *vanLatitude = (NSNumber*) coordinatesDivided[0];
        NSNumber *vanLongitude = (NSNumber*) coordinatesDivided[1];
        
        double curLat = [vanLatitude doubleValue];
        double curLon = [vanLongitude doubleValue];
        
        self.timeInterval = (-1)*[self.start timeIntervalSinceNow];
        
        if (self.timeInterval >= 30) {
            self.location2 = [[CLLocation alloc] init];
            self.location2 = [self.location2 initWithLatitude:curLat longitude:curLon];

//            if (self.testing) {
//                self.location2 = [self.location2 initWithLatitude:43.9154663085938 longitude:-69.964973449707];
//            }
//            else {
//                self.location2 = [self.location2 initWithLatitude:43.9126892089844 longitude:-69.9608001708984];
//            }
            self.start = [[NSDate alloc] init];
        }
        else if (self.firstTimeThrough) {
            //self.location = [self.location initWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude];
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
    if (self.timeInterval < 30 && self.location2 != nil) {
        double latitude = self.location.coordinate.latitude;
        double latitude2 = self.location2.coordinate.latitude;
        double longitude = self.location.coordinate.longitude;
        double longitude2 = self.location2.coordinate.longitude;
        self.rise = latitude2 - latitude;
        self.run = longitude2 - longitude;
        
        self.timeInterval = (-1)*[self.start timeIntervalSinceNow];
        double multiplier = self.timeInterval*.005;
        double fraction = (30/multiplier);
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

//-(void)updateMap {
//    
//        //Get the shuttle coordinates from a web page that is already connected to the soap server
//        [[NSURLCache sharedURLCache] removeAllCachedResponses];
//        NSString *urlString = @"http://necstats.org/shuttle/van_l.php";
//        NSURL *urlAddress = [[NSURL alloc] initWithString:urlString];
//        NSString *coordinates = [self stringWithUrl:urlAddress];
//        NSArray *coordinatesDivided = [coordinates componentsSeparatedByString:@","];
//        
//        NSNumber *vanLatitude = (NSNumber*) coordinatesDivided[0];
//        NSNumber *vanLongitude = (NSNumber*) coordinatesDivided[1];
//        
//        double curLat = [vanLatitude doubleValue];
//        double curLon = [vanLongitude doubleValue];
//    
//        self.marker.position = CLLocationCoordinate2DMake(curLat, curLon);
//        self.marker.title = @"Shuttle 1";
//        self.marker.snippet = @"Bowdoin College";
//        self.marker.icon = [UIImage imageNamed:@"b_pin.png"];
//        self.marker.map = mapView_;
//
//}

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

-(void)isRunning
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
        }
    }
    else {
        if (currentHour < 18 && currentHour > 02) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"The Shuttle is not running right now." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (IBAction)followShuttle:(id)sender {
    if (!self.follow){
        self.follow = true;
        [sender setTitle:@"Unfollow"];
        [sender setTintColor:[UIColor redColor]];

    }
    else {
        self.follow = false;
        [sender setTitle:@"Follow"];
        UIColor *color = [UIColor colorWithRed:23/255.0f green:204/255.0f blue:0/255.0f alpha:1.0f];
        [sender setTintColor:color];
    }
}

-(void)updateCenter {
    if (self.follow) {
        CLLocationCoordinate2D current = CLLocationCoordinate2DMake(self.location.coordinate.latitude,self.location.coordinate.longitude);
        GMSCameraUpdate *currentCam = [GMSCameraUpdate setTarget:current];
        [mapView_ animateWithCameraUpdate:currentCam];
    }
}
@end
