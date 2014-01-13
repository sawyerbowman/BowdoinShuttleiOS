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
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:35.482930000
                                                            longitude:-80.905970000
                                                                 zoom:14];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
    self.view = mapView_;
    [self updateMap];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateMap) userInfo:nil repeats:YES];
}

-(void)updateMap {
    
        //Get the shuttle coordinates from a web page that is already connected to the soap server
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        NSString *urlString = @"http://necstats.org/shuttle/van_l.php";
        NSURL *urlAddress = [[NSURL alloc] initWithString:urlString];
        NSString *coordinates = [self stringWithUrl:urlAddress];
        NSArray *coordinatesDivided = [coordinates componentsSeparatedByString:@","];
        
        NSNumber *vanLatitude = (NSNumber*) coordinatesDivided[0];
        NSNumber *vanLongitude = (NSNumber*) coordinatesDivided[1];
        
        double curLat = [vanLatitude doubleValue];
        double curLon = [vanLongitude doubleValue];
        
        // Creates a marker in the center of the map.
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(curLat, curLon);
        marker.title = @"Shuttle 1";
        marker.snippet = @"Bowdoin College";
        marker.icon = [UIImage imageNamed:@"b_pin.png"];
        marker.map = mapView_;

}

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

@end
