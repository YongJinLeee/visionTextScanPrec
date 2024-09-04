//
//  ScanViewController.swift
//  visionKitTextScanTest
//
//  Created by YongJin on 9/3/24.
//

import UIKit

import Vision
import VisionKit

import SnapKit
import Then

class DefaultViewController: UIViewController {

    private lazy var scanStartButton = UIButton().then {
        $0.setTitle("스캔 시작", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.addTarget(self, action: #selector(pushToScanView), for: .touchUpInside)
    }

    private lazy var testLabel = UILabel().then {
        $0.text = "Hello, World!"
        $0.textColor = .black
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        setupContstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func addSubviews() {
        view.backgroundColor = .white
//        view.addSubview(testLabel)
        [testLabel, scanStartButton].forEach {
            view.addSubview($0)
        }
    }

    func setupContstraints() {

        testLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        scanStartButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-120)
            make.width.equalTo(50)
            make.width.equalTo(25)
        }
    }

}

extension DefaultViewController: ScanDelegate {

    @objc func pushToScanView() {

//        let nextView = ScanViewController()
//        navigationController?.pushViewController(nextView, animated: true)
        let nextView = VNDocumentCameraViewController()
        nextView.delegate = self

        present(nextView, animated: true)
    }

    func resultString(string: String) {
        testLabel.text = string
    }
}

extension DefaultViewController: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
    }
}
