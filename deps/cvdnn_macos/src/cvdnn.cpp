#include <chrono>
#include <iostream>
#include <algorithm>

#include <opencv2/core.hpp>
#include <opencv2/dnn.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <onnxruntime/onnxruntime_cxx_api.h>

#include <cstdint>

#include "cvdnn.h"

cv::dnn::Net net;

void initNetFromOnnx(char* modelPath) {
  std::cout << "init model" << std::endl;
  net = cv::dnn::readNetFromONNX(modelPath);
  std::cout << "finish init model" << std::endl;
}

void generateImage(char* imagePath, char* outputPath) {

  auto start = std::chrono::high_resolution_clock::now();
  
  cv::Mat inputImage = cv::imread(imagePath, cv::IMREAD_COLOR);

  int oriWidth = inputImage.size().width;
  int oriHeight = inputImage.size().height;

  cv::Mat blob = cv::dnn::blobFromImage(inputImage, 1.0/255, cv::Size(512,512), cv::Scalar(), true);

  std::cout << "start forward" << std::endl;
  net.setInput(blob);
  cv::Mat output = net.forward();
  std::cout << "finish forward" << std::endl;

  cv::Mat outputImage;
  cv::transposeND(output, {1, 2, 0}, outputImage);

  cv::Mat uint8Image;
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

void generateWithOnnxRuntime(char* modelPath, char* imagePath, char* outputPath) {

  Ort::Env env(ORT_LOGGING_LEVEL_WARNING, "onnxdnn");

  Ort::SessionOptions sessionOptions;
  sessionOptions.SetIntraOpNumThreads(8);
  Ort::Session session(env, ORT_TSTR(modelPath), sessionOptions);

  cv::Mat inputImage = cv::imread(imagePath, cv::IMREAD_COLOR);

  int oriWidth = inputImage.size().width;
  int oriHeight = inputImage.size().height;

  cv::Mat blob = cv::dnn::blobFromImage(
    inputImage, 
    1.0/255, 
    cv::Size(512,512), 
    cv::Scalar(),
    true
  );
  std::cout << blob.size() << std::endl;
  std::cout << blob.rows << std::endl;
  std::cout << blob.cols << std::endl;
  std::cout << blob.channels() << std::endl;
  std::cout << blob.dims << std::endl;
  std::cout << blob.depth() << std::endl;
  std::cout << blob.total() << std::endl;
  
  cv::Mat resizedImage;
  cv::resize(inputImage, resizedImage, cv::Size(512,512));
  cv::Mat floatImage;
  resizedImage.convertTo(floatImage, CV_32FC3, 1.0/255.0);
  // floatImage = floatImage.reshape(1,1);

  std::cout << floatImage.size() << std::endl;
  std::cout << floatImage.rows << std::endl;
  std::cout << floatImage.cols << std::endl;
  std::cout << floatImage.channels() << std::endl;
  std::cout << floatImage.dims << std::endl;
  std::cout << floatImage.depth() << std::endl;
  std::cout << floatImage.total() << std::endl;

  Ort::MemoryInfo memoryInfo = Ort::MemoryInfo::CreateCpu(
    OrtArenaAllocator, 
    OrtMemTypeDefault
  );
  std::vector<int64_t> inputShape = {1, 3, 512, 512};
  
  Ort::Value inputTensor = Ort::Value::CreateTensor<float>(memoryInfo, 
    (float*) blob.data, 
    3*512*512, 
    inputShape.data(), 
    inputShape.size()
  );

  std::vector<const char*> inputNames = {"input"};
  std::vector<const char*> outputNames = {"output"};

  std::cout << "run" << std::endl;
  std::vector<Ort::Value> outputTensor = session.Run(
    Ort::RunOptions{}, 
    inputNames.data(), 
    &inputTensor, 
    1,
    outputNames.data(), 
    outputNames.size()
  );
  std::cout << "finish" << std::endl;
  
  Ort::TensorTypeAndShapeInfo outputInfo = outputTensor[0].GetTensorTypeAndShapeInfo();
  int batchSize = outputInfo.GetShape()[0]; // 1
  int channels = outputInfo.GetShape()[1]; // 3
  int height = outputInfo.GetShape()[2]; // 2048
  int width = outputInfo.GetShape()[3]; // 2048
  
  const float* outputData = outputTensor[0].GetTensorMutableData<float>();
  
  cv::Mat outputImage(height, width, CV_32FC(channels), const_cast<float*>(outputData));
  
  // cv::Mat outputMat(height, width, CV_32FC(channels));
  // memcpy(outputMat.data, outputData, channels * height * width);

  // std::cout << "convert f32" << std::endl;
  // std::cout << outputImage.size() << std::endl;
  // std::cout << outputImage.at<cv::Vec3f>(0, 0) << std::endl;

  // cv::Mat transposedImage;
  // cv::transposeND(outputImage, {1, 2, 0}, transposedImage);
  // std::cout << transposedImage.size() << std::endl;
  // std::cout << "transpose" << std::endl;

  cv::Mat uint8Image;
  outputImage.convertTo(uint8Image, CV_8UC3, 255);
  // std::cout << "convert uint8" << std::endl;
  // std::cout << uint8Image.size() << std::endl;
  // std::cout << uint8Image.at<cv::Vec3b>(0, 0) << std::endl;

  // cv::Mat convertedImage(outputImage.size().height, outputImage.size().width, CV_8UC3);
  // for (int row = 0; row < outputImage.size().height; ++row) {
  //   for (int col = 0; col < outputImage.size().width; ++col) {
  //     // std::cout << "row:" << row << ",col:" << col << ",value:" << outputImage.at<cv::Vec3b>(row, col) << std::endl;
  //     cv::Vec3b channels;
  //     // for (int chan = 0; chan < 3; ++chan) {
  //       cv::Vec3b vec = outputImage.at<cv::Vec3b>(row, col);
  //       channels = vec;
  //       // float value0 = outputImage.at<float>(row, col, 1);
  //       // channels[0] = value0;
  //       // std::cout << "chan:" << 0 << ",value0:" << (int) value0 << std::endl;

  //       // float value1 = outputImage.at<float>(row, col, 1);
  //       // channels[1] = value1;
  //       // std::cout << "chan:" << 1 << ",value1:" << (int) value1 << std::endl;

  //       // float value2 = outputImage.at<float>(row, col, 1);
  //       // channels[2] = value2;
  //       // std::cout << "chan:" << 2 << ",value2:" << (int) value2 << std::endl;
  //     // }
  //     // std::cout << "channels:" << channels << std::endl;
  //     convertedImage.at<cv::Vec3b>(row, col) = channels;
  //   }
  // }
  // std::cout << "convert uint8" << std::endl;

  cv::Mat bgrOutput;
  cv::cvtColor(uint8Image, bgrOutput, cv::COLOR_RGB2BGR);

  cv::Mat finalImageOuput;
  cv::resize(bgrOutput, finalImageOuput, cv::Size(oriWidth*4, oriHeight*4), cv::INTER_LINEAR_EXACT);

  // cv::imwrite(outputPath, uint8Image);

  // Create a window to display the image
  cv::namedWindow("Display Window", cv::WINDOW_NORMAL); // You can choose different window flags

  // Show the image in the window
  cv::imshow("Display Window", finalImageOuput);

  // Wait for a key press and close the window when a key is pressed
  cv::waitKey(0);

  // Close the display window
  cv::destroyWindow("Display Window");
}

int main(int argc, char* argv[]) {
  // initNetFromOnnx(argv[1]);
  // generateImage(argv[2], argv[3]);
  generateWithOnnxRuntime(argv[1], argv[2], argv[3]);
  return 0;
}