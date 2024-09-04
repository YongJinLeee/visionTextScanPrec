//
//  ScanViewController.swift
//  visionKitTextScanTest
//
//  Created by YongJin on 9/3/24.
//

import UIKit

import Vision
import VisionKit
import AVFoundation

protocol ScanDelegate: AnyObject {

    func resultString(string: String)
}

class ScanViewController: UIViewController {

    weak var delegate: ScanDelegate?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput = AVCapturePhotoOutput()
    private var photoSettings: AVCapturePhotoSettings?


    override func viewDidLoad() {
        super.viewDidLoad()

        scanStart()
    }

    private func scanStart() {

//        let handler = VNImageRequestHandler(cgImage: CGImage)
        let request = VNRecognizeTextRequest { [weak self] response, error in
            guard let self = self else { return }

            guard let observations = response.results as? [VNRecognizedTextObservation], error == nil  else { return }

            let text = observations.compactMap ({
                $0.topCandidates(1).first?.string
            }).joined(separator: "-")

            DispatchQueue.main.async {
                self.delegate?.resultString(string: text)
                print(text, "전달완료")
            }
        }
        let revision3 = VNRecognizeTextRequestRevision3
        request.revision = revision3
        request.recognitionLevel = .fast
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = false

        do { 
            var possibleLanguages: Array<String> = []
            possibleLanguages = try request.supportedRecognitionLanguages()
            print(possibleLanguages, "\n끝")

        } catch {
            print("인식 에러")
        }
    }
}

extension ScanViewController {

    private func setupInput() {

        var backCamera: AVCaptureDevice?

        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            fatalError("후면 카메라 사용불가")
        }
        
        // AF 기능 활성화
        do {
            try backCamera?.lockForConfiguration()
            backCamera?.focusMode = .continuousAutoFocus
            backCamera?.unlockForConfiguration()
        } catch {
            fatalError("후면 카메라 오토포커싱 처리 오류")
        }

        guard let backCamera = backCamera,
              let backCameraInput = try? AVCaptureDeviceInput(device: backCamera) 
        else { fatalError("후면 카메라 기능 시작 오류") }

        if let captureSession = captureSession,
           !captureSession.canAddInput(backCameraInput) {
            fatalError("후면 카메라 캡쳐세션 초기화 오류")
        }

        captureSession?.addInput(backCameraInput)
    }

    private func setupOutput() {

        if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {

            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
    }

    func setupCameraSession() {
        captureSession = AVCaptureSession()
        captureSession?.beginConfiguration()

        if let captureSession = captureSession,
           captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }

        setupInput()
        setupOutput()

        captureSession?.commitConfiguration()


    }
}
