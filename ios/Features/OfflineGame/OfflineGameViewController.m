#import "OfflineGameViewController.h"
#import "GameModel.h"
#import <SSZipArchive.h>
#import <WebKit/WebKit.h>

@interface OfflineGameViewController () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, copy) void (^progressUpdateBlock)(float progress);
@property (strong, nonatomic) WKWebView * webView;

@end

@implementation OfflineGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[WKWebView alloc] init];
    [_webView.configuration.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
    [_webView setNavigationDelegate:self];
    [_webView.configuration setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
    _webView.configuration.allowsInlineMediaPlayback = YES;
    _webView.configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;

    [_webView loadRequest:[NSURLRequest requestWithURL:self.url]];
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

- (void) loadRequest {
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/games/Lost", NSHomeDirectory()]];
    [_webView loadRequest:[NSURLRequest requestWithURL:[url URLByAppendingPathComponent:@"index.html"]]];
}

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
      [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - Action Handlers

- (void)downloadGame:(NSURL *)downloadUrl progress:(void (^)(float))progressUpdateBlock withCompletionBlock:(void (^)(void))completionBlock
{
    self.progressUpdateBlock = progressUpdateBlock;
    NSLog(@"Download start");
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:downloadUrl completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"download... %@", error);
        [self installZipGameAtPath:location.path withCompletionBlock:completionBlock];
    }];

    [task.progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    
    [task resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        if (self.progressUpdateBlock) {
            self.progressUpdateBlock(((NSProgress *)object).fractionCompleted);
        }
    }
}

- (void)installZipGameAtPath:(NSString *)path withCompletionBlock:(void (^)(void))completionBlock
{
    NSString *destPath = [NSString stringWithFormat:@"%@/games", NSHomeDirectory()];
    NSString *gameInfoPath = [NSString stringWithFormat:@"%@/project/data.js", destPath];
    NSError *error;
    [SSZipArchive unzipFileAtPath:path toDestination:destPath overwrite:YES password:nil error:&error];
        
}

@end
