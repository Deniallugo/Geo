//
//  AppDelegate.m
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

#import "GCDAsyncSocket.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "SMLoginView.h"
#import "DDLog.h"
#import "GCDAsyncSocket.h"
#import "XMPPLogging.h"
#import "DDTTYLogger.h"

#import "NSUserDefaults+DemoSettings.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize _chatDelegate, _messageDelegate,chatViewController;
@synthesize xmppCapabilities;
@synthesize xmppRoster;
@synthesize xmppvCardAvatarModule;
@synthesize xmppvCardTempModule;
@synthesize xmppStream;
static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure logging framework
    device = @"Main";

    //  device = [self appNameAndVersionNumberDisplayString ];
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];

    //// Setup the view controllers
    UIStoryboard * Main= [UIStoryboard storyboardWithName:device bundle:nil];

    loginViewController = [Main instantiateViewControllerWithIdentifier:@"login"] ;
    chatViewController = [Main instantiateViewControllerWithIdentifier:@"chat"] ;



    // Setup the XMPP stream
    host = @"5.143.43.41";

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:loginViewController];
    self.window.rootViewController = navigation;
    [self.window makeKeyAndVisible];


    [self setupStream];
    if (![CLLocationManager locationServicesEnabled]) {
        // location services is disabled, alert user
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DisabledTitle", @"DisabledTitle")
                                                                        message:NSLocalizedString(@"DisabledMessage", @"DisabledMessage")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"OKButtonTitle", @"OKButtonTitle")
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }


    [self connect];

    [NSUserDefaults saveIncomingAvatarSetting:YES];
    [NSUserDefaults saveOutgoingAvatarSetting:YES];

    return YES;
}

- (NSString *)appNameAndVersionNumberDisplayString {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];

    return [NSString stringWithFormat:@"%@, Version %@ (%@)",
            appDisplayName, majorVersion, minorVersion];
}

- (void)setupStream {

    xmppStream = [[XMPPStream alloc] init];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:[XMPPCapabilitiesCoreDataStorage sharedInstance]];
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:[XMPPRosterCoreDataStorage sharedInstance]];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:[XMPPvCardCoreDataStorage sharedInstance]];
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];

    // Configure modules

    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    [xmppRoster setAutoFetchRoster:YES];
    //    [xmppRoster setAutoRoster:YES];
    [xmppStream setHostName:host];
    [xmppStream setHostPort:5222];

    /**
     * Add XMPPRoster as a delegate of XMPPvCardAvatarModule to cache roster photos in the roster.
     * This frees the view controller from having to save photos on the main thread.
     **/
    [xmppvCardAvatarModule addDelegate:xmppRoster delegateQueue:xmppRoster.moduleQueue];


    // Activate xmpp modules

    [xmppCapabilities activate:xmppStream];
    [xmppRoster activate:xmppStream];
    [xmppvCardTempModule activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];

    // Add ourself as a delegate to anything we may be interested in

    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];

    xmppReconnect = [[XMPPReconnect alloc] init];
    [xmppReconnect activate:xmppStream];
    [xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];

    allowSelfSignedCertificates = NO;
    allowSSLHostNameMismatch = NO;
}

- (void)goOnline {
    UIStoryboard * Main= [UIStoryboard storyboardWithName:device bundle:nil];

    chatViewController = (SMChatViewController*)[Main instantiateViewControllerWithIdentifier:@"chat"] ;

    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:chatViewController];

    self.window.rootViewController = navigation;
    //    self.window.rootViewController = chatViewController;






    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}


- (BOOL)connect {

    [self setupStream];

    login = [[NSUserDefaults standardUserDefaults] stringForKey:@"userID"];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"userPassword"];

    NSString *jabberID = [login stringByAppendingString:@"@kampus_gid"];
    if (![xmppStream isDisconnected]) {
        return YES;
    }

    if (jabberID == nil || myPassword == nil) {

        return NO;
    }

    [xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    password = myPassword;

    NSError *error = nil;

    if (!
        [xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]
        )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];

        return NO;
    }


    return YES;
}





- (void)disconnect {

    [self goOffline];
    [xmppStream disconnect];

}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {

    isOpen = YES;
    NSError *error = nil;
    [[self xmppStream] authenticateWithPassword:password error:&error];

}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {

    [self goOnline];

}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {

    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];

    if (![presenceFromUser isEqualToString:myUsername]) {

        if ([presenceType isEqualToString:@"available"]) {

            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];

        } else if ([presenceType isEqualToString:@"unavailable"]) {

            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];

        }

    }

}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{



    NSXMLElement *queryElement = [iq elementForName:@"query"];
    if(queryElement){
        NSArray *items = [queryElement elementsForName:@"message"];
        NSMutableArray* messages = [[NSMutableArray alloc] init];

        for (NSXMLElement *i in items) {


            NSString* text = [[i elementForName:@"body"] stringValue];
            NSString* user = [[i elementForName:@"user"] stringValue];
            NSString* identificator = [[i elementForName:@"id"] stringValue];
            NSString* delivered ;
            if(!identificator){
                identificator =@"1";
            }
            NSDate *date = [[NSDate alloc]init];

            if([user isEqual:login]){
                user = @"you";
                delivered =@"yes";

            }
            else{
                delivered = @"no";
            }
            NSMutableDictionary *m = [[NSMutableDictionary alloc] init];

            NSInteger a = [[i elementForName:@"time"] stringValueAsNSInteger];
            date = [NSDate dateWithTimeIntervalSince1970:a];
            NSString * img = [[i elementForName:@"image"] stringValue];
            if( img ){
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"dd.MM.yyyy"];

                NSString *string = [format stringFromDate:date];
                NSURL *fullUrl = [NSURL URLWithString:[[[@"http://5.143.43.41/images/full/" stringByAppendingString:string] stringByAppendingString:@"/"] stringByAppendingString:img]];
               // NSData* data =[NSData dataWithContentsOfURL:url];

             //   UIImage *image = [UIImage imageWithData: data];
                NSURL *url = [NSURL URLWithString:[[[@"http://5.143.43.41/images/preview/" stringByAppendingString:string] stringByAppendingString:@"/"] stringByAppendingString:img]];
                 NSData* data =[NSData dataWithContentsOfURL:url];

                   UIImage *image = [UIImage imageWithData: data];

                if(url){
                    [m setObject:fullUrl forKey:@"url"];
                    [m setObject:image forKey:@"image"];
                }

            }
            if(text)
                [m setObject:text forKey:@"msg"];
            else
                [m setObject:@"" forKey:@"msg"];
            [m setObject:user forKey:@"sender"];
            [m setObject:date forKey:@"date"];
            [m setObject:identificator forKey:@"id"];
            [m setObject:delivered forKey:@"delivered"];

            [messages addObject:m];

        }

        [_messageDelegate newMessagesReceived:messages];

    }




    return YES;
}



- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    NSXMLElement* mes;

    if (!(mes = [message elementForName:@"received"])){
        NSString *msg = [[message elementForName:@"body"] stringValue];
        NSString *from = [[message elementForName:@"user"] stringValue];
        NSString *identificator = [[message elementForName:@"id"] stringValue];
        // UIImage * image  = [[message elementForName:@"img"]];

        NSString* delivered ;
        if(!identificator){
            identificator =@"0";
        }
        NSDate *date = [[NSDate alloc]init];

        if([from isEqual:login]){
            from = @"you";
            delivered =@"yes";

        }
        else{
            delivered = @"no";
        }

        NSInteger a = [[message elementForName:@"time"] stringValueAsNSInteger];
        date = [NSDate dateWithTimeIntervalSince1970:a];
        NSString * img = [[message elementForName:@"image"] stringValue];
        if( img ){
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"dd.MM.yyyy"];

            NSString *string = [format stringFromDate:date];
            NSURL *url = [NSURL URLWithString:[[[[@"http://5.143.17.232:5223/images/preview/" stringByAppendingString:string] stringByAppendingString:@"/"] stringByAppendingString:img] stringByAppendingString:@".png"]];
//            UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];

            [m setObject:url forKey:@"url"];

        }


        [m setObject:msg forKey:@"msg"];
        [m setObject:from forKey:@"sender"];
        [m setObject:@"0" forKey:@"id"];

    }
    else{
        NSString* s = [[mes attributeForName:@"id"] stringValue] ;
        [m setObject:@"all is ok" forKey:@"msg"];
        [m setObject:@"okMsg" forKey:@"sender"];
        [m setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"date"];
        [m setObject:s forKey:@"id"];
    }

    [_messageDelegate newMessageReceived:m animated:YES];



}


- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate: (NSXMLElement *)error;
{
    XMPPLogError(@"Did not authenticate");
    if( ![login  isEqual: @""]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Неправильно введено имя пользователя или пароль"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    UIStoryboard * Main= [UIStoryboard storyboardWithName:device bundle:nil];
    SMLoginView * loginView = [Main instantiateViewControllerWithIdentifier:@"login"] ;

    self.window.rootViewController = loginView;
    //    [self.window.rootViewController presentViewController:loginViewController animated:YES completion:nil];
}


- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags
{
    NSLog(@"didDetectAccidentalDisconnect:%u",connectionFlags);
    //chatViewController.waitingConnection.alpha = 1;

}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
    NSLog(@"shouldAttemptAutoReconnect:%u",reachabilityFlags);



    return YES;
}


- (void)xmppStreamDidRegister:(XMPPStream *)sender{


    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Registration with XMPP Successful!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [self.window.rootViewController presentViewController:loginViewController animated:YES completion:nil];
    //    [self.navigationController popToRootViewControllerAnimated:YES];

}



- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration with XMPP   Failed!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];

    NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];

    alert = [[UIAlertView alloc] initWithTitle:@"Registration with XMPP   Failed!" message:regError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

    if([errorCode isEqualToString:@"409"]){

        [alert setMessage:@"Username Already Exists!"];
    }
    if([errorCode isEqualToString:@"406"]){

        [alert setMessage:@"Bad login or password"];
    }
    UIStoryboard * Main= [UIStoryboard storyboardWithName:device bundle:nil];

    chatViewController = [Main instantiateViewControllerWithIdentifier:@"registration"] ;


    [UIView transitionFromView:self.window.rootViewController.view
                        toView:chatViewController.view
                      duration:0.65f
                       options:UIViewAnimationOptionTransitionCrossDissolve
     
                    completion:^(BOOL finished) {
                        self.window.rootViewController = chatViewController;
                    }];
    
    
    //
    //    UIStoryboard * Main= [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    SMLoginView * regView = [Main instantiateViewControllerWithIdentifier:@"registration"] ;
    //    //
    //    //    [self presentViewController:loginView animated:YES completion:nil];
    //    [self.navigationController pushViewController:regView animated:YES];
    
    
    [alert show];
    
}


@end
