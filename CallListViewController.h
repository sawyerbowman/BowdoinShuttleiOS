//
//  CallListViewController.h
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 9/15/14.
//  Copyright (c) 2014 Sawyer Bowman. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "Request.h"

@class CallListViewController;

@protocol CallListViewControllerDelegate <NSObject>
- (void)callListViewController:(CallListViewController *)controller;

@end

@interface CallListViewController : UITableViewController

-(void)getAllCalls;

@property (nonatomic, weak) id <CallListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *calls;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end