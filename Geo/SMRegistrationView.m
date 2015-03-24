//
//  SMRegistrationView.m
//  GeoChatWithXMPP
//
//  Created by Данил on 03/03/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "SMRegistrationView.h"
#import "AppDelegate.h"
#import "ViewController.h"
@implementation SMRegistrationView

@synthesize login,name,password;

-(IBAction)registr{
    [self createAccount];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)createAccount
{
    NSError *error = nil;
    NSString *juser =[[NSString alloc] initWithString:[login.text stringByAppendingString:@"@kampus_gid"]];

        NSMutableArray *elements = [NSMutableArray array];
        [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:juser]];
        [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:password.text]];


     [[self xmppStream ] registerWithElements:elements error:&error];

}
-(void) viewDidLoad{
    self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                                               target:self
                                                                                                               action:@selector(close)];

}




- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}






@end




