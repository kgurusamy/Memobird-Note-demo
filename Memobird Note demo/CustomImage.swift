//
//  CustomImage.swift
//  Memobird Note Demo
//
//  Created by Oottru Technologies on 11/09/17.
//  Copyright © 2017 Apoorv Mote. All rights reserved.
//

import UIKit
import Foundation

class customImage : NSObject,NSCoding {
    
    var image: UIImage
    var imageDescription : String
    
    init(image:UIImage, imageDescription:String)
    {
        self.image = image
        self.imageDescription = imageDescription
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder decoder: NSCoder) {
        guard let image = decoder.decodeObject(forKey: "image") as? UIImage,
            let imageDescription = decoder.decodeObject(forKey: "imageDescription") as? String
            else { return nil }
        
        self.init(
            image: image,
            imageDescription: imageDescription
        )
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.image, forKey: "image")
        coder.encode(self.imageDescription, forKey: "imageDescription")
    }

}
