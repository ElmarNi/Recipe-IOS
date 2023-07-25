//
//  RecipeViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 11.06.23.
//

import UIKit

class RecipeViewController: UIViewController {
    
    private var recipeId: Int
    private var ingridients = [String]()
    private var isBookmarked = false
    private var isLiked = false
    private var recipe: Recipe?
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let heartImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private let likesStackView = UIStackView()
    
    private let peopleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let peopleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private let peoplesStackView = UIStackView()
    
    private let timeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private let timeStackView = UIStackView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let tableListView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = false
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        return tableView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .justified
        return label
    }()
    
    private let spinnerMain: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        return spinner
    }()
    
    private let scrollView = UIScrollView()
    
    init(recipeId: Int) {
        self.recipeId = recipeId
//        self.ingridients = recipe.ingridients.components(separatedBy: ",")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        tableListView.delegate = self
        tableListView.dataSource = self
        getRecipe(recipeId: recipeId)
        scrollView.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(image)
        image.addSubview(spinner)
        likesStackView.addArrangedSubview(heartImageView)
        likesStackView.addArrangedSubview(likesLabel)
        scrollView.addSubview(likesStackView)
        peoplesStackView.addArrangedSubview(peopleImageView)
        peoplesStackView.addArrangedSubview(peopleLabel)
        scrollView.addSubview(peoplesStackView)
        timeStackView.addArrangedSubview(timeImageView)
        timeStackView.addArrangedSubview(timeLabel)
        scrollView.addSubview(timeStackView)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(authorNameLabel)
        scrollView.addSubview(tableListView)
        scrollView.addSubview(descriptionLabel)
        view.addSubview(spinnerMain)
        
        guard let isSignedIn = UserDefaults.standard.value(forKey: "isSignedIn") as? Bool,
              let userId = UserDefaults.standard.value(forKey: "userId") as? String else { return }
        
        if isSignedIn {
            isLikedAndBookmarked(userId: userId, recipeId: recipeId)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        spinnerMain.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        spinnerMain.center = view.center
    }
    
    @objc private func heartButtonTaped() {
        if isLiked {
            DispatchQueue.main.async {
                guard let userId = UserDefaults.standard.value(forKey: "userId") as? String else { return }
                ApiCaller.shared.unLike(userId: userId, recipeId: self.recipeId, sessionDelegate: self) {[weak self] result in
                    if result {
                        self?.navigationItem.rightBarButtonItems?[0].image = UIImage(systemName: "suit.heart")
                        self?.isLiked = false
                        if self?.recipe != nil {
                            self?.recipe?.likes -= 1
                            self?.likesLabel.text = "\(self?.recipe?.likes ?? 0)"
                        }
                    }
                    else {
                        showAlert(title: "Error", message: "Something went wrong", target: self)
                    }
                }
            }
        }
        else {
            DispatchQueue.main.async {
                guard let userId = UserDefaults.standard.value(forKey: "userId") as? String else { return }
                ApiCaller.shared.like(userId: userId, recipeId: self.recipeId, sessionDelegate: self) {[weak self] result in
                    if result {
                        self?.navigationItem.rightBarButtonItems?[0].image = UIImage(systemName: "suit.heart.fill")
                        self?.isLiked = true
                        if self?.recipe != nil {
                            self?.recipe?.likes += 1
                            self?.likesLabel.text = "\(self?.recipe?.likes ?? 0)"
                        }
                    }
                    else {
                        showAlert(title: "Error", message: "Something went wrong", target: self)
                    }
                }
            }
        }
        likesLabel.sizeToFit()
        likesLabel.frame = CGRect(x: heartImageView.right, y: 0, width: likesLabel.width, height: 25)    }
    
    @objc private func bookmarkButtonTaped() {
        if isBookmarked {
            DispatchQueue.main.async {
                guard let userId = UserDefaults.standard.value(forKey: "userId") as? String else { return }
                ApiCaller.shared.removeBookmark(userId: userId, recipeId: self.recipeId, sessionDelegate: self) {[weak self] result in
                    if result {
                        showAlert(title: "Success", message: "Recipe removed from bookmarks", target: self)
                        self?.navigationItem.rightBarButtonItems?[1].image = UIImage(systemName: "bookmark")
                        self?.isBookmarked = false
                    }
                    else {
                        showAlert(title: "Error", message: "Recipe not removed from bookmarks", target: self)
                    }
                }
            }
        }
        else {
            DispatchQueue.main.async {
                guard let userId = UserDefaults.standard.value(forKey: "userId") as? String else { return }
                ApiCaller.shared.addBookmark(userId: userId, recipeId: self.recipeId, sessionDelegate: self) {[weak self] result in
                    if result {
                        showAlert(title: "Success", message: "Recipe added to bookmarks", target: self)
                        self?.navigationItem.rightBarButtonItems?[1].image = UIImage(systemName: "bookmark.fill")
                        self?.isBookmarked = true
                    }
                    else {
                        showAlert(title: "Error", message: "Recipe not added to bookmarks", target: self)
                    }
                }
            }
        }
    }
    
    private func getRecipe(recipeId: Int) {
        DispatchQueue.main.async {
            ApiCaller.shared.getRecipe(with: recipeId, sessionDelegate: self) {[weak self] result in
                switch result {
                case .success(let model):
                    self?.recipe = model
                    self?.ingridients = model.ingridients.components(separatedBy: ",")
                    self?.configure(recipe: model)
                    self?.spinnerMain.stopAnimating()
                case .failure(_):
                    self?.spinnerMain.stopAnimating()
                    self?.spinner.stopAnimating()
                    showAlert(title: "Error", message: "Can't get recipe", target: self)
                }
                
            }
        }
    }
    
    private func configure(recipe: Recipe) {
        likesLabel.text = "\(recipe.likes)"
        peopleLabel.text = "\(recipe.people)"
        timeLabel.text = recipe.time
        nameLabel.text = recipe.name
        authorNameLabel.text = recipe.authorName
        descriptionLabel.text = recipe.description
        guard let url = URL(string: recipe.imageUrl ?? "") else { return }
        image.download(from: url, sessionDelegate: self) {[weak self] in
            self?.spinner.stopAnimating()
        }
        updateUI(recipe: recipe)
    }
    
    private func updateUI(recipe: Recipe) {
        likesLabel.sizeToFit()
        peopleLabel.sizeToFit()
        timeLabel.sizeToFit()
        nameLabel.sizeToFit()
        authorNameLabel.sizeToFit()
        tableListView.sizeToFit()
        descriptionLabel.sizeToFit()
        
        scrollView.frame = view.bounds
        image.frame = CGRect(x: 10, y: 10, width: view.width - 20, height: view.width - 20)
        spinner.frame = CGRect(x: image.width / 2, y: image.height / 2, width: 0, height: 0)
        
        timeImageView.frame = CGRect(x: 0, y: 0, width: 23, height: 25)
        timeLabel.frame = CGRect(x: timeImageView.right, y: 0, width: timeLabel.width + 2, height: 25)
        timeStackView.frame = CGRect(x: view.width - (timeLabel.width + timeImageView.width + 12),
                                     y: image.bottom + 5,
                                     width: timeLabel.width + timeImageView.width + 2,
                                     height: 25)
        
        peopleImageView.frame = CGRect(x: 0, y: 0, width: 23, height: 25)
        peopleLabel.frame = CGRect(x: peopleImageView.right, y: 0, width: peopleLabel.width, height: 25)
        peoplesStackView.frame = CGRect(x: view.width - (peopleLabel.width + peopleImageView.width + timeStackView.width + 20),
                                        y: image.bottom + 5,
                                        width: peopleLabel.width + peopleImageView.width,
                                        height: 25)
        
        heartImageView.frame = CGRect(x: 0, y: 0, width: 28, height: 25)
        likesLabel.frame = CGRect(x: heartImageView.right, y: 0, width: max(20, likesLabel.width), height: 25)
        likesStackView.frame = CGRect(x: view.width - (likesLabel.width + likesLabel.width + timeStackView.width + peoplesStackView.width + 30),
                                      y: image.bottom + 5,
                                      width: likesLabel.width + likesLabel.width,
                                      height: 25)
        
        nameLabel.frame = CGRect(x: 10, y: likesStackView.bottom + 10, width: view.width - 20, height: nameLabel.height)
        authorNameLabel.frame = CGRect(x: 10, y: nameLabel.bottom + 5, width: view.width - 20, height: authorNameLabel.height)
        
        var tableHeight:CGFloat = 0
        for ingridient in ingridients {
            tableHeight += ingridient.getHeightForLabel(font: .systemFont(ofSize: 14, weight: .semibold), width: view.width - 110) + 10
        }
        
        tableListView.frame = CGRect(x: 40, y: authorNameLabel.bottom + 10, width: view.width - 80, height: tableHeight)
        
        let descriptionLabelHeight = descriptionLabel.text?.getHeightForLabel(font: .systemFont(ofSize: 16), width: view.width - 20)
        descriptionLabel.frame = CGRect(x: 10, y: tableListView.bottom + 10, width: view.width - 20, height: descriptionLabelHeight ?? 0)
        let scrollViewHeight = image.height + likesStackView.height + nameLabel.height + authorNameLabel.height + descriptionLabel.height + tableHeight + 60
        scrollView.contentSize = CGSize(width: view.width, height: scrollViewHeight)
    }
    
    private func isBookmarked(userId: String, recipeId: Int, completion: @escaping (Bool) -> Void) {
        ApiCaller.shared.getBookmarks(userId: userId, sessinDelegate: self) {[weak self] result in
            switch result {
            case .success(let model):
                model.forEach {[weak self] item in
                    if item.id == recipeId {
                        self?.isBookmarked = true
                    }
                }
                completion(true)
            case .failure(_):
                showAlert(title: "Error", message: "Can't get is recipe bookmarked", target: self)
                completion(false)
            }
        }
    }
    
    private func isLiked(userId: String, recipeId: Int, completion: @escaping (Bool) -> Void) {
        ApiCaller.shared.getLikes(userId: userId, sessinDelegate: self) {[weak self] result in
            switch result {
            case .success(let model):
                model.forEach {[weak self] item in
                    if item.id == recipeId {
                        self?.isLiked = true
                    }
                }
                completion(true)
            case .failure(_):
                showAlert(title: "Error", message: "Can't get is recipe liked", target: self)
                completion(false)
            }
        }
    }
    
    private func isLikedAndBookmarked(userId: String, recipeId: Int) {
        DispatchQueue.main.async {[weak self] in
            self?.isBookmarked(userId: userId, recipeId: recipeId) { result in
                if result {
                    self?.isLiked(userId: userId, recipeId: recipeId) { result in
                        if result {
                            self?.navigationItem.rightBarButtonItems = [
                                UIBarButtonItem(image: UIImage(systemName: self?.isLiked ?? false ? "suit.heart.fill" : "suit.heart"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(self?.heartButtonTaped)),
                                UIBarButtonItem(image: UIImage(systemName: self?.isBookmarked ?? false ? "bookmark.fill" : "bookmark"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(self?.bookmarkButtonTaped))
                            ]
                        }
                    }
                }
            }
        }
    }
    
}

extension RecipeViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        cell.addSubview(dotImageView)
        cell.addSubview(ingridientLabel)
        
        dotImageView.frame = CGRect(x: 0, y: (cell.height - 10) / 2, width: 10, height: 10)
        let labelHeight = ingridients[indexPath.row].getHeightForLabel(font: .systemFont(ofSize: 14, weight: .semibold), width: view.width - 110) + 10
        ingridientLabel.frame = CGRect(x: dotImageView.right + 10, y: 0, width: cell.width - dotImageView.width - 10, height: labelHeight)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let labelHeight = ingridients[indexPath.row].getHeightForLabel(font: .systemFont(ofSize: 14, weight: .semibold), width: view.width - 110) + 10
        return labelHeight
    }
    
}
