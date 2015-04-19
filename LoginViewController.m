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
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO; //so that action such as clear text field button can be pressed
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (IBAction)verifyLogin:(id)sender {
    //if directory contains username
    //if pairing of username and password is correct
    //NSString* test = [self sha1:self.userName];
    
    //If userName is filled in, continue
    if ([self.userName.text length] != 0 && [self.userName.text length] == 5){
        //Put first letter at back of letters
        NSString* firstLetter = [self.userName.text substringToIndex:1];
        NSString* lastLetters = [self.userName.text substringWithRange:NSMakeRange(1, 4)];
        NSString* reverted = [lastLetters stringByAppendingString:firstLetter];
        
        NSString* hashedID = [self sha1:reverted];
        
        NSString* url = [NSString stringWithFormat:@"http://shuttle.bowdoinimg.net/netdirect/check_login_d.php?ID=%@", hashedID];
        NSString* response = [GetRequest getDataFrom:url];
        
        NSArray* responseTraits = [response componentsSeparatedByString:@"&"];
        
        NSArray* successTraits = [responseTraits[0] componentsSeparatedByString:@"="];
        
        if ([successTraits[1] isEqualToString:@"1"]){
            [self performSegueWithIdentifier:@"Login" sender:sender];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Please Enter A Valid Bowdoin ID Number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    //Else, output error message to user
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Please Enter Your Bowdoin ID Number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

/**
 *Creates a hash
 */

-(NSString*) sha1:(NSString*)input {
    
    
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

@end
