
#ifdef __cplusplus
#undef NO
#import <opencv2/core.hpp>
#import <opencv2/dnn.hpp>
#import <opencv2/imgcodecs.hpp>
#import <opencv2/imgproc.hpp>
#endif
#import <Foundation/Foundation.h>

@interface CvdnnObjC : NSObject;

- (instancetype)initWithModelPath:(NSString *)modelPath;
- (void)generateImageWithInputPath:(NSString *)inputPath outputPath:(NSString *)outputPath;

@end
