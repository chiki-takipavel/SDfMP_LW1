//
//  UIImageExtensions.swift
//  Phonebook
//
//  Created by Pavel Miskevich on 24.03.2021.
//

import UIKit


extension UIImage {
    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = self.size
        let aspectRatio =  size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {
                width = dimension
                height = dimension / aspectRatio
            } else {
                height = dimension
                width = dimension * aspectRatio
            }
            
        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
    
    func cropedToSquare() -> UIImage? {
        let image = self
        
        if let cgImage = image.cgImage {
            var imageHeight = image.size.height
            var imageWidth = image.size.width
            
            if imageHeight > imageWidth {
                imageHeight = imageWidth
            }
            else {
                imageWidth = imageHeight
            }
            
            let size = CGSize(width: imageWidth, height: imageHeight)
            
            let refWidth : CGFloat = CGFloat(cgImage.width)
            let refHeight : CGFloat = CGFloat(cgImage.height)
            
            let x = (refWidth - size.width) / 2
            let y = (refHeight - size.height) / 2
            
            let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
            if let imageRef = cgImage.cropping(to: cropRect) {
                return UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
            }
        }
        
        return nil
    }
}
