//
//  ImageViewController.swift
//  CocoaPodsTest_10_18
//
//  Created by Larry Combs on 12/6/15.
//  Copyright © 2015 Larry Combs. All rights reserved.
//

import UIKit
import Parse

protocol ImageViewControllerDelegate: class {
    
    func imageViewControllerDidPressBackButton(controller: ImageViewController)
    func imageViewControllerDidPressLikeButton(controller: ImageViewController)
    
    
}


class ImageViewController: UIViewController {
    
    var image: UIImage?
    var object : PFObject?
    
    private var imageView: UIImageView!
    
    private var backButton: UIButton!
    
    private var likeButton: UIButton!
    
    private var counterNumber = 0
    
    weak var delegate: ImageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        counterNumber = (object?["counterNumber"] as? NSNumber)?.integerValue ?? 0
        
        imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        self.view.addSubview(imageView)
        
        backButton = UIButton(frame: CGRectMake(10, 10, 50, 50))
        backButton.setTitle("X", forState: .Normal)
        backButton.setTitle("O", forState: UIControlState.Highlighted)
        backButton.addTarget(self, action: "didPressBackButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        
    }
    
     func didPressBackButton(sender: AnyObject) {
        delegate?.imageViewControllerDidPressBackButton(self)
        
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        
    
    
        likeButton = UIButton(frame: CGRectMake(50, 60, 450, 1000))
        likeButton.setImage(UIImage(named: "LikeButton"), forState: .Normal)
        likeButton.setTitle("LOVED", forState: .Highlighted)
        likeButton.addTarget(self, action: "didPressLikeButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(likeButton)
        if counterNumber > 0 {
            likeButton.setTitle("LOVED \(counterNumber)", forState: UIControlState.Normal)
        }
        
        
    
    }
    
    func didPressLikeButton(sender:UIButton){
        counterNumber += 1
        object?["counterNumber"] = NSNumber(integer: counterNumber)
            object?.saveInBackground()
        
        likeButton.setTitle("LOVED \(counterNumber)", forState: UIControlState.Normal)
        delegate?.imageViewControllerDidPressLikeButton(self)
    }
    
    
    

    
}
