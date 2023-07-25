//
//  AddViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 31.05.23.
//

import UIKit

class AddViewController: UIViewController {

    private let notSignedIn = NotSignedIn(frame: .zero)
    
    private var categories = [Category]()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isHidden = true
        return scrollView
    }()
    
    private var ingridients = [String]()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        return spinner
    }()
    
    private let imageButton: UIButton = {
        let button = UIButton()
        button.setTitle(nil, for: .normal)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFill
        button.setBackgroundImage(UIImage(named: "add-image"), for: .normal)
        return button
    }()
    
    private let nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter name..."
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 16)
        return field
    }()
    
    private let timeField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter time..."
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 16)
        return field
    }()
    
    private let peopleField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter people..."
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 16)
        return field
    }()
    
    private let categoriesPickerView = UIPickerView()
    private let categoriesTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Select category..."
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 16)
        field.allowsEditingTextAttributes = false
        field.tintColor = UIColor.clear
        return field
    }()
    
    private let descriptionText: UITextView = {
        let textView = UITextView()
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        textView.text = "Enter description..."
        textView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.7).cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = true
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        return tableView
    }()
    
    private let addIngridientButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Ingridient", for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 6
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 6
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    private let buttonStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(notSignedIn)
        
        guard let isSignedIn = UserDefaults.standard.value(forKey: "isSignedIn") as? Bool else { return }
        notSignedIn.isHidden = isSignedIn
        notSignedIn.delegate = self
        
        if isSignedIn {
            scrollView.backgroundColor = .systemBackground
            view.addSubview(scrollView)
            view.addSubview(spinner)
            scrollView.addSubview(imageButton)
            scrollView.addSubview(nameField)
            scrollView.addSubview(timeField)
            scrollView.addSubview(peopleField)
            scrollView.addSubview(categoriesTextField)
            scrollView.addSubview(descriptionText)
            scrollView.addSubview(tableView)
            scrollView.addSubview(buttonStackView)
            buttonStackView.addSubview(addIngridientButton)
            buttonStackView.addSubview(saveButton)
            
            tableView.dataSource = self
            tableView.delegate = self
            
            categoriesPickerView.delegate = self
            categoriesPickerView.dataSource = self
            categoriesTextField.inputView = categoriesPickerView
            categoriesTextField.delegate = self
            
            imageButton.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
            addIngridientButton.addTarget(self, action: #selector(addIngridientButtonTapped), for: .touchUpInside)
            saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
            descriptionText.delegate = self
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(gesture)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            
            getCategories()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        notSignedIn.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        scrollView.frame = view.bounds
        
        imageButton.frame = CGRect(x: 10, y: 10, width: view.width - 20, height: view.width - 20)
        imageButton.backgroundColor = .white
        nameField.frame = CGRect(x: 10, y: imageButton.bottom + 10, width: view.width - 20, height: 30)
        timeField.frame = CGRect(x: 10, y: nameField.bottom + 5, width: view.width - 20, height: 30)
        peopleField.frame = CGRect(x: 10, y: timeField.bottom + 5, width: view.width - 20, height: 30)
        categoriesTextField.frame = CGRect(x: 10, y: peopleField.bottom + 5, width: view.width - 20, height: 30)
        descriptionText.frame = CGRect(x: 10, y: categoriesTextField.bottom + 5, width: view.width - 20, height: 35)
        tableView.frame = CGRect(x: 40, y: descriptionText.bottom + 10, width: view.width - 80, height: 0)
        buttonStackView.frame = CGRect(x: 10, y: tableView.bottom + 10, width: view.width - 20, height: 30)
        addIngridientButton.frame = CGRect(x: 0, y: 0, width: (buttonStackView.width / 2) - 3, height: 30)
        saveButton.frame = CGRect(x: addIngridientButton.right + 6, y: 0, width: (buttonStackView.width / 2) - 3, height: 30)
        scrollView.setContentSize()
        spinner.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        spinner.center = view.center
    }
    
    private func getCategories() {
        DispatchQueue.main.async {
            ApiCaller.shared.getCategories(sessionDelegate: self) {[weak self] result in
                switch result {
                case .success(let categoriesModel):
                    self?.categories = categoriesModel
                    self?.scrollView.isHidden = false
                    self?.categoriesPickerView.reloadAllComponents()
                    self?.spinner.stopAnimating()
                case .failure(_):
                    showAlert(title: "Error", message: "Can't get categories", target: self)
                }
            }
        }
    }
    
    @objc private func imageButtonTapped() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        view.endEditing(true)
    }
    
    @objc private func addIngridientButtonTapped() {
        view.endEditing(true)
        let alertVC = UIAlertController(title: "Add ingdridient", message: nil, preferredStyle: .alert)
        alertVC.addTextField{ textField in
            textField.placeholder = "Ingdridient..."
        }
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let field = alertVC.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty
            else {
                showAlert(title: "Error", message: "Ingdridient name can't be empty", target: self)
                return
            }
            
            self.ingridients.append(text)
            
            let textHeight = text.getHeightForLabel(font: .systemFont(ofSize: 14, weight: .semibold), width: self.view.width - 120) + 10
            let tableOldHeight = self.tableView.height
            let tableNewHeight = tableOldHeight + textHeight
            
            self.tableView.reloadData()
            self.tableView.frame = CGRect(x: 40, y: self.descriptionText.bottom + 10, width: self.view.width - 80, height: tableNewHeight)
            self.buttonStackView.frame = CGRect(x: 10, y: self.tableView.bottom + 10, width: self.view.width - 20, height: 30)
            if tableNewHeight != tableOldHeight {
                let oldScrollViewSize = self.scrollView.contentSize
                self.scrollView.contentSize = CGSize(width: oldScrollViewSize.width, height: oldScrollViewSize.height + (tableNewHeight - tableOldHeight))
            }
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alertVC, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        spinner.isHidden = false
        spinner.startAnimating()
        view.endEditing(true)
        DispatchQueue.main.async {
            guard let username = UserDefaults.standard.value(forKey: "username") as? String else {
                showAlert(title: "Error", message: "Can't add recipe", target: self)
                return
            }
            
            if let text = self.nameField.text, text.isEmpty {
                showAlert(title: "Error", message: "Name can't be empty", target: self)
                return
            }
            
            if let text = self.timeField.text, text.isEmpty {
                showAlert(title: "Error", message: "Time can't be empty", target: self)
                return
            }
            
            if let text = self.peopleField.text, text.isEmpty {
                showAlert(title: "Error", message: "People can't be empty", target: self)
                return
            }
            
            if let text = self.categoriesTextField.text, text.isEmpty {
                showAlert(title: "Error", message: "Category can't be empty", target: self)
                return
            }
            
            if let text = self.descriptionText.text, text.isEmpty, text == "Enter description..." {
                showAlert(title: "Error", message: "Description can't be empty", target: self)
                return
            }
            
            if self.ingridients.count == 0 {
                showAlert(title: "Error", message: "Ingridients can't be empty", target: self)
                return
            }
            
            let category = self.categories.first { category in
                category.name == self.categoriesTextField.text
            }
            
            let recipe = Recipe(authorName: username,
                                category: category,
                                description: self.descriptionText.text,
                                id: nil,
                                imageUrl: "testImageUrl",
                                ingridients: self.ingridients.joined(separator: ","),
                                likes: 0,
                                name: "\(self.nameField.text ?? "")",
                                people: Int(self.peopleField.text ?? "0") ?? 0,
                                time: "\(self.timeField.text ?? "") min")
            
            ApiCaller.shared.addRecipe(recipe: recipe, sessionDelegate: self) { [weak self] result in
                self?.spinner.isHidden = true
                self?.spinner.stopAnimating()
                if result {
                    showAlert(title: "Success", message: "Recipe added successfuly", target: self)
                    self?.nameField.text = nil
                    self?.timeField.text = nil
                    self?.peopleField.text = nil
                    self?.descriptionText.text = "Enter description..."
                    self?.descriptionText.textColor = .lightGray
                    self?.categoriesTextField.text = nil
                    self?.imageButton.setBackgroundImage(UIImage(named: "add-image"), for: .normal)
                    self?.ingridients = []
                    self?.tableView.reloadData()
                }
                else {
                    showAlert(title: "Error", message: "Can't add recipe", target: self)
                }
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.setContentOffset(CGPoint(x: 0, y: keyboardSize.height - view.safeAreaInsets.top - 100), animated: true)
            
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.setContentOffset(CGPoint(x: 0, y: -view.safeAreaInsets.top), animated: true)
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        
        let text = ingridients[sender.tag]
        let textHeight = text.getHeightForLabel(font: .systemFont(ofSize: 14, weight: .semibold), width: self.view.width - 120) + 10
        let tableOldHeight = self.tableView.height
        let tableNewHeight = tableOldHeight - textHeight
        
        self.ingridients.remove(at: sender.tag)
        self.tableView.reloadData()
        self.tableView.frame = CGRect(x: 40, y: self.descriptionText.bottom + 10, width: self.view.width - 80, height: tableNewHeight)
        self.buttonStackView.frame = CGRect(x: 10, y: self.tableView.bottom + 10, width: self.view.width - 20, height: 30)
        if tableNewHeight != tableOldHeight {
            let oldScrollViewSize = self.scrollView.contentSize
            self.scrollView.contentSize = CGSize(width: oldScrollViewSize.width, height: oldScrollViewSize.height + (tableNewHeight - tableOldHeight))
        }
    }
    
}

extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageButton.setBackgroundImage(image, for: .normal)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func textViewDidBeginEditing (_ textView: UITextView) {
        if textView.text == "Enter description..." { textView.text = nil }
        textView.textColor = .label
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            textView.textColor = .lightGray
            textView.text = "Enter description..."
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: view.width - 20, height: CGFloat.greatestFiniteMagnitude))
        let oldSize = descriptionText.height
        descriptionText.frame = CGRect(x: 10, y: categoriesTextField.bottom + 5, width: view.width - 20, height: newSize.height)
        tableView.frame = CGRect(x: 40, y: descriptionText.bottom + 10, width: view.width - 20, height: tableView.height)
        buttonStackView.frame = CGRect(x: 10, y: tableView.bottom + 10, width: view.width - 20, height: 30)
        if newSize.height != oldSize {
            let oldScrollViewSize = scrollView.contentSize
            scrollView.contentSize = CGSize(width: oldScrollViewSize.width, height: oldScrollViewSize.height + (newSize.height - oldSize))
        }
    }
    
}

