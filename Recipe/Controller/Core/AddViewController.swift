//
//  AddViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 31.05.23.
//

import UIKit

class AddViewController: UIViewController {

    private let notSignedIn = NotSignedIn(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(notSignedIn)
        
        guard let isSignedIn = UserDefaults.standard.value(forKey: "isSignedIn") as? Bool else { return }
        notSignedIn.isHidden = isSignedIn
        notSignedIn.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        notSignedIn.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
    }

}

extension AddViewController: NotSignedInDelegate {
    
    func notSignedInTapped() {
        let welcomeVC = WelcomeViewController()
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(welcomeVC, animated: true)
        navigationController?.viewControllers[0].removeFromParent()
    }
    
}
