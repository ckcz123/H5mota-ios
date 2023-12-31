#import <Foundation/Foundation.h>
#import <UIImageView+YYWebImage.h>
#import "GameCellViewController.h"
#import <Masonry.h>

@interface GameCellViewController ()

@property (nonatomic, strong) UIImageView *thumbImageView;
@property (nonatomic, strong) UILabel *gameTitle;

@end

@implementation GameCellViewController

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}


- (void)setupUI
{
    [self.contentView addSubview:self.thumbImageView];
    [self.contentView addSubview:self.gameTitle];
    
    [self.thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.leading.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView);
        
        make.height.equalTo(@(128));
    }];
    
    [self.gameTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.thumbImageView.mas_bottom).offset(10);
        make.centerX.equalTo(self.thumbImageView);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    
}

- (UIImageView *)thumbImageView
{
    if (!_thumbImageView) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.clipsToBounds = YES;
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _thumbImageView;
}

- (UILabel *)gameTitle
{
    if (!_gameTitle) {
        _gameTitle = [[UILabel alloc] init];
        _gameTitle.font = [UIFont systemFontOfSize:13];
    }
    return _gameTitle;
}

- (void)setupWithModel:(GameModel *)model
{
    [self.thumbImageView yy_setImageWithURL:model.imageURL placeholder:[UIImage imageNamed:@"placeholder"] options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    self.gameTitle.text = model.titleName;
}

@end
