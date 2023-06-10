//
//  CategoryHeaderCollectionReusableView.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 10.06.23.
//

import UIKit

class CategoryHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "CategoryHeaderCollectionReusableView"
    
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
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(image)
        addSubview(nameLabel)
        image.addSubview(spinner)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        image.frame = CGRect(x: (width - width / 1.2) / 2, y: 10, width: width / 1.2, height: width / 2)
        spinner.frame = CGRect(x: image.width / 2, y: image.height / 2, width: 0, height: 0)
        let nameLabelHeight = nameLabel.text?.getHeightForLabel(font: .systemFont(ofSize: 20, weight: .semibold), width: width - 20)
        nameLabel.frame = CGRect(x: 10, y: image.bottom + 5, width: width - 20, height: nameLabelHeight ?? 0)
    }
    
    public func configure(with model: Category) {
        nameLabel.text = model.name
        guard let url = URL(string: model.imageUrl ?? "") else { return }
        image.download(from: url, sessionDelegate: self) { [weak self] in
            self?.spinner.stopAnimating()
        }
    }
}
