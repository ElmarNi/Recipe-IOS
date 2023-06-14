//
//  RegisterViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 14.06.23.
//

import UIKit

class RegisterViewController: UIViewController {

    let stackView = UIStackView(frame: .zero)
    
    let logo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    
    private let signUpTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.text = "Sign Up"
        label.textAlignment = .center
        return label
    }()
    
    private let signUpDescLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.text = "Create your account"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let firstNameFiled = AccountField(fieldType: .firstname)
    private let lastNameFiled = AccountField(fieldType: .lastname)
    private let emailFiled = AccountField(fieldType: .email)
    private let usernameFiled = AccountField(fieldType: .username)
    private let passwordFiled = AccountField(fieldType: .password)
    
    private let signUpButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Sign Up", for: .normal)
        btn.backgroundColor = .systemOrange
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return btn
    }()
    
    private let termsTextView: UITextView = {
        let textView = UITextView()
        let text = NSMutableAttributedString(string: "By creating an account, you agree to our Terms & Conditions and you acknowledge that you have read our Privacy Policy.",
                                             attributes: [.font: UIFont.systemFont(ofSize: 14)])
        text.addAttribute(.link, value: "terms://termsAndConditions", range: (text.string as NSString).range(of: "Terms & Conditions"))
        text.addAttribute(.link, value: "privacy://privacyPolicy", range: (text.string as NSString).range(of: "Privacy Policy"))
        textView.linkTextAttributes = [.foregroundColor: UIColor.link]
        textView.attributedText = text
        textView.backgroundColor = .clear
        textView.textColor = .label
        textView.isSelectable = true
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.delaysContentTouches = false
        return textView
    }()
    
    private let haveAccountButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Already have an account? Sign In.", for: .normal)
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
        stackView.addSubview(signUpTitleLabel)
        stackView.addSubview(signUpDescLabel)
        stackView.addSubview(firstNameFiled)
        stackView.addSubview(lastNameFiled)
        stackView.addSubview(emailFiled)
        stackView.addSubview(usernameFiled)
        stackView.addSubview(passwordFiled)
        stackView.addSubview(signUpButton)
        stackView.addSubview(termsTextView)
        stackView.addSubview(haveAccountButton)
        view.addSubview(stackView)
        
        termsTextView.delegate = self
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        haveAccountButton.addTarget(self, action: #selector(haveAccountButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                                                              
        let signUpDescLabelHeight = signUpDescLabel.text?.getHeightForLabel(font: .systemFont(ofSize: 20, weight: .regular), width: view.width - 20) ?? 0
        let signUpTitleLabelHeight = signUpTitleLabel.text?.getHeightForLabel(font: .systemFont(ofSize: 24, weight: .semibold), width: view.width - 20) ?? 0
        
        logo.frame = CGRect(x: (view.width - 100) / 2, y: 0, width: 100, height: 100)
        signUpTitleLabel.frame = CGRect(x: 10, y: logo.bottom + 10, width: view.width - 20, height: signUpTitleLabelHeight)
        signUpDescLabel.frame = CGRect(x: 10, y: signUpTitleLabel.bottom + 10, width: view.width - 20, height: signUpDescLabelHeight)
        firstNameFiled.frame = CGRect(x: 40, y: signUpDescLabel.bottom + 20, width: view.width - 80, height: 50)
        lastNameFiled.frame = CGRect(x: 40, y: firstNameFiled.bottom + 10, width: view.width - 80, height: 50)
        emailFiled.frame = CGRect(x: 40, y: lastNameFiled.bottom + 10, width: view.width - 80, height: 50)
        usernameFiled.frame = CGRect(x: 40, y: emailFiled.bottom + 10, width: view.width - 80, height: 50)
        passwordFiled.frame = CGRect(x: 40, y: usernameFiled.bottom + 10, width: view.width - 80, height: 50)
        signUpButton.frame = CGRect(x: 40, y: passwordFiled.bottom + 10, width: view.width - 80, height: 50)
        termsTextView.frame = CGRect(x: 40, y: signUpButton.bottom + 10, width: view.width - 80, height: 0)
        termsTextView.sizeToFit()
        haveAccountButton.frame = CGRect(x: 40, y: termsTextView.bottom + 10, width: view.width - 80, height: 20)
        
        stackView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: view.width,
                                 height: signUpTitleLabel.height + signUpDescLabel.height + termsTextView.height + 530)
        
        stackView.center = view.center
    }

}


extension RegisterViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "terms" {
            showWebViewController(with: "https://policies.google.com/terms?hl=en-US")
        }
        else if URL.scheme == "privacy" {
            showWebViewController(with: "https://policies.google.com/privacy?hl=en-US")
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
    
}

extension RegisterViewController {
    
    @objc private func signUpButtonTapped() {
        
    }
    
    @objc private func haveAccountButtonTapped() {
        if let navController = self.navigationController,
           navController.viewControllers.count > 1 {
            let prevController = navController.viewControllers[navController.viewControllers.count - 2]
            let className = NSStringFromClass(prevController.classForCoder)
            if className == "Recipe.LoginViewController" {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                let loginVC = LoginViewController()
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
    }
    
    private func showWebViewController(with urlString: String) {
        let webVCNavController = UINavigationController(rootViewController: WebViewController(urlString: urlString))
        present(webVCNavController, animated: true)
    }
}
