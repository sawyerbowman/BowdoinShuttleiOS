//
//  SelectShuttleViewController.h
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 2/8/14.
//  Copyright (c) 2014 Sawyer Bowman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectShuttleDelegate <NSObject>
@required
-(void)selectedShuttle:(NSString *)newShuttle;
@end

@interface SelectShuttleViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *shuttles;
@property (nonatomic, weak) id<SelectShuttleDelegate> delegate;

@end
