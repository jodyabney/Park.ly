//
//  RoundButton.swift
//  Park.ly
//
//  Created by Jody Abney on 5/18/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit

@IBDesignable

class RoundButton: UIButton {

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        customizeView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeView()
    }
    
    func customizeView() {
        //MARK: Corner Radius
        self.layer.cornerRadius = self.frame.height / 2
        
        //MARK: Shadow
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
    }

}
