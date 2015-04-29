//
//  LoginViewController.h
//  BowdoinShuttleiOS
//
//  Created by Sawyer Bowman on 3/25/15.
//  Copyright (c) 2015 Sawyer Bowman. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
#import "GetRequest.h"
#import "RequestViewController.h"
#import "CallListViewController.h"

@class LoginViewController;

//Delegate Method

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginViewController:(LoginViewController *)controller;

@end

//Needs UIAlertViewDelegate for displaying alerts

@interface LoginViewController : UIViewController <UIAlertViewDelegate, RequestViewControllerDelegate>

//Text field to contain bowdoin id
@property (weak, nonatomic) IBOutlet UITextField *userName;

//Value to pass forward
@property (strong, nonatomic) NSString* hashVal;

//Booleans to determine whether to allow login
@property Boolean email;
@property Boolean success;

//Delegate
@property (nonatomic, weak) id <LoginViewControllerDelegate> delegate;

//Sha1 hash given an input string
- (NSString*) sha1:(NSString*)input;

//Keyboard methods
- (IBAction)textFieldReturn:(id)sender;
- (void) hideKeyboard;

@end
