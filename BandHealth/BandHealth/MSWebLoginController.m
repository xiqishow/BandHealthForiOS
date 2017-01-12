//
//  MSWebLoginController.m
//  BandHealth
//
//  Created by Coofeel on 15/11/30.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#import "MSWebLoginController.h"
#import "HttpTools.h"
#import "NSURL+Parameters.h"



@interface MSWebLoginController ()
{
    
    __weak IBOutlet UIWebView *loginWebView;
    __weak IBOutlet UIButton *btnClose;
}

@end

@implementation MSWebLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *url = [NSString stringWithFormat:MS_APP_LOGINURL,MS_CLIENTID,MS_SCOPE,MS_APP_RESULT_REDIRECT];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    ;
    [loginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    CALayer *btnCloseLayer = [btnClose layer];
    [btnCloseLayer setCornerRadius:btnClose.bounds.size.width/2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UIEvents

- (IBAction)didBtnCloseTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [KVNProgress showWithStatus:@"加载页面中..."];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [KVNProgress dismiss];
    NSURL *url = webView.request.URL;
    NSRange range = [url.absoluteString rangeOfString:MS_APP_RESULT_REDIRECT];
    if(range.location != NSNotFound && range.location == 0){
        NSString *code = [url parameterForKey:@"code"];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:MS_CLIENTID forKey:@"client_id"];
        [params setValue:MS_APPSECRET forKey:@"client_secret"];
        [params setValue:MS_APP_RESULT_REDIRECT forKey:@"redirect_uri"];
        [params setValue:code forKey:@"code"];
        [params setValue:@"authorization_code" forKey:@"grant_type"];
        
        __weak typeof(self) weakSelf = self;

        [KVNProgress showWithStatus:@"验证中..."];
        
        [HttpTools postToURL:MS_APP_TOKEN_URL withParams:params andUseID:NO withSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setValue:[responseObject valueForKey:@"access_token"] forKey:MS_APP_LOCAL_TOKEN];
            [userDefaults setValue:[responseObject valueForKey:@"refresh_token"] forKey:MS_APP_LOCAL_REFRESHTOKEN];
            [userDefaults synchronize];
            [KVNProgress dismiss];
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           
                [KVNProgress showErrorWithStatus:@"验证错误"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                });
            });
        }];
    }
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    __weak typeof (self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [KVNProgress showErrorWithStatus:@"网络连接失败"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        });
    });
    
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
