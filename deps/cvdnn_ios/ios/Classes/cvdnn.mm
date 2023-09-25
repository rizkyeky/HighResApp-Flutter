//
//  OpenCV.m
//  HighRes
//
//  Created by Eky on 12/09/23.
//

#import "cvdnn.h"

@implementation CvdnnObjC {
  @protected
  cv::dnn::Net _net;
}

- (nullable instancetype)initWithModelPath:(NSString *)modelPath {
  self = [super init];
  if (self) {
    try {
      _net = cv::dnn::readNetFromONNX([modelPath UTF8String]);
    } catch (const std::exception& e) {
      NSLog(@"Failed to load the ONNX model.");
      return nil;	
    }
  }
  return self;
}

- (void)generateImageWithInputPath:(NSString *)inputPath outputPath:(NSString *)outputPath {

  // Check if the input file exists
  if (![[NSFileManager defaultManager] fileExistsAtPath:inputPath]) {
    NSLog(@"Input file does not exist.");
    return;
  }
    
  cv::Mat inputImage = cv::imread([inputPath UTF8String], cv::IMREAD_COLOR);

  // Check if the input image loaded successfully
  if (inputImage.empty()) {
    NSLog(@"Failed to load input image.");
    return;
  }
  
  int oriWidth = inputImage.size().width;
  int oriHeight = inputImage.size().height;
  
  cv::Mat blob = cv::dnn::blobFromImage(inputImage, 1.0/255, cv::Size(320, 320), cv::Scalar(), true);

  _net.setInput(blob);
  cv::Mat output = _net.forward();

  cv::Mat outputImage;
  cv::transposeND(output, {1, 2, 0}, outputImage);

  cv:: Mat uint8Image;
  outputImage.convertTo(uint8Image, CV_8UC1, 255);
  
  cv::Mat convertedImage(uint8Image.size().height, uint8Image.size().width, CV_8UC3);
  for (int row = 0; row < uint8Image.size().height; ++row) {
    for (int col = 0; col < uint8Image.size().width; ++col) {
      cv::Vec3b channels;
      for (int chan = 0; chan < 3; ++chan) {
        uint8_t value = uint8Image.at<uint8_t>(row, col, chan);
        channels[chan] = value;
      }
      convertedImage.at<cv::Vec3b>(row, col) = channels;
    }
  }
  
  cv::Mat bgrOutput;
  cv::cvtColor(convertedImage, bgrOutput, cv::COLOR_RGB2BGR);

  cv::Mat finalImageOutput;
  cv::resize(bgrOutput, finalImageOutput, cv::Size(oriWidth*4, oriHeight*4), cv::INTER_LINEAR_EXACT);
  
  if (!cv::imwrite([outputPath UTF8String], finalImageOutput)) {
    NSLog(@"Failed to save the output image.");
  }
}

@end
