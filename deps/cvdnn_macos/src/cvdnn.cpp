#include <opencv2/core.hpp>
#include <opencv2/dnn.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <chrono>
#include <iostream>

#include "cvdnn.hpp"

cv::dnn::Net net;

EXPORT_C void initNetFromOnnx(char* modelPath) {
  net = cv::dnn::readNetFromONNX(modelPath);
}

EXPORT_C void generateImage(char* imagePath, char* outputPath) {

  auto start = std::chrono::high_resolution_clock::now();
  
  cv::Mat inputImage = cv::imread(imagePath, cv::IMREAD_COLOR);

  int oriWidth = inputImage.size().width;
  int oriHeight = inputImage.size().height;

  cv::Mat blob = cv::dnn::blobFromImage(inputImage, 1.0/255, cv::Size(320,320), cv::Scalar(), true);

  net.setInput(blob);
  cv::Mat output = net.forward();

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

  cv::Mat finalImageOuput;
  cv::resize(bgrOutput, finalImageOuput, cv::Size(oriWidth*4, oriHeight*4), cv::INTER_LINEAR_EXACT);

  auto end = std::chrono::high_resolution_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
  std::cout << "Model forward time: " << duration.count() << "ms" << std::endl;

  cv::imwrite(outputPath, finalImageOuput);
}