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

    func addSubviews() {
        view.backgroundColor = .white
        view.addSubview(testLabel)
    }

    func setupContstraints() {

        testLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}

extension DefaultViewController {

    func pushToScanView() {

        let nextView = ScanViewController()

        navigationController?.pushViewController(nextView, animated: true)
    }
}