extension AddViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingridients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let dotImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .regular))
            imageView.tintColor = .label
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        let ingridientLabel: UILabel = {
            let label = UILabel()
            label.text = ingridients[indexPath.row].trimmingCharacters(in: .whitespaces)
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            label.numberOfLines = 0
            return label
        }()
        
        let deleteButton: UIButton = {
            let btn = UIButton()
            btn.setTitle(nil, for: .normal)
            btn.setBackgroundImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
            btn.tintColor = .red
            btn.tag = indexPath.row
            return btn
        }()
        
        cell.addSubview(dotImageView)
        cell.addSubview(ingridientLabel)
        cell.addSubview(deleteButton)
        
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_ :)), for: .touchUpInside)
        
        let labelHeight = ingridients[indexPath.row].getHeightForLabel(font: .systemFont(ofSize: 14, weight: .semibold), width: view.width - 120) + 10
        ingridientLabel.frame = CGRect(x: 20, y: 0, width: cell.width - 40, height: labelHeight)
        dotImageView.frame = CGRect(x: 0, y: 0, width: 10, height: labelHeight)
        deleteButton.frame = CGRect(x: cell.width - 20, y: (cell.height - 20) / 2, width: 20, height: 20)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let labelHeight = ingridients[indexPath.row].getHeightForLabel(font: .systemFont(ofSize: 14, weight: .semibold), width: view.width - 120) + 10
        return labelHeight
    }
    
}

extension AddViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoriesTextField.text = categories[row].name
        categoriesTextField.resignFirstResponder()
    }
    
}

extension AddViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
            categoriesPickerView.selectRow(0, inComponent: 0, animated: true)
            categoriesTextField.text = categories[0].name
        }
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
