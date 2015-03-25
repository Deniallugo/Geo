//
//  MapBoxViewController.m
//  Geo
//
//  Created by Данил on 25.03.15.
//  Copyright (c) 2015 &#1044;&#1072;&#1085;&#1080;&#1083;. All rights reserved.
//

#import "MapBoxViewController.h"
#import "Mapbox.h"

@interface MapBoxViewController ()

@end

@implementation MapBoxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[RMConfiguration sharedInstance] setAccessToken:@"sk.eyJ1IjoiZGVuaWxhbGx1Z28iLCJhIjoiaUJPUFpHTSJ9.7-cpuri25os9kmKn2RiI2Q"];

    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"denilallugo.44f3c83b"];

    RMMapView *mapView = [[RMMapView alloc] initWithFrame:self.view.bounds
                                            andTilesource:tileSource];
    // set zoom
    mapView.zoom = 15;

    // set coordinates
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.longtitude,self.latitude);

    // center the map to the coordinates
    mapView.centerCoordinate = center;
    
    [self.view addSubview:mapView];
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

@end
