//
//  MapBoxViewController.h
//  Geo
//
//  Created by Данил on 25.03.15.
//  Copyright (c) 2015 &#1044;&#1072;&#1085;&#1080;&#1083;. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapBoxViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *view;
@property (assign) float latitude;
@property (assign)  float longtitude;

@end
