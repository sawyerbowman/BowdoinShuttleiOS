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

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //If buttonIndex is yes, get the email from the user
    if (buttonIndex == 1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Add your email" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert textFieldAtIndex:0].placeholder = @"ex. bmills@bowdoin.edu";
        [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeEmailAddress;
        [alert show];
    }
    else {
        UITextField *textfield =  [alertView textFieldAtIndex: 0];
        
        NSString* url = [NSString stringWithFormat:@"http://shuttle.bowdoinimg.net/netdirect/addemail_d.php?ID=%@&email=%@", self.hashVal, textfield.text];
        NSString* response = [GetRequest getDataFrom:url];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
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
        self.hashVal = [[NSString alloc] initWithString:hashedID];
        
        NSString* url = [NSString stringWithFormat:@"http://shuttle.bowdoinimg.net/netdirect/check_login_d.php?ID=%@", self.hashVal];
        NSString* response = [GetRequest getDataFrom:url];
        
        Boolean success = false;
        
        NSArray* responseTraits = [response componentsSeparatedByString:@"&"];
        for (NSString* trait in responseTraits){
            if ([trait isEqualToString:@"success=1"]){
                success = true;
            }
            else if ([trait isEqualToString:@"email=0"]){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"You will not be able to receive email updates. Do you want to add your email?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                [alert show];
            }
        }
        if (success){
            return YES;
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
    return NO;
}

/**
 *Prepares for segue to request
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITabBarController *tabbar=segue.destinationViewController;
    UINavigationController *navController = [tabbar.viewControllers objectAtIndex:0];
    RequestViewController *svc=[navController.viewControllers objectAtIndex:0];
    svc.hashVal = self.hashVal;

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
