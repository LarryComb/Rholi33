//
//  PhotosCollectionViewController.swift
//  R.HOLI
//
//  Created by LARRY COMBS on 4/9/16.
//  Copyright © 2016 Larry Combs. All rights reserved.
//

import UIKit

class PhotosCollectionViewController:  UICollectionViewController {
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeGesture.direction = .Right
        view.addGestureRecognizer(swipeGesture)
        
        
        
    }
    
    

    func swiped(gesture:UISwipeGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  

}
