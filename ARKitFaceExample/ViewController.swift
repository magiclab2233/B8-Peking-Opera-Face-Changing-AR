/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, ARSessionDelegate {
    
    // MARK: Outlets

    @IBOutlet var sceneView: ARSCNView!

    @IBOutlet weak var blurView: UIVisualEffectView!

    private lazy var changeBtn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("更换脸谱", for: .normal)
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    private lazy var saveBtn:UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("保存", for: .normal)
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    var facePickerView: BottomSheetFacePickerView!
    
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()

    // MARK: Properties

    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }

    var nodeForContentType = [VirtualContentType: VirtualFaceNode]()
    
    let contentUpdater = VirtualContentUpdater()

    // MARK: - View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = contentUpdater
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        createUI()
        createFaceGeometry()

        // Set the initial face content, if any.
        contentUpdater.virtualFaceNode = nodeForContentType[.faceGeometry]

        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
            AR experiences typically involve moving the device without
            touch input for some time, so prevent auto screen dimming.
        */
        UIApplication.shared.isIdleTimerDisabled = true
        
        resetTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        session.pause()
    }
    
    func createUI() {
        self.view.addSubview(changeBtn)
        self.changeBtn.frame = CGRectMake(20, 100, 80, 48)
        self.changeBtn.addTarget(self, action: #selector(changeBtnClick), for: .touchUpInside)
        
        self.view.addSubview(self.saveBtn)
        self.saveBtn.frame = CGRectMake(20, 168, 80, 48)
        self.saveBtn.addTarget(self, action: #selector(saveSnapshotToPhotos), for: .touchUpInside)
        
        
        facePickerView = BottomSheetFacePickerView(frame: CGRectMake(0, 0, self.view.frame.size.width / 3.0, self.view.frame.size.height))
        facePickerView.faceMaterials = ["lianpu1", "lianpu2", "lianpu3","lianpu4","lianpu5","lianpu6","lianpu7","lianpu8","lianpu9"] // 设置脸谱图片名
        facePickerView.didSelectFace = { faceName in
            self.applyFaceTexture(named: faceName)
        }
    }
    
    @objc private func changeBtnClick() {
        facePickerView.show(in: self.view)
    }
    
    // MARK: - Setup
    
    /// - Tag: CreateARSCNFaceGeometry
    func createFaceGeometry() {
        // This relies on the earlier check of `ARFaceTrackingConfiguration.isSupported`.
        let device = sceneView.device!
        let maskGeometry = ARSCNFaceGeometry(device: device)!
        nodeForContentType = [
            .faceGeometry: Mask(geometry: maskGeometry),
        ]
    }
    
    private func applyFaceTexture(named:String) {
        nodeForContentType[.faceGeometry]?.updateName(name: named)
    }
    
    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "AR 会话失败。", message: errorMessage)
        }
    }

    func sessionWasInterrupted(_ session: ARSession) {
        blurView.isHidden = false
        statusViewController.showMessage("""
        会话已中断
        中断结束后，会话将被重置。
        """, autoHide: false)
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        blurView.isHidden = true
        
        DispatchQueue.main.async {
            self.resetTracking()
        }
    }
    
    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        statusViewController.showMessage("正在启动新会话")
        
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    // MARK: - Interface Actions

    /// - Tag: restartExperience
    func restartExperience() {
        // Disable Restart button for a while in order to give the session enough time to restart.
        statusViewController.isRestartExperienceButtonEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.statusViewController.isRestartExperienceButtonEnabled = true
        }

        resetTracking()
    }
    
    // MARK: - Error handling
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "重新开始会话", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        facePickerView.hide()
    }
    
    // 捕获当前场景视图的快照并保存到相册
   @objc private func saveSnapshotToPhotos() {
        // 获取当前渲染图像
        let snapshotImage = sceneView.snapshot()
        
        // 保存图像到相册
        UIImageWriteToSavedPhotosAlbum(snapshotImage, self, #selector(imageSavedToAlbum(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // 处理保存操作的回调
    @objc func imageSavedToAlbum(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // 如果保存失败，显示错误信息
            let alert = UIAlertController(title: "错误", message: "保存图片失败: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true, completion: nil)
        } else {
            // 保存成功，显示成功提示
            let alert = UIAlertController(title: "成功", message: "图片已经保存到相册", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }
}
