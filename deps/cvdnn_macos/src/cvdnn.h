#ifndef OPENCV_H
#define OPENCV_H

#define EXPORT_C extern "C"

void initNetFromOnnx(char* modelPath);
void generateImage(char* imagePath, char* outputPath);
void generateWithOnnxRuntime(char* modelPath, char* imagePath, char* outputPath);

#endif // OPENCV_H
