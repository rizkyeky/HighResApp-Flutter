import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
// import 'package:path_provider/path_provider.dart'
//     show getApplicationSupportDirectory;
// import 'package:path/path.dart' show dirname;
// import 'package:opencv_4/opencv_4.dart';
// import 'package:cvdnn/cvdnn.dart';
import 'package:cvdnn_macos/cvdnn_macos.dart';
import 'package:cvdnn_ios/cvdnn_ios.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Platform.isMacOS
    ? const MacosApp(
      debugShowCheckedModeBanner: false,
      title: 'Guest Image',
      home: MainPage(),
    )
    : const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Guest Image',
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isMacOS
    ? MacosWindow(
        child: MacosScaffold(children: [
          ContentArea(
            builder: (context, scrollController) => const HomePage(),
          )
        ])
      )
    : const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('High Res'),
      ),
      child: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _oriImage;
  File? _generatedImage;

  bool _isLoading = false;
  
  final CvdnnMacos _cvdnnMacos = CvdnnMacos();
  final CvdnnIos _cvdnnIos = CvdnnIos();

  @override
  void initState() {
    super.initState();

    if (Platform.isMacOS) {
      // _isLoading = true;
      // _cvdnnMacos.initModel().then((_) {
      //   setState(() => _isLoading = false);
      // });
    } else if (Platform.isIOS) {
      _isLoading = true;
      _cvdnnIos.getPlatformVersion().then((value) => print(value));
      _cvdnnIos.initModel().then((value) {
        setState(() => _isLoading = false);
        print(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (Platform.isIOS) const SizedBox(height: 120,),
          if (Platform.isMacOS) const Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Guest Image',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white
                ),
              ),
            ),
          ),
          const SizedBox(height: 16,),
          Expanded(
            flex: 7,
            child: Column(
              children: [
                SizedBox(
                  height: Platform.isIOS ? 200 : 300,
                  child: !_isLoading ? (_oriImage != null)
                  ? Wrap(
                    direction: Platform.isMacOS ? Axis.horizontal : Axis.vertical,
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Image.file(_oriImage!,),
                      if (_generatedImage != null) Image.file(_generatedImage!,)
                    ],
                  )
                  : DropArea(
                    onDrop: (file) {
                      setState(() => _oriImage = file);
                    },
                  )
                  : const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                ),
                if (!_isLoading) Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    direction: Platform.isMacOS ? Axis.horizontal : Axis.vertical,
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (_oriImage != null) AppleButton(
                        color: CupertinoColors.systemRed,
                        onPressed: () {
                          if (_oriImage != null) {
                            setState(() {
                              _oriImage = null;
                              _generatedImage = null;
                            });
                          }
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                      if (_oriImage != null && _generatedImage == null) AppleButton(
                        color: CupertinoColors.activeGreen,
                        onPressed: () async {
                          if (Platform.isMacOS) {
                            setState(() => _isLoading = true);
                            _cvdnnMacos.generateImage(_oriImage!.path).then((value) {
                              _generatedImage = File(value);
                              setState(() => _isLoading = false);
                            });
                          } else if (Platform.isIOS) {
                            setState(() => _isLoading = true);
                            _cvdnnIos.generateImage(_oriImage!.path).then((value) {
                              if (value != null) _generatedImage = File(value);
                              setState(() => _isLoading = false);
                            });
                          }
                        },
                        child: const Text(
                          'Generate',
                          style: TextStyle(
                            color: CupertinoColors.white,
                          ),
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppleButton extends StatelessWidget {
  const AppleButton({
    required this.onPressed, 
    required this.child, 
    this.color, 
    super.key
  });

  final Color? color;
  final void Function() onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Platform.isMacOS ? PushButton(
      controlSize: ControlSize.large,
      color: color,
      onPressed: onPressed,
      child: child,
    )
    : CupertinoButton.filled(
      onPressed: onPressed,
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              color: CupertinoColors.white,
            ),
          ),
        ),
        child: child
      ),
    );
  }
}

class DropArea extends StatefulWidget {
  const DropArea({
    super.key,
    required this.onDrop,
  });

  final Function(File? file) onDrop;

  @override
  State<DropArea> createState() => _DropAreaState();
}

class _DropAreaState extends State<DropArea> {
  File? file;
  bool _dragging = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Platform.isMacOS
        ? DropTarget(
            onDragDone: (detail) {
              setState(() {
                if (detail.files.isNotEmpty) {
                  file = File(detail.files.first.path);
                  widget.onDrop(file);
                }
              });
            },
            onDragEntered: (detail) {
              setState(() {
                _dragging = true;
              });
            },
            onDragExited: (detail) {
              setState(() {
                _dragging = false;
              });
            },
            child: DottedBorder(
                strokeWidth: 4,
                borderType: BorderType.RRect,
                radius: const Radius.circular(8),
                padding: const EdgeInsets.all(16),
                dashPattern: const [8],
                color: CupertinoColors.systemGrey5
                    .withOpacity(_dragging ? 0.4 : 1),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isLoading)
                        AppleButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                            );
                            if (result != null && result.files.isNotEmpty) {
                              final img = result.files.first;
                              if (img.path != null) {
                                setState(() {
                                  file = File(result.files.first.path!);
                                  widget.onDrop(file);
                                });
                              }
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          child: const Text('Upload'),
                        )
                      else
                        const SizedBox(
                          width: 50,
                          child: CupertinoActivityIndicator(),
                        ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Center(child: Text("or Drop here")),
                    ],
                  ),
                )),
          )
        : DottedBorder(
            strokeWidth: 4,
            borderType: BorderType.RRect,
            radius: const Radius.circular(8),
            padding: const EdgeInsets.all(16),
            dashPattern: const [8],
            color: CupertinoColors.systemGrey5.withOpacity(_dragging ? 0.4 : 1),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isLoading)
                    AppleButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          final img = result.files.first;
                          if (img.path != null) {
                            setState(() {
                              file = File(result.files.first.path!);
                              widget.onDrop(file);
                            });
                          }
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      child: const Text(
                        'Upload',
                        style: TextStyle(
                          color: CupertinoColors.white,
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      width: 50,
                      child: CupertinoActivityIndicator(),
                    ),
                  if (Platform.isMacOS) ...[
                    const SizedBox(
                      height: 16,
                    ),
                    const Center(child: Text("or Drop here")),
                  ]
                ],
              ),
            ));
  }
}
