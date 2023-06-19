//
//  WelcomeViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 14.06.23.
//

import UIKit

class WelcomeViewController: UIViewController {

    let stackView = UIStackView(frame: .zero)
    
    private let logo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 64
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "background")
        return imageView
    }()
    
    private let overlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = .black
        overlay.alpha = 0.8
        return overlay
    }()
    
    private let signInButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Sign In", for: .normal)
        btn.backgroundColor = .systemOrange
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return btn
    }()
    
    private let continueAsGuestButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Continue as guest", for: .normal)
        btn.backgroundColor = .secondarySystemBackground
        btn.setTitleColor(.systemOrange, for: .normal)
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return btn
    }()
    
    private let createAccountButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("New user? Create Account.", for: .normal)
        btn.setTitleColor(.systemOrange, for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        view.addSubview(backgroundImageView)
        backgroundImageView.addSubview(overlay)
        stackView.addSubview(logo)
        stackView.addSubview(signInButton)
        stackView.addSubview(continueAsGuestButton)
        stackView.addSubview(createAccountButton)
        view.addSubview(stackView)
        
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        continueAsGuestButton.addTarget(self, action: #selector(continueAsGuestButtonTapped), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(createAccountButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImageView.frame = view.bounds
        overlay.frame = backgroundImageView.bounds
        logo.frame = CGRect(x: (view.width - 128) / 2, y: 0, width: 128, height: 128)
        signInButton.frame = CGRect(x: 40, y: logo.bottom + 20, width: view.width - 80, height: 50)
        continueAsGuestButton.frame = CGRect(x: 40, y: signInButton.bottom + 10, width: view.width - 80, height: 50)
        createAccountButton.frame = CGRect(x: 40, y: continueAsGuestButton.bottom + 30, width: view.width - 80, height: 20)
        
        stackView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: view.width,
                                 height: 308)
        
        stackView.center = view.center
    }
    
    @objc private func signInButtonTapped() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @objc private func continueAsGuestButtonTapped() {
        let tabBarController = TabBarViewController()
        navigationController?.navigationBar.isHidden = true
        navigationController?.pushViewController(tabBarController, animated: true)
        navigationController?.viewControllers[0].removeFromParent()
        UserDefaults.standard.setValue(false, forKey: "isSignedIn")
    }
    
    @objc private func createAccountButtonTapped() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }

}
