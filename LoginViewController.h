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

@protocol LoginViewControllerDelegate <NSObject>
- (void)loginViewController:(LoginViewController *)controller;

@end

@interface LoginViewController : UIViewController <UIAlertViewDelegate, RequestViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) NSString* hashVal;
@property Boolean email;
@property Boolean success;

@property (nonatomic, weak) id <LoginViewControllerDelegate> delegate;

- (IBAction)verifyLogin:(id)sender;
- (NSString*) sha1:(NSString*)input;

- (IBAction)textFieldReturn:(id)sender;
- (void) hideKeyboard;

@end
