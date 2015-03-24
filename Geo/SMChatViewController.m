//
//  SMChatViewController.m
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "SMChatViewController.h"
#import "AppDelegate.h"
#import "SMLoginView.h"
#import "TURNSocket.h"


@implementation SMChatViewController{

    CLLocationManager *locationManager;

}

@synthesize  chatWithUser, GeoLength,GeoLtitude;



- (void)viewDidLoad {

    [super viewDidLoad];
    messages = [[NSMutableArray alloc ] init];

    self.title = @"JSQMessages";

    /**
     *  You MUST set your senderId and display name
     */
    self.senderId = @"you";
    self.senderDisplayName = kJSQDemoAvatarDisplayNameSquires;
    if(Radius == 0)
        Radius = 500;

    /**
     *  Load up our fake data for the demo
     */
    self.demoData = [[DemoModelData alloc] init];


    /**
     *  You can set custom avatar sizes
     */
    if (![NSUserDefaults incomingAvatarSetting]) {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    }

    if (![NSUserDefaults outgoingAvatarSetting]) {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    }

    self.showLoadEarlierMessagesHeader = YES;

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];


    XMPPJID *jid = [XMPPJID jidWithString:[[self appDelegate] login ]];

    AppDelegate *del = [self appDelegate];
    del._messageDelegate = self;
    //  TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] toJID:jid];
    //  [turnSockets addObject:turnSocket];
    //  [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];


    //  GeoLocation

    self->locationManager = [[CLLocationManager alloc] init];
    self->locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self->locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self->locationManager requestWhenInUseAuthorization];
    }
    [self->locationManager startUpdatingLocation];

    GeoLtitude = [NSString stringWithFormat:@"%.8f", 43.0288];
    GeoLength = [NSString stringWithFormat:@"%.8f", 131.9013];

//    [NSTimer scheduledTimerWithTimeInterval:3
//                                     target:self
//                                   selector:@selector(sendQuery)
//                                   userInfo:nil
//                                    repeats:YES];
    firstUpdateLocation = true;
    [self sendQuery];
}


- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket {

    NSLog(@"TURN Connection succeeded!");
    NSLog(@"You now have a socket that you can use to send/receive data to/from the other person.");

    [turnSockets removeObject:sender];
}

- (void)turnSocketDidFail:(TURNSocket *)sender {

    NSLog(@"TURN Connection failed!");
    [turnSockets removeObject:sender];

}




#pragma mark - CLLocationManagerDelegate



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //  [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{

    CLLocation *currentLocation = newLocation;

    if (currentLocation != nil) {
        GeoLtitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        GeoLength = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }

    if (firstUpdateLocation){
        [self sendQuery];
        firstUpdateLocation = false;
    }


}


- (void)stopUpdatingLocationWithMessage:(NSString *)state {

    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;


}


#pragma mark -
#pragma mark Actions

- (IBAction) closeChat {


    UIStoryboard * Main= [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SMLoginView * loginView = [Main instantiateViewControllerWithIdentifier:@"login"] ;

    [self presentViewController:loginView animated:YES completion:nil];

}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo
                                                                                          target:self
                                                                                          action:@selector(closeChat)];


    UIBarButtonItem* radiusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:                      UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(goToRadius)];


    UIBarButtonItem* WebButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                  UIBarButtonSystemItemSearch
                                                                               target:self
                                                                               action:@selector(goToWebMap)];

    self.navigationItem.rightBarButtonItems=[[NSArray alloc] initWithObjects:radiusButton,WebButton, nil];

}


-(void) goToRadius{


    RadiusViewController* radiusView = [self.storyboard instantiateViewControllerWithIdentifier:@"radius"];
    [self.navigationController pushViewController:radiusView animated:YES ];
}

-(void) goToWebMap{


    WebViewController * webView = [self.storyboard instantiateViewControllerWithIdentifier:@"web"];
    [self.navigationController pushViewController:webView animated:YES ];
}

- (void)newMessageReceived:(NSMutableArray *)messageContent animated:(BOOL)animated {

    NSString *msg = [messageContent valueForKey:@"msg"];
    NSString *sender = [messageContent valueForKey:@"sender"];
    NSDate* date = [messageContent valueForKey:@"date"];

    JSQMessage *m = [[JSQMessage alloc] initWithSenderId:sender
                                       senderDisplayName:sender
                                                    date:date
                                                    text:msg];
    if([sender  isEqual:@"you"]){
        m.delivered = YES;
    }

    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    [self.demoData.messages addObject:m];
    [self finishReceivingMessageAnimated:animated];

    //
    //    if (newMessage.isMediaMessage) {
    //        /**
    //         *  Simulate "downloading" media
    //         */
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            /**
    //             *  Media is "finished downloading", re-display visible cells
    //             *
    //             *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
    //             *
    //             *  Reload the specific item, or simply call `reloadData`
    //             */
    //
    //            if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
    //                ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
    //                [self.collectionView reloadData];
    //            }
    //            else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
    //                [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
    //                    [self.collectionView reloadData];
    //                }];
    //            }
    //            else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
    //                ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
    //                ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
    //                [self.collectionView reloadData];
    //            }
    //            else {
    //                NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
    //            }
    //
    //        });
    //    }




}


- (void)newMessagesReceived:(NSMutableArray *)messagesRecv {

    [messages removeAllObjects];
    for(int i = messagesRecv.count - 1  ; i >= 0 ; i--){

        [self newMessageReceived:[messagesRecv objectAtIndex:i] animated:NO];
    }



}





