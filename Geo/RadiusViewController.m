//
//  RadiusViewController.m
//  Geo
//
//  Created by Данил on 22.03.15.
//  Copyright (c) 2015 &#1044;&#1072;&#1085;&#1080;&#1083;. All rights reserved.
//

#import "RadiusViewController.h"
#include "SMChatViewController.h"
@interface RadiusViewController ()
@end

@implementation RadiusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)okButton:(id)sender {
}

- (IBAction)changeRadius:(id)sender {
        self->radius1 = self.slider.value * 1000;
        self.viewRadius.text = [NSString stringWithFormat:@"%f",self->radius1 ];

}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    SMChatViewController* vs = [segue destinationViewController];
    [vs radiusChange:radius1];
}

@end
