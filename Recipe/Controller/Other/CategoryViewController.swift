//
//  CategoryViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 10.06.23.
//

import UIKit

class CategoryViewController: UIViewController {
    private let category: Category
    private var recipes = [Recipe]()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let titleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    init(category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.name
        view.backgroundColor = .systemBackground
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.width, height: 120)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RecommendedRecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedRecipeCollectionViewCell.identifier)
        view.addSubview(collectionView)
        view.addSubview(spinner)
        getRecipesByCategory()
        guard let isSignedIn = UserDefaults.standard.value(forKey: "isSignedIn") as? Bool else { return }
        
        if isSignedIn {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
            collectionView.addGestureRecognizer(gesture)
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        spinner.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        spinner.center = view.center
        collectionView.frame = view.bounds
    }
    
    private func getRecipesByCategory() {
        DispatchQueue.main.async {
            ApiCaller.shared.getRecipesByCategoryId(categoryId: self.category.id, sessionDelegate: self) {[weak self] result in
                switch result {
                case .success(let model):
                    self?.recipes = model
                    self?.collectionView.reloadData()
                    self?.spinner.stopAnimating()
                case .failure(_):
                    showAlert(title: "Error", message: "Can't get categories", target: self)
                }
            }
        }
    }
    
    @objc private func longPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: collectionView)
            guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
            
            let recipe = recipes[indexPath.row]
            
            let alertController = UIAlertController(title: "Add to bookmarks", message: "Would you like add \(recipe.name) to bookmarks?", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
                print("OK")
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true)
        }
    }
    
}

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedRecipeCollectionViewCell.identifier, for: indexPath)
                as? RecommendedRecipeCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.configure(with: recipes[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipeVC = RecipeViewController(recipe: recipes[indexPath.row])
        navigationController?.pushViewController(recipeVC, animated: true)
    }
    
}
