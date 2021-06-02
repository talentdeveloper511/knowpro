//
//  KPContactGradientView.swift
//  KnowPro
//
//  Created by John Gabelmann on 7/10/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import UIKit

class KPContactGradientView: UIView {
    
    var gradientStartingColor: UIColor?
    var gradientEndingColor: UIColor?
    
    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let gradient = self.layer as? CAGradientLayer else { return }
        gradient.colors = [
            gradientStartingColor?.cgColor ?? UIColor(named: KPConstants.Color.LogoRed)!.cgColor,
            gradientEndingColor?.cgColor ?? UIColor(named: KPConstants.Color.LogoRed)!.cgColor
        ]
        
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let gradient = self.layer as? CAGradientLayer else { return }
        gradient.colors = [
            gradientStartingColor?.cgColor ?? UIColor(named: KPConstants.Color.LogoRed)!.cgColor,
            gradientEndingColor?.cgColor ?? UIColor(named: KPConstants.Color.LogoRed)!.cgColor
        ]
        
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x: 1, y: 1)
    }
    
}
