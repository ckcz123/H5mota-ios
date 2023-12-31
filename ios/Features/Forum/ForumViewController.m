#import "ForumViewController.h"
#import <WebKit/WebKit.h>
#import "../OfflineGame/GameModel.h"
#import <SSZipArchive.h>


@interface ForumViewController () <WKNavigationDelegate, WKUIDelegate>

@property (strong, nonatomic) WKWebView * webView;
@property (nonatomic, copy) void (^progressUpdateBlock)(float progress);

@end

@implementation ForumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [WKWebView new];
    [_webView setNavigationDelegate:self];
    NSURL *url = [NSURL URLWithString:@"https://h5mota.com/bbs"];
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

@end
