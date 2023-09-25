import 'package:torch_cpp/torch_cpp.dart';
import 'package:torch_ffi/torch_ffi.dart';
import 'package:torch_sr/torch_sr.dart';

Future<void> some() async {
  
  final TorchCpp torchCpp = TorchCpp();

  torchCpp.createStack();
  torchCpp.pushStack(1);
  torchCpp.pushStack(2);
  torchCpp.pushStack(3);
  torchCpp.pushStack(4);
  torchCpp.pushStack(5);

  print(torchCpp.lenStack().toString());

  final pop1 = torchCpp.popStack();
  final pop2 = torchCpp.popStack();

  print('$pop1, $pop2');
  print(torchCpp.lenStack().toString());

  torchCpp.deleteStack();

  final str = torchCpp.addStr('Hello World!');
  final arr = torchCpp.addArray1D(5);
  final arr2 = torchCpp.addArray2D(3,3);
  print('$str $arr $arr2');

  final totalArr = torchCpp.countArray1D(arr);
  final totalArr2 = torchCpp.countArray2D(arr2);
  print('$totalArr $totalArr2');

  final mat = torchCpp.doMatrixOps(1.9);
  print(mat.toString());

  final json = torchCpp.doJson();
  print(json);

  final onnx = torchCpp.initOnnxModel();
  print(onnx.toString());

  final TorchFfi torchFfi = TorchFfi();
  final c = torchFfi.cFunction(10);
  print(c.toString());

  final TorchSR torchSR = TorchSR();
  await torchSR.initModel();
}