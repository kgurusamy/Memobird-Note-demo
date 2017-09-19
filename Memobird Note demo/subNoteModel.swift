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
    var imageName: String
    var text : String
    
    init(type : Int, imageName:String, text:String)
    {
        self.type = type
        self.imageName = imageName
        self.text = text
    }
    
    // MARK: NSCoding
    
    required init(coder decoder: NSCoder) {
            self.type = decoder.decodeInteger(forKey: "type")
            self.imageName = (decoder.decodeObject(forKey: "imageName") as? String) ?? ""
            self.text = (decoder.decodeObject(forKey: "text") as? String) ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.type, forKey: "type")
        coder.encode(self.imageName, forKey: "imageName")
        coder.encode(self.text, forKey: "text")
    }

    
}
