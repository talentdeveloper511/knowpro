//
//  KPGradientView.swift
//  KnowPro
//
//  Created by John Gabelmann on 6/28/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit

class KPGradientView: UIView {
    
    var gradientColor: UIColor?

    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let gradient = self.layer as? CAGradientLayer else { return }
        gradient.colors = [
            UIColor.clear.cgColor,
            gradientColor?.cgColor ?? UIColor(named: KPConstants.Color.LogoRed)!.cgColor
        ]
        
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let gradient = self.layer as? CAGradientLayer else { return }
        gradient.colors = [
            UIColor.clear.cgColor,
            gradientColor?.cgColor ?? UIColor(named: KPConstants.Color.LogoRed)!.cgColor
        ]
        
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
    }

}
