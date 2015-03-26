//
//  WebViewController.h
//  Geo
//
//  Created by Данил on 22.03.15.
//  Copyright (c) 2015 &#1044;&#1072;&#1085;&#1080;&#1083;. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController{
    UIActivityIndicatorView *loadingIndicator;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (assign) float latitude;
@property (assign)  float longtitude;

@end
