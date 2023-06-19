//
//  RecipeViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 11.06.23.
//

import UIKit

class RecipeViewController: UIViewController {
    
    private let recipe: Recipe
    private var ingridients = [String]()
    
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
    
    private let scrollView = UIScrollView()
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.ingridients = recipe.ingridients.components(separatedBy: ",")
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
        configure()
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
        
        guard let isSignedIn = UserDefaults.standard.value(forKey: "isSignedIn") as? Bool else { return }
        
        if isSignedIn {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(image: UIImage(systemName: "suit.heart"),
                                style: .plain,
                                target: self,
                                action: #selector(heartButtonTaped)),
                UIBarButtonItem(image: UIImage(systemName: "bookmark"),
                                style: .plain,
                                target: self,
                                action: #selector(bookmarkButtonTaped))
            ]
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        timeLabel.frame = CGRect(x: timeImageView.right, y: 0, width: timeLabel.width, height: 25)
        timeStackView.frame = CGRect(x: view.width - (timeLabel.width + timeImageView.width + 10),
                                     y: image.bottom + 5,
                                     width: timeLabel.width + timeImageView.width,
                                     height: 25)
        
        peopleImageView.frame = CGRect(x: 0, y: 0, width: 23, height: 25)
        peopleLabel.frame = CGRect(x: peopleImageView.right, y: 0, width: peopleLabel.width, height: 25)
        peoplesStackView.frame = CGRect(x: view.width - (peopleLabel.width + peopleImageView.width + timeStackView.width + 20),
                                        y: image.bottom + 5,
                                        width: peopleLabel.width + peopleImageView.width,
                                        height: 25)
        
        heartImageView.frame = CGRect(x: 0, y: 0, width: 28, height: 25)
        likesLabel.frame = CGRect(x: heartImageView.right, y: 0, width: likesLabel.width, height: 25)
        likesStackView.frame = CGRect(x: view.width - (likesLabel.width + likesLabel.width + timeStackView.width + peoplesStackView.width + 30),
                                      y: image.bottom + 5,
                                      width: likesLabel.width + likesLabel.width,
                                      height: 25)
        
        nameLabel.frame = CGRect(x: 10, y: likesStackView.bottom + 10, width: view.width - 20, height: nameLabel.height)
        authorNameLabel.frame = CGRect(x: 10, y: nameLabel.bottom + 5, width: view.width - 20, height: authorNameLabel.height)
        
        var tableHeight:CGFloat = 0
        for ingridient in ingridients {
            tableHeight += ingridient.getHeightForLabel(font: .systemFont(ofSize: 14, weight: .semibold), width: view.width - 100) + 10
        }
        
        tableListView.frame = CGRect(x: 40, y: authorNameLabel.bottom + 10, width: view.width - 80, height: tableHeight)
        
        let descriptionLabelHeight = descriptionLabel.text?.getHeightForLabel(font: .systemFont(ofSize: 16), width: view.width - 20)
        descriptionLabel.frame = CGRect(x: 10, y: tableListView.bottom + 10, width: view.width - 20, height: descriptionLabelHeight ?? 0)
        let scrollViewHeight = image.height + likesStackView.height + nameLabel.height + authorNameLabel.height + descriptionLabel.height + tableHeight + 60
        scrollView.contentSize = CGSize(width: view.width, height: scrollViewHeight)
    }
    
    @objc private func heartButtonTaped() {
        print("Hear tapped in recipe")
    }
    
    @objc private func bookmarkButtonTaped() {
        print("Bookmark tapped in recipe")
    }
    
    private func configure() {
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
        let labelHeight = ingridients[indexPath.row].getHeightForLabel(font: .systemFont(ofSize: 14, weight: .semibold), width: view.width - 100) + 10
        ingridientLabel.frame = CGRect(x: dotImageView.right + 10, y: 0, width: cell.width - dotImageView.width - 10, height: labelHeight)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let labelHeight = ingridients[indexPath.row].getHeightForLabel(font: .systemFont(ofSize: 16, weight: .semibold), width: view.width - 100) + 10
        return labelHeight
    }
    
}
