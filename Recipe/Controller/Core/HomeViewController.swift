//
//  HomeViewController.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 31.05.23.
//

import UIKit

enum SectionType {
    case categories(viewModels: [Category])
    case popularRecipes(viewModels: [Recipe])
    case recommendedRecipes(viewModels: [Recipe])
    var title: String {
        switch self {
        case .categories: return "Categories"
        case .popularRecipes: return "Get Inspired with Tasty Recipes"
        case .recommendedRecipes: return "Cook Like a Pro"
        }
    }
}

class HomeViewController: UIViewController {
    
    private var sections = [SectionType]()
    private var likedRecipes = [Recipe]()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
                return HomeViewController.configureSections(section: sectionIndex)
            }))
        collectionView.backgroundColor = .systemBackground
        collectionView.isPagingEnabled = false
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.register(PopularRecipeCollectionViewCell.self, forCellWithReuseIdentifier: PopularRecipeCollectionViewCell.identifier)
        collectionView.register(RecommendedRecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedRecipeCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderCollectionReusableView.identifier)
        return collectionView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        view.addSubview(spinner)
        
        guard let isSignedIn = UserDefaults.standard.value(forKey: "isSignedIn") as? Bool else { return }
        if isSignedIn {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
            let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
            tap.numberOfTapsRequired = 2
            tap.delaysTouchesBegan = true
            collectionView.addGestureRecognizer(longPressGesture)
            collectionView.addGestureRecognizer(tap)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        spinner.startAnimating()
        getDatas()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        spinner.center = view.center
    }
    
    @objc private func longPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: collectionView)
            guard let indexPath = collectionView.indexPathForItem(at: point), indexPath.section != 0 else { return }
            var recipe: Recipe?
            switch sections[indexPath.section] {
            case .recommendedRecipes(let model):
                recipe = model[indexPath.row]
            case .popularRecipes(let model):
                recipe = model[indexPath.row]
            default: break
            }
            
            let alertController = UIAlertController(title: "Add to bookmarks", message: "Would you like add \(recipe?.name ?? "") to bookmarks?", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
                DispatchQueue.main.async {
                    guard let userId = UserDefaults.standard.value(forKey: "userId") as? String,
                          let recipe = recipe
                    else { return }
                    ApiCaller.shared.addBookmark(userId: userId, recipeId: recipe.id ?? 0, sessionDelegate: self) { result in
                        if result {
                            showAlert(title: "Success", message: "Recipe added to bookmarks", target: self)
                        }
                        else {
                            showAlert(title: "Error", message: "Recipe not added to bookmarks", target: self)
                        }
                    }
                }
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true)
        }
    }
    
    @objc private func doubleTap(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point), indexPath.section != 0 else { return }
        var recipe: Recipe?
        switch sections[indexPath.section] {
        case .recommendedRecipes(let model):
            recipe = model[indexPath.row]
        case .popularRecipes(let model):
            recipe = model[indexPath.row]
        default: break
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let userId = UserDefaults.standard.value(forKey: "userId") as? String,
                  let recipe = recipe
            else { return }
            var isLiked = false
            self?.likedRecipes.forEach { item in
                if item.id == recipe.id {
                    isLiked = true
                }
            }
            if isLiked { return }
            ApiCaller.shared.like(userId: userId, recipeId: recipe.id ?? 0, sessionDelegate: self!) { result in
                if result {
                    switch self?.sections[indexPath.section] {
                    case .popularRecipes(_):
                        guard let cell = self?.collectionView.cellForItem(at: indexPath) as? PopularRecipeCollectionViewCell else { return }
                        cell.like(likes: (recipe.likes + 1))
                    case .recommendedRecipes(_):
                        guard let cell = self?.collectionView.cellForItem(at: indexPath) as? RecommendedRecipeCollectionViewCell else { return }
                        cell.like(likes: (recipe.likes + 1))
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func getDatas() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        sections = []
        
        var categories = [Category]()
        var popularRecipes = [Recipe]()
        var recommendedRecipes = [Recipe]()
        var likededRecipes = [Recipe]()
        if let userId = UserDefaults.standard.value(forKey: "userId") as? String {
            ApiCaller.shared.getLikes(userId: userId, sessinDelegate: self) {[weak self] result in
                defer {
                    dispatchGroup.leave()
                }
                switch result {
                case .success(let model):
                    likededRecipes = model
                case .failure(_):
                    showAlert(title: "Error", message: "Can't get is recipe bookmarked", target: self)
                }
            }
        }
        
        ApiCaller.shared.getCategories(sessionDelegate: self) {[weak self] result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let categoriesModel):
                categories = categoriesModel
            case .failure(_):
                showAlert(title: "Error", message: "Can't get categories", target: self)
            }
        }
        
        ApiCaller.shared.getPopularRecipes(sessionDelegate: self) {[weak self] result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let popularRecipesModel):
                popularRecipes = popularRecipesModel
            case .failure(_):
                showAlert(title: "Error", message: "Can't get recipes", target: self)
            }
        }
        
        ApiCaller.shared.getRecommendedRecipes(sessionDelegate: self) {[weak self] result in
            defer {
                dispatchGroup.leave()
            }
            switch result {
            case .success(let recommendedRecipesModel):
                recommendedRecipes = recommendedRecipesModel
            case .failure(_):
                showAlert(title: "Error", message: "Can't get recipes", target: self)
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.configureModels(categories: categories, popularRecipes: popularRecipes, recommendedRecipes: recommendedRecipes)
            self?.likedRecipes = likededRecipes
        }
    }
    
    private func configureModels(categories: [Category], popularRecipes: [Recipe], recommendedRecipes: [Recipe]) {
        sections.append(SectionType.categories(viewModels: categories))
        sections.append(SectionType.popularRecipes(viewModels: popularRecipes))
        sections.append(SectionType.recommendedRecipes(viewModels: recommendedRecipes))
        spinner.stopAnimating()
        collectionView.reloadData()
    }
    
    private static func configureSections(section: Int) -> NSCollectionLayoutSection {
        let supplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )]
        switch section {
        case 0:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                 heightDimension: .fractionalHeight(1)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            //group
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(UIScreen.main.bounds.width / 2 - 20), heightDimension: .absolute(100)),
                repeatingSubitem: item,
                count: 1)
            
            //section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryItems
            return section
        case 1:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                 heightDimension: .fractionalHeight(1)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            //group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2)),
                repeatingSubitem: item,
                count: 2)
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(UIScreen.main.bounds.width - 70), heightDimension: .absolute(300)),
                repeatingSubitem: verticalGroup,
                count: 1)
            
            //section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 7, trailing: 0)
            section.boundarySupplementaryItems = supplementaryItems
            return section
        default:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                 heightDimension: .fractionalHeight(1)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
            
            //group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(120)),
                repeatingSubitem: item,
                count: 1)
            
            //section
            let section = NSCollectionLayoutSection(group: verticalGroup)
            section.boundarySupplementaryItems = supplementaryItems
            return section
        }
    }
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .categories(let model):
            return model.count
        case .popularRecipes(let model):
            return model.count
        case .recommendedRecipes(let model):
            return model.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch  sections[indexPath.section] {
        case .categories(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath)
                    as? CategoryCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: models[indexPath.row])
            return cell
        case .popularRecipes(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularRecipeCollectionViewCell.identifier, for: indexPath)
                    as? PopularRecipeCollectionViewCell else {
                return UICollectionViewCell()
            }
            var isLiked = false
            likedRecipes.forEach { item in
                if item.id == models[indexPath.row].id {
                    isLiked = true
                }
            }
            cell.configure(with: models[indexPath.row], isLiked: isLiked)
            return cell
        case .recommendedRecipes(let models):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedRecipeCollectionViewCell.identifier, for: indexPath)
                    as? RecommendedRecipeCollectionViewCell else {
                return UICollectionViewCell()
            }
            var isLiked = false
            likedRecipes.forEach { item in
                if item.id == models[indexPath.row].id {
                    isLiked = true
                }
            }
            
            cell.configure(with: models[indexPath.row], isLiked: isLiked)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) ->
    UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderCollectionReusableView.identifier,
            for: indexPath) as? HeaderCollectionReusableView
        else {
            return UICollectionReusableView()
        }
        header.configure(with: sections[indexPath.section].title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch sections[indexPath.section]{
            
        case .categories(let model):
            let categoryVC = CategoryViewController(category: model[indexPath.row])
            navigationController?.pushViewController(categoryVC, animated: true)

        case .popularRecipes(let model):
            let recipeVC = RecipeViewController(recipeId: model[indexPath.row].id ?? 0)
            navigationController?.pushViewController(recipeVC, animated: true)
        case .recommendedRecipes(let model):
            let recipeVC = RecipeViewController(recipeId: model[indexPath.row].id ?? 0)
            navigationController?.pushViewController(recipeVC, animated: true)
        }
    }
    
}
