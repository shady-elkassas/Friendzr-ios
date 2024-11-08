//
//  CustomCropperViewController.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/03/2022.
//

import Foundation
import QCropper

class CustomCropperViewController: CropperViewController {

    lazy var customOverlay: CustomOverlay = {
        let co = CustomOverlay(frame: self.view.bounds)
        co.gridLinesCount = 0

        return co
    }()

    override var overlay: Overlay {
        get {
            return customOverlay
        }

        set {
            if let co = newValue as? CustomOverlay {
                customOverlay = co
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isCropBoxPanEnabled = false
        topBar.isHidden = true
        angleRuler.isHidden = true
        aspectRatioPicker.isHidden = true
    }

    override func resetToDefaultLayout() {
        super.resetToDefaultLayout()

        aspectRatioLocked = true
        if Defaults.isIPhoneLessThan2500 {
            setAspectRatioValue(1.7)
        }else {
            setAspectRatioValue(1.39)
        }
    }
}
