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

@class LoginViewController;

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userName;

- (IBAction)verifyLogin:(id)sender;
- (NSString*) sha1:(NSString*)input;

- (IBAction)textFieldReturn:(id)sender;
- (void) hideKeyboard;

@end
