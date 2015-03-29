//
//  SMChatViewController.h
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMMessageDelegate.h"   
#import <CoreLocation/CoreLocation.h>
#import "DemoModelData.h"
#import "NSUserDefaults+DemoSettings.h"
#import "RadiusViewController.h"
#import "JSQMessages.h"
#import "WebViewController.h"

#import "JTSImageViewController.h"
#import "JTSImageInfo.h"

@class SMChatViewController;

@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(SMChatViewController *)vc;

@end

@interface SMChatViewController : JSQMessagesViewController<SMMessageDelegate, CLLocationManagerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDelegate>{

    UITextField     *messageField;
    NSString        *chatWithUser;
    UITableView     *tView;
    NSMutableArray  *messages;
    NSString        *GeoLatitude;
    NSString        *GeoLongtitude;
    float           Radius;
    bool            firstUpdateLocation;
    NSMutableArray *turnSockets;
    NSInteger identifier;
    

    NSInteger timeInterval;



}



@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;

@property (strong, nonatomic) DemoModelData *demoData;



- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

- (void)closePressed:(UIBarButtonItem *)sender;


//
//@property (weak, nonatomic) IBOutlet UILabel *waitingConnection;

@property (nonatomic,retain) NSString *chatWithUser;
@property (nonatomic,retain) NSString *GeoLatitude;
@property (nonatomic,retain) NSString *GeoLongtitude;
@property (strong, nonatomic) CLLocation *currentLocation;
//@property (weak, nonatomic) IBOutlet UISlider *slider;
//@property (weak, nonatomic) IBOutlet UILabel *radius1;

//@property (nonatomic, retain) IBOutlet UIWindow *window;





- (id) initWithUser:(NSString *) userName;
//- (IBAction) sendMessage;
-(void) runTimer:(NSInteger) time;
- (IBAction) closeChat;
- (void)radiusChange:(float)radius;
- (IBAction)openCamera: (id)sender;

@end