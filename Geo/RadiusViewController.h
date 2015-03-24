//
//  RadiusViewController.h
//  Geo
//
//  Created by Данил on 22.03.15.
//  Copyright (c) 2015 &#1044;&#1072;&#1085;&#1080;&#1083;. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadiusViewController : UIViewController{
    float radius1;
}

- (IBAction)okButton:(id)sender;
- (IBAction)changeRadius:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UILabel *viewRadius;

@end
