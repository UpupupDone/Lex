//
//  ScanCodeViewController.swift
//  Swift_Demo
//
//  Created by nbcb on 2016/11/18.
//  Copyright © 2016年 周清城. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

private let scanAnimationDuration = 3.0 //扫描时长

class ScanCodeViewController: UIViewController {
    
    //MARK: Global Variables
    @IBOutlet weak var scanPane: UIImageView! ///扫描框
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var alertTitle: UILabel!
    
    var lightOn = false ///闪光灯
    var scanSession :  AVCaptureSession?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //        view.layoutIfNeeded()
        scanPane.addSubview(scanLine)
        setupScanSession()
        
//        setViewsMakeConstraints()
    }
    
//    func setViewsMakeConstraints() {
//        
//        let common_Height : CGFloat = app_height / 3
//        let center_space : CGFloat = (app_width - common_Height) / 2
//        weak var weakSelf : ScanCodeViewController? = self
//        
//        self.topView.alpha = 0.6
//        self.leftView.alpha = 0.6
//        self.rightView.alpha = 0.6
//        self.bottomView.alpha = 0.6
//        self.scanPane.alpha = 0.2
//        self.tabBarView.alpha = 0.6
//
//        self.topView.snp.makeConstraints { (make) -> Void in
//            
//            make.top.equalTo((weakSelf?.view)!).offset(0)
//            make.left.equalTo((weakSelf?.view)!).offset(0)
//            make.size.equalTo(CGSize.init(width: app_width, height: common_Height))
//        }
//        
//        self.leftView.snp.makeConstraints { (make) -> Void in
//            make.top.equalTo((weakSelf?.view)!).offset(common_Height)
//            make.left.equalTo((weakSelf?.view)!).offset(0)
//            make.size.equalTo(CGSize.init(width: center_space, height: common_Height))
//        }
//        
//        self.rightView.snp.makeConstraints { (make) -> Void in
//            make.top.equalTo((weakSelf?.view)!).offset(common_Height)
//            make.right.equalTo((weakSelf?.view)!).offset(0)
//            make.size.equalTo(CGSize.init(width: center_space, height: common_Height))
//        }
//        
//        self.scanPane.snp.makeConstraints { (make) -> Void in
//            make.top.equalTo((weakSelf?.view)!).offset(common_Height)
//            make.left.equalTo((weakSelf?.view)!).offset(center_space)
//            make.size.equalTo(CGSize.init(width: common_Height, height: common_Height))
//        }
//        
//        self.activityIndicatorView.snp.makeConstraints { (make) -> Void in
//            make.center.equalTo((weakSelf?.view)!)
//            make.size.equalTo(CGSize.init(width: 37, height: 37))
//        }
//        
//        self.bottomView.snp.makeConstraints { (make) -> Void in
//            make.top.equalTo((weakSelf?.scanPane)!).offset(0)
//            make.bottom.equalTo((weakSelf?.view)!).offset(0)
//            make.left.equalTo((weakSelf?.view)!).offset(0)
//            make.right.equalTo((weakSelf?.view)!).offset(0)
//            //            make.size.equalTo(CGSize.init(width: app_width, height: common_Height))
//        }
//        
//        self.tabBarView.snp.makeConstraints { (make) -> Void in
//            make.bottom.equalTo((weakSelf?.bottomView)!).offset(0)
//            make.left.equalTo((weakSelf?.bottomView)!).offset(0)
//            make.size.equalTo(CGSize.init(width: app_width, height: 80))
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        startScan()
    }
    
    //MARK: Lazy Components
    lazy var scanLine : UIImageView = {
        
        let scanLine = UIImageView()
        scanLine.frame = CGRect(x: 0, y: 0, width: app_height / 3, height: 3)
        scanLine.image = UIImage(named: "QRCode_ScanLine")
        return scanLine
    }()
    
    //MARK: Interface Components
    func setupScanSession() {
        
        do {
            
            //设置捕捉设备
            let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            //设置设备输入输出
            let input = try AVCaptureDeviceInput(device: device)
            
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            //设置会话
            let  scanSession = AVCaptureSession()
            scanSession.canSetSessionPreset(AVCaptureSessionPresetHigh)
            
            if scanSession.canAddInput(input) {
                scanSession.addInput(input)
            }
            
            if scanSession.canAddOutput(output) {
                scanSession.addOutput(output)
            }
            
            //设置扫描类型(二维码和条形码)
            output.metadataObjectTypes = [
                AVMetadataObjectTypeQRCode,
                AVMetadataObjectTypeCode39Code,
                AVMetadataObjectTypeCode128Code,
                AVMetadataObjectTypeCode39Mod43Code,
                AVMetadataObjectTypeEAN13Code,
                AVMetadataObjectTypeEAN8Code,
                AVMetadataObjectTypeCode93Code]
            
            //预览图层
            let scanPreviewLayer = AVCaptureVideoPreviewLayer(session:scanSession)
            scanPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            scanPreviewLayer!.frame = view.layer.bounds
            
            view.layer.insertSublayer(scanPreviewLayer!, at: 0)
            
            //设置扫描区域
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: nil, using: { (noti) in
                output.rectOfInterest = (scanPreviewLayer?.metadataOutputRectOfInterest(for: self.scanPane.frame))!
            })
            
            //保存会话
            self.scanSession = scanSession
        }
        catch {
            
            //摄像头不可用
            ScanCodeTool.confirm("温馨提示", "摄像头不可用", self)
            return
        }
    }
    
    //MARK: - 相册
    @IBAction func photo() {
        
        ScanCodeTool.shareTool().choosePicture(self, true, .photoLibrary) {[weak self] (image) in
            
            self!.activityIndicatorView.startAnimating()
            
            DispatchQueue.global().async {
                let recognizeResult = image.recognizeQRCode()
                let result = recognizeResult?.characters.count > 0 ? recognizeResult : "无法识别"
                DispatchQueue.main.async {
                    self!.activityIndicatorView.stopAnimating()
                    ScanCodeTool.confirm("扫描结果", result, self!)
                }
            }
        }
    }
    
    //MARK: - 闪光灯
    @IBAction func light(_ sender: UIButton) {
        
        lightOn = !lightOn
        sender.isSelected = lightOn
        turnTorchOn()
        
    }
    
    //MARK: - 我的二维码
    @IBAction func myQRCode(_ sender: Any) {
        
        let vc = UserInfoQRCodeVC()
        vc.pushFlag = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //开始扫描
    fileprivate func startScan() {
        
        scanLine.layer.add(scanAnimation(), forKey: "scan")
        
        guard let scanSession = scanSession else { return }
        
        if !scanSession.isRunning {
            scanSession.startRunning()
        }
    }
    
    //扫描动画
    private func scanAnimation() -> CABasicAnimation {
        
        let startPoint = CGPoint(x: scanLine .center.x  , y: 1)
        let endPoint = CGPoint(x: scanLine.center.x, y: scanPane.bounds.size.height - 2)
        
        let translation = CABasicAnimation(keyPath: "position")
        translation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        translation.fromValue = NSValue(cgPoint: startPoint)
        translation.toValue = NSValue(cgPoint: endPoint)
        translation.duration = scanAnimationDuration
        translation.repeatCount = MAXFLOAT
        translation.autoreverses = true
        
        return translation
    }
    
    ///闪光灯
    private func turnTorchOn() {
        
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            
            if lightOn {
                ScanCodeTool.confirm("温馨提示", "闪光灯不可用", self)
            }
            return
        }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if lightOn && device.torchMode == .off {
                    device.torchMode = .on
                }
                if !lightOn && device.torchMode == .on {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            }
            catch { }
        }
    }
    
    deinit  {
        
        ///移除通知
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanCodeViewController : AVCaptureMetadataOutputObjectsDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        //停止扫描
        self.scanLine.layer.removeAllAnimations()
        self.scanSession!.stopRunning()
        
        //播放声音
        ScanCodeTool.playAlertSound("noticeMusic.caf")
        
        //扫完完成
        if metadataObjects.count > 0 {
            
            if let resultObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                
                ScanCodeTool.confirm("扫描结果", resultObj.stringValue, self, handler: { (_) in
                    //继续扫描
                    self.startScan()
                })
            }
        }
    }
}
