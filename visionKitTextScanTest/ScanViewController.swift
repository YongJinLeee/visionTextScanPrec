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

    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!


    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
    }
}

extension ScanViewController {

    private func setupCamera() {

        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video)
        else { return }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let photoOutput = AVCapturePhotoOutput()
        if (captureSession.canAddOutput(photoOutput)) {
            captureSession.addOutput(photoOutput)
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

//        DispatchQueue.main.async {
//            self.captureSession.startRunning()
//        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }

        // 사진 촬영 버튼 추가
        let captureButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        captureButton.setTitle("촬영!", for: .normal)
        captureButton.backgroundColor = .blue
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
    }

    @objc func capturePhoto() {
        let photoOutput = captureSession.outputs.first as! AVCapturePhotoOutput
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
      }
}

extension ScanViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
           guard let imageData = photo.fileDataRepresentation(),
                 let image = UIImage(data: imageData) else { return }

           recognizeText(from: image)
       }

    func recognizeText(from image: UIImage) {

        guard let cgImage = image.cgImage
        else { return }

        let request = VNRecognizeTextRequest { (request, error) in
            if let results = request.results as? [VNRecognizedTextObservation] {
                var recognizedText = ""
                for observation in results {
                    if let topcandidate = observation.topCandidates(1).first {
                        recognizedText += topcandidate.string + "\n"
                    }
                }
                self.extractCodes(from: recognizedText)
            }
        }

        request.recognitionLevel = .fast
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = false

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
        } catch {
            print("텍스트 인식 및 검출 실패 :  \(error)")
        }
    }

    func extractCodes(from text: String) {
        let regexPattern = "\\b[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}\\b|\\b[A-Z0-9]{16}\\b"
        let regex = try? NSRegularExpression(pattern: regexPattern, options: [])

        let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

        if let matches = matches {
            for match in matches {
                if let range = Range(match.range, in: text) {
                    let code = text[range]
                    print("검출 된 코드 \(code)")
                    delegate?.resultString(string: String(code))

                    navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
