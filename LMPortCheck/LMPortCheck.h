#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LMPortCheckCompletionHandler)(BOOL success, NSError* _Nullable error);

@interface LMPortCheck : NSObject

+ (void)connectToHost:(NSString*)host port:(uint16_t)port timeout:(NSTimeInterval)timeout completionHandler:(LMPortCheckCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
