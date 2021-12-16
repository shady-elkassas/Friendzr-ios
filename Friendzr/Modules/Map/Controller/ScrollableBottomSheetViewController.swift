//
//  ScrollableBottomSheetViewController.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/12/2021.
//

import UIKit

class ScrollableBottomSheetViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let fullView: CGFloat = 50
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 150
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(ScrollableBottomSheetViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            let frame = self?.view.frame
            let yComponent = self?.partialView
            self?.view.frame = CGRect(x: 0, y: yComponent!, width: frame!.width, height: frame!.height - 100)
            })
        
        print("self?.view.frame\(self.view.frame)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)

        let y = self.view.frame.minY
        
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }

//        print("\(y)")
        print("\(translation.y)")
        print("self.view.frame>>\(self.view.frame)")
        print("velocity.y>>\(velocity.y)")

//
//        if recognizer.state == .ended {
//            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
//
//            duration = duration > 1.3 ? 1 : duration
//
//            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
//                if  velocity.y >= 0 {
//                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
//                } else {
//                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
//                }
//            }, completion: { [weak self] _ in
//                if ( velocity.y < 0 ) {
//                    self?.collectionView.isScrollEnabled = true
//                }
//            })
//        }
    }
}

extension ScrollableBottomSheetViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
}

//extension ScrollableBottomSheetViewController:UICollectionViewDataSource {
//
//}

extension ScrollableBottomSheetViewController: UIGestureRecognizerDelegate {

    // Solution
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y

        let y = view.frame.minY
        if (y == fullView && collectionView.contentOffset.y == 0 && direction > 0) || (y == partialView) {
            collectionView.isScrollEnabled = false
        } else {
            collectionView.isScrollEnabled = true
        }
        
        return false
    }
    
}

