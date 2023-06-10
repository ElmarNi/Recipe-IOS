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
        
        view.backgroundColor = .systemBackground
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.width, height: 120)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RecommendedRecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedRecipeCollectionViewCell.identifier)
        collectionView.register(CategoryHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CategoryHeaderCollectionReusableView.identifier)
        view.addSubview(collectionView)
        view.addSubview(spinner)
        getRecipesByCategory()
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) ->
    UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderCollectionReusableView.identifier,
            for: indexPath) as? CategoryHeaderCollectionReusableView
        else {
            return UICollectionReusableView()
        }
        header.configure(with: category)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) ->
    CGSize
    {
        let nameLabelHeight = category.name.getHeightForLabel(font: .systemFont(ofSize: 20, weight: .semibold), width: view.width - 20)
        
        return CGSize(width: view.width, height: nameLabelHeight + view.width / 2 + 25)
//        return CGSize(width: 0, height: 0)
    }
    
}
