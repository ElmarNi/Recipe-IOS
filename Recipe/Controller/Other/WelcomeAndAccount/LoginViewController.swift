//
//  LoginViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 14.06.23.
//

import UIKit

class LoginViewController: UIViewController {

    let stackView = UIStackView(frame: .zero)
    
    let logo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    
    private let signInTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.text = "Sign In"
        label.textAlignment = .center
        return label
    }()
    
    private let signInDescLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.text = "Sign in to your account"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let usernameFiled = AccountField(fieldType: .username)
    private let passwordFiled = AccountField(fieldType: .password)
    
    private let signInButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Sign In", for: .normal)
        btn.backgroundColor = .systemOrange
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
        
        stackView.addSubview(logo)
        stackView.addSubview(signInTitleLabel)
        stackView.addSubview(signInDescLabel)
        stackView.addSubview(usernameFiled)
        stackView.addSubview(passwordFiled)
        stackView.addSubview(signInButton)
        stackView.addSubview(createAccountButton)
        view.addSubview(stackView)
        
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(createAccountButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let signInDescLabelHeight = signInDescLabel.text?.getHeightForLabel(font: .systemFont(ofSize: 20, weight: .regular), width: view.width - 20) ?? 0
        let signInTitleLabelHeight = signInTitleLabel.text?.getHeightForLabel(font: .systemFont(ofSize: 24, weight: .semibold), width: view.width - 20) ?? 0
 
        logo.frame = CGRect(x: (view.width - 100) / 2, y: 0, width: 100, height: 100)
        signInTitleLabel.frame = CGRect(x: 0, y: logo.bottom + 10, width: view.width, height: signInTitleLabelHeight)
        signInDescLabel.frame = CGRect(x: 10, y: signInTitleLabel.bottom + 10, width: view.width - 20, height: signInDescLabelHeight)
        usernameFiled.frame = CGRect(x: 40, y: signInDescLabel.bottom + 20, width: view.width - 80, height: 50)
        passwordFiled.frame = CGRect(x: 40, y: usernameFiled.bottom + 10, width: view.width - 80, height: 50)
        signInButton.frame = CGRect(x: 40, y: passwordFiled.bottom + 10, width: view.width - 80, height: 50)
        createAccountButton.frame = CGRect(x: 40, y: signInButton.bottom + 30, width: view.width - 80, height: 20)
        stackView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: view.width,
                                 height: signInTitleLabel.height + signInDescLabel.height + 360)
        
        stackView.center = view.center
    }
    
    @objc private func signInButtonTapped() {
        print("SignIn")
    }
    @objc private func createAccountButtonTapped() {
        
        if let navController = self.navigationController,
           navController.viewControllers.count > 1 {
            let prevController = navController.viewControllers[navController.viewControllers.count - 2]
            let className = NSStringFromClass(prevController.classForCoder)
            if className == "Recipe.RegisterViewController" {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                let registerVC = RegisterViewController()
                navigationController?.pushViewController(registerVC, animated: true)
            }
        }
    }
}
