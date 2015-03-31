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
-(void)viewWillAppear:(BOOL)animated {
    self.slider.value = [self trueRadius:_radius1];
    self.viewRadius.text = [NSString stringWithFormat:@"%f",self->_radius1 ];
    self.navigationItem.title=@"Изменить радиус";

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
    self->_radius1 =[self trueRadius: self.slider.value];
        self.viewRadius.text = [NSString stringWithFormat:@"%f",self->_radius1 ];
}

-(NSInteger)trueRadius:(float) value{

    if(value < 0.01)
        return value*10 + 0.1;

    if(value < 0.1)
        return value*100 + 0.1;
    if( value < 1)
        return value*10000 + 0.1;



    if(value > 100)
        return value/100000;
    if( value > 1)
        return value/1000;
    else
        return 0;


}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    SMChatViewController* vs = [segue destinationViewController];
    [vs radiusChange:_radius1];

    [vs runTimer:_time];
    
}

- (IBAction)changeTime:(id)sender {
//    self->_time = self.slider1.value * 100000 + 0.1;
//    self.timer.text = [NSString stringWithFormat:@"%ld",(long)self->_time ];


}
@end
