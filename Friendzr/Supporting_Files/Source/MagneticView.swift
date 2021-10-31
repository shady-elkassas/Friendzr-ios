//
//  MagneticView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/08/2021.
//

import Foundation
import SpriteKit

public class MagneticView: SKView {
    
    @objc
    public lazy var magnetic: Magnetic = { [unowned self] in
        let scene = Magnetic(size: self.bounds.size)
        self.presentScene(scene)
        return scene
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        _ = magnetic
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        magnetic.size = bounds.size
        magnetic.backgroundColor = .clear
    }
    
}
