//
//  WebViewController.m
//  Geo
//
//  Created by Данил on 22.03.15.
//  Copyright (c) 2015 &#1044;&#1072;&#1085;&#1080;&#1083;. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"Карта с сообщениями";

    NSString *fullURL =@"http://5.143.43.41:80/?lon=" ;

    NSString* lat =[[[[NSNumber numberWithFloat:self.longtitude] stringValue] stringByAppendingString:@"&lat="] stringByAppendingString:[[NSNumber numberWithFloat:self.latitude] stringValue]];

    _webView.delegate = self;
   fullURL = [fullURL stringByAppendingString:lat];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [_webView loadRequest:requestObj];

    loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(145, 190, 20,20)]; [loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray]; [loadingIndicator setHidesWhenStopped:YES];
    [_webView addSubview:loadingIndicator];
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
[loadingIndicator startAnimating];
}



-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [loadingIndicator stopAnimating];
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
