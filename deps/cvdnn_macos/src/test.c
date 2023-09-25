#include "cvdnn.hpp"

int main(int argc, char* argv[]) {
  initNetFromOnnx(argv[1]);
  generateImage(argv[2], argv[3]);
  return 0;
}