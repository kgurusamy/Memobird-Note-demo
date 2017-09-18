//
//  subNoteModel.swift
//  Memobird Note Demo
//
//  Created by Oottru Technologies on 18/09/17.
//  Copyright © 2017 Oottru Technologies. All rights reserved.
//

import Foundation
import UIKit

class subNote : NSObject,NSCoding {

    var type: Int // 0 - text, 1 - image
    var image: UIImage?
    var text : String
    
    init(type : Int, image:UIImage?, text:String)
    {
        self.type = type
        self.image = image
        self.text = text
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder decoder: NSCoder) {
        guard
            let type = decoder.decodeObject(forKey: "type") as? Int,
            let image = decoder.decodeObject(forKey: "image") as? UIImage,
            let text = decoder.decodeObject(forKey: "text") as? String
            else { return nil }
        
        self.init(
            type : type,
            image: image,
            text: text
        )
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.type, forKey: "type")
        coder.encode(self.image, forKey: "image")
        coder.encode(self.text, forKey: "text")
    }

    
}
