//
//  ShuttlePopover.m
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 2/8/14.
//  Copyright (c) 2014 Sawyer Bowman. All rights reserved.
//

#import "ShuttlePopover.h"

@implementation UIPopoverController (overrides)

+ (BOOL)_popoversDisabled {
    return NO;
}

@end
