//
//  Extensions.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 01.06.23.
//

import Foundation
import UIKit

extension UIView {
    var width: CGFloat{
        return frame.size.width
    }
    
    var height: CGFloat{
        return frame.size.height
    }
    
    var left: CGFloat{
        return frame.origin.x
    }
    
    var right: CGFloat{
        return left + width
    }

    var top: CGFloat{
        return frame.origin.y
    }
    
    var bottom: CGFloat{
        return top + height
    }
}

extension String {
    func getHeightForLabel(font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return boundingBox.height
    }
}

extension UIImageView {
    func downloaded(from url: URL, sessionDelegate: URLSessionDelegate, completion: (() -> Void)? = nil) {
        URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: sessionDelegate,
            delegateQueue: OperationQueue.main).dataTask(with: url)
        { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                self.image = UIImage(systemName: "photo")
                completion?()
                return
            }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
                completion?()
            }
        }.resume()
    }
}

func showAlert(title: String, message: String, target: UIViewController?) {
    guard let target = target else { return }
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    target.present(alert, animated: true)
}
