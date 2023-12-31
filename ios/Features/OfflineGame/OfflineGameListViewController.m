#import <Foundation/Foundation.h>
#import <Masonry.h>
#include "OfflineGameListViewController.h"
#include "GameModel.h"
#include "GameCellViewController.h"
#include "OfflineGameViewController.h"
#import <WebKit/WebKit.h>

@interface OfflineGameListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) NSArray *gameModels;
@property (strong, nonatomic) WKWebView * webView;

@end

@implementation OfflineGameListViewController

- (void)viewDidLoad {
    self.navigationController.delegate = self;

    [super viewDidLoad];
    [self initData];
    [self initUI];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self initData];
    [self.collectionView reloadData];
    _emptyLabel.hidden = self.gameModels.count > 0;
}

-(void)initData {
    self.gameModels = [GameModel modelsFromFilePath:[NSString stringWithFormat:@"%@/games", NSHomeDirectory()]];
}

-(void)initUI {
    NSLog(@"init ui");
    self.title = @"All Offline Games";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.emptyLabel];
    
    [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.leading.greaterThanOrEqualTo(self.view).offset(10);
        make.trailing.lessThanOrEqualTo(self.view).offset(-10);
    }];
}


- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(150, 170);
        layout.minimumInteritemSpacing=10;
        layout.minimumLineSpacing=20;
        layout.sectionInset=UIEdgeInsetsMake(20, 30, 20, 30);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[GameCellViewController class] forCellWithReuseIdentifier:NSStringFromClass([GameCellViewController class])];

        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (UILabel *)emptyLabel
{
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.hidden = self.gameModels.count > 0;
        _emptyLabel.font = [UIFont systemFontOfSize:14];
        _emptyLabel.text = @"No Offline Games Available.";
    }
    return _emptyLabel;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    OfflineGameViewController *game = [self.storyboard instantiateViewControllerWithIdentifier:@"offlineGame"];
    GameModel *model = [self.gameModels objectAtIndex:indexPath.item];
    game.url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/games/%@/index.html", NSHomeDirectory(), model.gameID]];

    [self.navigationController pushViewController:game animated:YES];
}


# pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.gameModels.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < self.gameModels.count) {
        // Game item
        GameCellViewController *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GameCellViewController class]) forIndexPath:indexPath];
        [cell setupWithModel:self.gameModels[indexPath.row]];
        return cell;
    }
    return nil;
}

@end
