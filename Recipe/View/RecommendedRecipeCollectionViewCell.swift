//
//  RecommendedRecipeCollectionViewCell.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 06.06.23.
//

import UIKit

class RecommendedRecipeCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedRecipeCollectionViewCell"
    
    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let peopleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    private let peopleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let timeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray6
        contentView.addSubview(peopleImageView)
        contentView.addSubview(peopleLabel)
        contentView.addSubview(timeImageView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(authorNameLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(image)
        image.addSubview(spinner)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        peopleLabel.sizeToFit()
        timeLabel.sizeToFit()
        authorNameLabel.sizeToFit()
        nameLabel.sizeToFit()
        
        image.frame = CGRect(x: 10, y: 5, width: contentView.height - 10, height: contentView.height - 10)
        spinner.frame = CGRect(x: image.width / 2, y: image.height / 2, width: 0, height: 0)
        nameLabel.frame = CGRect(x: image.right + 5, y: 10, width: contentView.width - image.width - 20, height: 25)
        authorNameLabel.frame = CGRect(x: image.right + 5, y: nameLabel.bottom, width: contentView.width - image.width - 20, height: 20)
        peopleImageView.frame = CGRect(x: image.right + 5, y: contentView.bottom - 30, width: 23, height: 20)
        peopleLabel.frame = CGRect(x: peopleImageView.right, y: contentView.bottom - 30, width: peopleLabel.width, height: 20)
        timeImageView.frame = CGRect(x: peopleLabel.right + 5, y: contentView.bottom - 30, width: 23, height: 20)
        timeLabel.frame = CGRect(x: timeImageView.right + 3, y: contentView.bottom - 30, width: timeLabel.width, height: 20)
    }
    
    public func configure(with model: Recipe) {
        peopleLabel.text = "\(model.people)"
        timeLabel.text = model.time
        nameLabel.text = model.name
        authorNameLabel.text = model.authorName
        guard let url = URL(string: model.imageUrl ?? "") else { return }
        image.download(from: url, sessionDelegate: self) {[weak self] in
            self?.spinner.stopAnimating()
        }
    }
}
