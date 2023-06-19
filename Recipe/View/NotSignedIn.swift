//
//  NotSignedIn.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 19.06.23.
//

import UIKit
protocol NotSignedInDelegate: AnyObject {
    func notSignedInTapped()
}
class NotSignedIn: UIView {
    
    weak var delegate: NotSignedInDelegate?
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.addTarget(self, action: #selector(notSignedInTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        button.frame = self.bounds
    }
    
    @objc private func notSignedInTapped() {
        delegate?.notSignedInTapped()
    }

}
