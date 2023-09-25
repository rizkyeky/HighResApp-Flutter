import Flutter
import UIKit

public class CvdnnIosPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cvdnn_ios", binaryMessenger: registrar.messenger())
    let instance = CvdnnIosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public var cvdnn: CvdnnObjC?

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "initModel":
      if let modelPath = call.arguments as? String {
        cvdnn = CvdnnObjC(modelPath: modelPath)
        result("Done initializing model from ObjC")
      } else {
        result("Failed to initialize model from ObjC")
      }
    case "generateImage":
      let args = call.arguments as! [String]
      if let dnn = cvdnn {
        dnn.generateImage(withInputPath: args[0], outputPath: args[1])
        result("Done generating image from ObjC")
      } else {
        result("Cvdnn is not initialized")
      }
      result("Done generate image from ObjC")
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
