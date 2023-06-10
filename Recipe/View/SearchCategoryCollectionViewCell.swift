//
//  SearchCategoryCollectionViewCell.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 09.06.23.
//

import UIKit

class SearchCategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "SearchCategoryCollectionViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 4
        contentView.addSubview(nameLabel)
        contentView.addSubview(image)
        image.addSubview(spinner)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 5, y: contentView.height - 25, width: contentView.width - 10, height: 20)
        image.frame = CGRect(x: (contentView.width - 80) / 2, y: 10, width: contentView.width - 40, height: contentView.width - 40)
        spinner.frame = CGRect(x: image.width / 2, y: image.height / 2, width: 0, height: 0)
        
    }
    
    public func configure(with model: Category) {
        nameLabel.text = model.name
        guard let url = URL(string: model.iconUrl ?? "") else { return }
        image.download(from: url, sessionDelegate: self) { [weak self] in
            self?.spinner.stopAnimating()
        }
    }
}
