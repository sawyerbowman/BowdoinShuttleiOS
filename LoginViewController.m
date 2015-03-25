//
//  LoginViewController.m
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 3/25/15.
//  Copyright (c) 2015 Sawyer Bowman. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

- (void)viewDidLoad {

}

- (IBAction)verifyLogin:(id)sender {
    //if directory contains username
    //if pairing of username and password is correct
    [self performSegueWithIdentifier:@"Login" sender:sender];
}

@end
