#import <Foundation/Foundation.h>

@interface GameModel : NSObject

@property (nonatomic, strong) NSString *gameID;
@property (nonatomic, strong) NSString *titleName;
@property (nonatomic, strong) NSURL *imageURL;

+ (NSArray*) modelsFromFilePath:(NSString *)path;

@end
