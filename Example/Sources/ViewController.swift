//
//  ASAPTY.swift
//  ASAPTY
//
//  Created by Pavel Kuznetsov on 14.01.2022.
//

import UIKit
import ASAPTY_SDK

class ViewController: UIViewController {
    private let button: UIButton = {
        let button = UIButton(frame: .init(x: 0, y: 0, width: 250, height: 56))
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        button.setTitle("Отправить событие", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(button)
        button.center = view.center
    }
    
    @objc
    private func didTap() {
        ASAPTY.shared.track(eventName: "inapp_purchase", productId: "com.sdk.asapty", revenue: "3.0", currency: "USD")
    }
}

