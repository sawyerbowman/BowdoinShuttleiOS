//
//  Place.h
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 1/29/15.
//  Copyright (c) 2015 Sawyer Bowman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject

@property (nonatomic, copy) NSString *ident;
@property (nonatomic, copy) NSString *name;
@property double latitude;
@property double longitude;

@end
