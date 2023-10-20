import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as pffi;

import 'package:path/path.dart' as pth;
import 'package:path_provider/path_provider.dart' as pthp;

import 'bindings_generated.dart';

class DataIsolate {
  final int id;
  final List<dynamic> data;
  const DataIsolate(this.id, this.data);
}

class CvdnnMacos {
  Future<String> get _appCachePath async => pthp.getApplicationCacheDirectory().then((value) => value.path);
  int _nextId = 0;


  Future<void> initModel() async {
    final SendPort helperSendPort = await initModelIsolateSendPort;
    final int requestId = _nextId++;
    final DataIsolate request = DataIsolate(requestId, ['START']);
    final Completer<List<dynamic>> completer = Completer<List<dynamic>>();
    dataRequests[requestId] = completer;
    helperSendPort.send(request); 
    await completer.future;
  }

  Future<String> generateImage(String imagePath) async {
    final baseName = pth.basename(imagePath);
    final outputPath = '${(await _appCachePath)}/$baseName';
    final SendPort helperSendPort = await generateImageIsolateSendPort;
    final int requestId = _nextId++;
    final DataIsolate request = DataIsolate(requestId, [imagePath, outputPath]);
    final Completer<List<dynamic>> completer = Completer<List<dynamic>>();
    dataRequests[requestId] = completer;
    helperSendPort.send(request); 
    await completer.future;

    return outputPath;
  }
}

const String _libName = 'cvdnn_macos';
String get _modelPath {
  final appPath = Directory(Platform.resolvedExecutable).parent.parent.path;
  return pth.join(appPath, 'Frameworks', 'App.framework', 'Resources', 'flutter_assets', 'assets', 'animesr.onnx');
}

ffi.DynamicLibrary get _dylib => ffi.DynamicLibrary.executable();
final CvdnnMacosBindings _bindings = CvdnnMacosBindings(_dylib);

final Map<int, Completer<List<dynamic>>> dataRequests = <int, Completer<List<dynamic>>>{};

Future<SendPort> initModelIsolateSendPort = () async {
  final Completer<SendPort> completer = Completer<SendPort>();
  final ReceivePort receivePort = ReceivePort()
    ..listen((dynamic data) {
      if (data is SendPort) {
        completer.complete(data);
        return;
      }
      if (data is DataIsolate) {
        final Completer<List<dynamic>> completer = dataRequests[data.id]!;
        dataRequests.remove(data.id);
        completer.complete(data.data);
        return;
      }
      throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
  });

  await Isolate.spawn((SendPort sendPort) async {
    final ReceivePort helperReceivePort = ReceivePort()
      ..listen((dynamic data) async {
        if (data is DataIsolate) {
          try {
            final file = File(_modelPath);
            final isFile = await file.exists();
            if (isFile) {
              print('Found $_modelPath');
              _bindings.initNetFromOnnx(_modelPath.toNativeUtf8());
            }
          } catch (e) {
            throw Exception('Error init model');
          }
          final response = DataIsolate(data.id, ['DONE']);
          sendPort.send(response);
          return;
        }
        throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
      });
    sendPort.send(helperReceivePort.sendPort);
  }, receivePort.sendPort);

  return completer.future;
}();

Future<SendPort> generateImageIsolateSendPort = () async {
  final Completer<SendPort> completer = Completer<SendPort>();
  final ReceivePort receivePort = ReceivePort()
    ..listen((dynamic data) {
      if (data is SendPort) {
        completer.complete(data);
        return;
      }
      if (data is DataIsolate) {
        final Completer<List<dynamic>> completer = dataRequests[data.id]!;
        dataRequests.remove(data.id);
        completer.complete(data.data);
        return;
      }
      throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
  });

  await Isolate.spawn((SendPort sendPort) async {
    final ReceivePort helperReceivePort = ReceivePort()
      ..listen((dynamic data) {
        if (data is DataIsolate) {
          final imagePath = data.data[0] as String;
          final outputPath = data.data[1] as String;
          try {
            print('Start generate image');
            _bindings.generateImage(imagePath.toNativeUtf8(), outputPath.toNativeUtf8());
          } catch (e) {
            throw Exception('Error generate image');
          }
          final response = DataIsolate(data.id, ['DONE']);
          sendPort.send(response);
          return;
        }
        throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
      });
    sendPort.send(helperReceivePort.sendPort);
  }, receivePort.sendPort);

  return completer.future;
}();