-(void) sendImage: (UIImage*) imagePic{

    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];

    //        [body setStringValue:messageStr];


    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];

    [message addAttributeWithName:@"type"stringValue:@"chat"];

    [message addAttributeWithName:@"to"stringValue:nil];
    [message addAttributeWithName:@"latitude" stringValue:GeoLtitude];
    [message addAttributeWithName:@"length" stringValue:GeoLength];


    [message addChild:body];

    if([imagePic isKindOfClass:[UIImage class]])

    {

        NSData *dataPic =  UIImagePNGRepresentation(imagePic);

        NSXMLElement *photo = [NSXMLElement elementWithName:@"PHOTO"];

        NSXMLElement *binval = [NSXMLElement elementWithName:@"BINVAL"];

        [photo addChild:binval];

        NSString *base64String = [dataPic base64EncodedStringWithOptions:0];

        [binval setStringValue:base64String];

        [message addChild:photo];

    }

    //        [self.xmppStream sendElement:message];
    //
    //    }
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:imagePic];
    JSQMessage *m = [[JSQMessage alloc] initWithSenderId:self.senderId
                                       senderDisplayName:self.senderId
                                                    date:[NSDate dateWithTimeIntervalSinceNow:0]
                                                   media:photoItem];

    [self.demoData.messages addObject:m];

    [self finishReceivingMessageAnimated:YES];



}


- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{


    identifier++;
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:text];
    DDXMLElement *geo = [DDXMLElement elementWithName:@"geoloc" xmlns:@"http://jabber.org/protocol/geoloc"];


    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];

    [message addAttributeWithName:@"id" intValue:identifier];

    NSXMLElement * latitude = [NSXMLElement elementWithName:@"lat" stringValue:GeoLtitude];
    NSXMLElement * longitude = [NSXMLElement elementWithName:@"lon" stringValue:GeoLength];
    NSXMLElement * request = [NSXMLElement elementWithName:@"request" stringValue:@"urn:xmpp:receipts"];

    [geo addChild:latitude];
    [geo addChild:longitude];
    [message addChild:body];
    [message addChild:geo];
    [message addChild:request];

    [self.xmppStream sendElement:message];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];

    JSQMessage *m = [[JSQMessage alloc] initWithSenderId:senderId
                                       senderDisplayName:senderId
                                                    date:date
                                                    text:text];
    m.delivered = YES;

    [self.demoData.messages addObject:m];

    [self finishSendingMessageAnimated:YES];





}

-(void) sendQuery{
    XMPPIQ *iq = [[XMPPIQ alloc] initWithType:@"get"];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query" xmlns:@"geo:list:messages"];
    NSXMLElement * latitude = [NSXMLElement elementWithName:@"lat" stringValue:GeoLtitude];
    NSXMLElement * longitude = [NSXMLElement elementWithName:@"lon" stringValue:GeoLength];
    NSXMLElement * radius = [NSXMLElement elementWithName:@"radius" stringValue:[NSString stringWithFormat:@"%.20lf", Radius ] ];
    NSXMLElement * number = [NSXMLElement elementWithName:@"number" stringValue:@"30"];

    DDXMLElement *geo = [DDXMLElement elementWithName:@"geoloc"];
    [geo addChild:latitude];
    [geo addChild:longitude];
    [query addChild:geo];
    [query addChild:radius];
    [query addChild:number];
    [iq addChild:query];


    [[[self appDelegate] xmppStream] sendElement:iq];
}
- (void)radiusChange:(float)radius{
    Radius = radius;
    [self sendQuery];
}

#pragma mark - Keyboard events


#pragma mark Chat delegates

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}




- (NSString *) getCurrentTime {

    NSDate *nowUTC = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:nowUTC];

}
#pragma mark - Send image method


- (void)didPressAccessoryButton:(UIButton *)sender{

    NSString *actionSheetTitle = @"Выбор камеры"; //Action Sheet Title
    NSString *other1 = @"Сфотографировать";
    NSString *other2 = @"Выбрать из галлереи";
    NSString *cancelTitle = @"Отмена";

    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:other1, other2, nil];

    [actionSheet showInView:self.view];



}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];





    if ([buttonTitle isEqualToString:@"Сфотографировать"]) {
        [self takePhoto];
    }
    if ([buttonTitle isEqualToString:@"Выбрать из галлереи"]) {
        [self selectPhoto];
    }

}

- (void)takePhoto {

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil
                                    ];

        [myAlertView show];
        [self selectPhoto];

    }
    else{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;

        [self presentViewController:picker animated:YES completion:NULL];
    }


}

- (void)selectPhoto {

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:picker animated:YES completion:NULL];


}





#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];

    [self sendImage:chosenImage];

    [picker dismissViewControllerAnimated:YES completion:NULL];



}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:NULL];

}


- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.demoData.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */

    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];

    if ([message.senderId isEqualToString:self.senderId]) {
        return self.demoData.outgoingBubbleImageData;
    }

    return self.demoData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */

    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];

    if ([message.senderId isEqualToString:self.senderId]) {
        if (![NSUserDefaults outgoingAvatarSetting]) {
            return nil;
        }
    }
    else {
        if (![NSUserDefaults incomingAvatarSetting]) {
            return nil;
        }
    }

    if(message.senderId == self.senderId)
        return [self.demoData.avatars objectForKey:kJSQDemoAvatarIdJobs];
    else
        return [self.demoData.avatars objectForKey:kJSQDemoAvatarIdWoz];

}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }

    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];

    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }

    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }

    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.demoData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */

    JSQMessage *msg = [self.demoData.messages objectAtIndex:indexPath.item];

    if (!msg.isMediaMessage) {

        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }

        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }

    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */

    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }

    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }

    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }

    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

@end