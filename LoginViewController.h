//
//  LoginViewController.h
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 3/25/15.
//  Copyright (c) 2015 Sawyer Bowman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginViewController;

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userName;

@property (weak, nonatomic) IBOutlet UITextField *password;

- (IBAction)verifyLogin:(id)sender;

@end
