#import "OnlineGameViewController.h"
#import <SSZipArchive.h>
#import <MBProgressHUD.h>

@interface OnlineGameViewController () <WKNavigationDelegate, WKUIDelegate>

@property (strong, nonatomic) WKWebView * webView;

@property (nonatomic, copy) void (^progressUpdateBlock)(float progress);

@end

@implementation OnlineGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [WKWebView new];
    [_webView setNavigationDelegate:self];
    NSURL *url = [NSURL URLWithString:@"https://h5mota.com/"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:_webView];
    [_webView setUIDelegate:self];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.allowsBackForwardNavigationGestures = YES;
    _webView.inspectable = YES;
    
    [NSLayoutConstraint activateConstraints:@[
      [_webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
      [_webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
      [_webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
      [_webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
      [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(nonnull WKNavigationResponse *)navigationResponse decisionHandler:(nonnull void (^)(WKNavigationResponsePolicy))decisionHandler {
    if (navigationResponse.canShowMIMEType) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    } else {
        decisionHandler(WKNavigationResponsePolicyDownload);
    }
}

- (void)webView:(WKWebView *)webView navigationResponse:(WKNavigationResponse *)navigationResponse didBecomeDownload:(WKDownload *)download {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Downloading...";
    [hud showAnimated:TRUE];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self downloadGame:download.originalRequest.URL progress:^(float progress){
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.progress = progress;
            });
            } withCompletionBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }];
        
    });

    [download cancel:^(NSData* data){}];
}


- (void)downloadGame:(NSURL *)downloadUrl progress:(void (^)(float))progressUpdateBlock withCompletionBlock:(void (^)(void))completionBlock
{
    self.progressUpdateBlock = progressUpdateBlock;
    NSLog(@"Download start");
    NSString* dirName = [[downloadUrl lastPathComponent] stringByDeletingPathExtension];

    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:downloadUrl completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"download... %@", error);
        [self installZipGameAtPath:location.path gameDirName:dirName withCompletionBlock:completionBlock];
    }];

    [task.progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    
    [task resume];
}

- (void)installZipGameAtPath:(NSString *)path gameDirName:(NSString *)gameDirName withCompletionBlock:(void (^)(void))completionBlock
{
    NSString *destPath = [NSString stringWithFormat:@"%@/games/%@", NSHomeDirectory(), gameDirName];
    NSURL *destURL =[NSURL fileURLWithPath:destPath];

    NSError *error;
    [SSZipArchive unzipFileAtPath:path toDestination:destPath overwrite:YES password:nil error:&error];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:destPath error:nil];

    if (contents.count == 1) {
        NSURL *tempURL = [[destURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"temp"];
        [[NSFileManager defaultManager] moveItemAtURL:[destURL URLByAppendingPathComponent:contents.firstObject] toURL:tempURL error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:destURL error:nil];
        [[NSFileManager defaultManager] moveItemAtURL:tempURL toURL:destURL error:nil];
    }
    completionBlock();
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        if (self.progressUpdateBlock) {
            self.progressUpdateBlock(((NSProgress *)object).fractionCompleted);
        }
    }
}

@end
