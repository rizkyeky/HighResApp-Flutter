#ifndef OPENCV_H
#define OPENCV_H

#define EXPORT_C extern "C"

EXPORT_C void initNetFromOnnx(char* modelPath);
EXPORT_C void generateImage(char* imagePath, char* outputPath);

#endif // OPENCV_H
