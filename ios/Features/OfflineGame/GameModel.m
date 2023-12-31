#import "GameModel.h"

@interface GameModel ()

@end

@implementation GameModel

+ (NSArray*) modelsFromFilePath:(NSString *)path {
    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray* array = [NSMutableArray new];
    for(NSString* path in paths) {
        [array addObject:[self modelFromFilePath:[NSString stringWithFormat:@"%@/games/%@/project", NSHomeDirectory(), path]]];
    }
    return array;
}

+ (instancetype)modelFromFilePath:(NSString *)path {
    NSDictionary *dict = [GameModel parseJSONFromPath:[NSString stringWithFormat:@"%@/data.js", path]];
    if(dict == nil) return nil;
    
    GameModel *model = [GameModel new];
    NSDictionary *firstData = dict[@"firstData"];
    model.gameID = firstData[@"name"];
    model.titleName = firstData[@"title"];
    model.imageURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/images/bg.jpg", path]];
    return model;
}

+ (NSDictionary*) parseJSONFromPath:(NSString *)path {
    NSFileManager *fileManager=[NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:path])
    {
        NSError *error= NULL;
        
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        NSArray *arr = [content componentsSeparatedByString:@"\n"];
        arr = [arr subarrayWithRange:NSMakeRange(1, arr.count-1)];
        NSString * jsonString = [[arr valueForKey:@"description"] componentsJoinedByString:@""];

        id jsonData = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        if (error == NULL)
        {
            return jsonData;
        }
    }
    return nil;
}

@end
