//
//  ViewController.swift
//  Drawing App
//
//  Created by roycetanjiashing on 17/9/16.
//  Copyright © 2016 examplecompany. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var toolIcon: UIButton!
    @IBOutlet weak var colors: UIStackView!
    @IBOutlet weak var tools: UIStackView!
    @IBOutlet weak var colors_bg: UIView!
    @IBOutlet weak var highlight: UIView!
    
    var bannerView: GADBannerView!
    
    var lastPoint = CGPoint.zero
    var swiped = false
    var isInMenu = false
    
    var currentColor:UIButton!
    var red:CGFloat = 0.0
    var green:CGFloat = 0.0
    var blue:CGFloat = 0.0
    var alpha:CGFloat = 1.0
    
    var tool:UIImageView!
    var isDrawing = true
    var temp:CGFloat = 5
    var brushSize:CGFloat = 5
    var selectedImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tool = UIImageView()
        tool.frame = CGRect(x: self.view.bounds.size.width, y: self.view.bounds.size.height, width: 38, height: 38)
        tool.image = #imageLiteral(resourceName: "paintBrush")
        self.view.addSubview(tool)
        
        for i in 0..<colors.subviews.count {
            colors.subviews[i].layer.cornerRadius = colors.subviews[i].frame.size.height / 2
            colors.subviews[i].layer.masksToBounds = true
        }
        
        DispatchQueue.main.async {
            self.highlight.center.x = self.colors.frame.origin.x + 10
            self.highlight.frame.origin.y = self.colors_bg.frame.origin.y + self.colors_bg.frame.size.height + 2
        }
        
        currentColor = colors.subviews[0] as? UIButton
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-7352520433824678/7349961813"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isInMenu {
            swiped = false
            UIView.animate(withDuration: 0.5) {
                self.colors.alpha = 0
                self.colors_bg.alpha = 0
                self.tools.alpha = 0
                self.highlight.alpha = 0
            }
            if let touch = touches.first {
                lastPoint = touch.location(in: self.view)
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.view.subviews.last!.alpha = 0
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.view.subviews.last!.removeFromSuperview()
                self.isInMenu = false
            }
        }
    }
    
    func drawLines(fromPoint:CGPoint,toPoint:CGPoint) {
        UIGraphicsBeginImageContext(self.view.frame.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        tool.center = toPoint
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushSize)
        context?.setStrokeColor(UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor)
        
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            drawLines(fromPoint: lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.5) {
            self.colors.alpha = 1
            self.colors_bg.alpha = 1
            self.tools.alpha = 1
            self.highlight.alpha = 1
        }
        if !swiped {
            drawLines(fromPoint: lastPoint, toPoint: lastPoint)
        }
    }
    @IBAction func reset(_ sender: AnyObject) {
        self.imageView.image = nil
        print(self.highlight.center.x)
    }
    @IBAction func save(_ sender: AnyObject) {
        isInMenu = true
        let bg = UIVisualEffectView(frame: self.view.bounds)
        bg.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        bg.alpha = 0
        self.view.addSubview(bg)
        let bg_sub = UIView(frame: CGRect(x: 16, y: bg.frame.size.height, width: 300, height: 300))
        bg_sub.center.x = bg.center.x
        bg.contentView.addSubview(bg_sub)
        let drawer = UIButton(frame: CGRect(x: 0, y: 0, width: bg_sub.frame.size.width, height: 150))
        drawer.backgroundColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
        drawer.setTitle("Draw over an image", for: UIControl.State.normal)
        drawer.setTitleColor(UIColor.white, for: UIControl.State.normal)
        drawer.titleLabel?.font = UIFont.systemFont(ofSize: 35)
        drawer.layer.cornerRadius = 20
        drawer.layer.masksToBounds = true
        drawer.addTarget(self, action: #selector(self.addImage(_:)), for: UIControl.Event.touchUpInside)
        bg_sub.addSubview(drawer)
        let save = UIButton(frame: CGRect(x: 0, y: bg_sub.frame.size.height / 2, width: bg_sub.frame.size.width, height: 150))
        save.backgroundColor = UIColor(red: (75 / 255), green: (66 / 255), blue: (244 / 255), alpha: 1)
        save.setTitle("Save your image", for: UIControl.State.normal)
        save.setTitleColor(UIColor.white, for: UIControl.State.normal)
        save.layer.cornerRadius = 20
        save.layer.masksToBounds = true
        save.titleLabel?.font = UIFont.systemFont(ofSize: 35)
        save.addTarget(self, action: #selector(self.saveDrawing(_:)), for: UIControl.Event.touchUpInside)
        bg_sub.addSubview(save)
        UIView.animate(withDuration: 0.5) {
            bg.alpha = 1
            bg_sub.center = bg.center
        }
    }
    
    @objc func addImage(_ sender: UIButton!) {
        UIView.animate(withDuration: 0.5) {
            sender.superview!.superview!.superview!.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.view.subviews.last!.removeFromSuperview()
            self.isInMenu = false
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func saveDrawing(_ sender: UIButton!) {
        if let image = self.imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            sender.setTitle("Success!", for: UIControl.State.normal)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                UIView.animate(withDuration: 0.5) {
                    sender.superview!.superview!.superview!.alpha = 0
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.view.subviews.last!.removeFromSuperview()
                    self.isInMenu = false
                }
            }
        }
    }
    
    @IBAction func erase(_ sender: AnyObject) {
        if (isDrawing) {
            (red,green,blue) = (1,1,1)
            tool.image = #imageLiteral(resourceName: "EraserIcon")
            toolIcon.setImage(#imageLiteral(resourceName: "paintBrush"), for: .normal)
            self.temp = self.brushSize
            self.brushSize = 20
        } else {
            (red,green,blue) = (0,0,0)
            tool.image = #imageLiteral(resourceName: "paintBrush")
            toolIcon.setImage(#imageLiteral(resourceName: "EraserIcon"), for: .normal)
            self.brushSize = self.temp
        }
        
        isDrawing = !isDrawing
    }
    
    @IBAction func settings(_ sender: AnyObject) {}
    
    @IBAction func colorsPicked(_ sender: AnyObject) {
        currentColor = sender as? UIButton
        UIView.animate(withDuration: 1) {
            self.highlight.center.x = sender.center.x + self.colors.frame.origin.x
        }
        
        if sender.tag == 0 {
            (red,green,blue) = (1,0,0)
        } else if sender.tag == 1 {
            (red,green,blue) = (0,1,0)
        } else if sender.tag == 2 {
            (red,green,blue) = (0,0,1)
        } else if sender.tag == 3 {
            (red,green,blue) = (1,0,1)
        } else if sender.tag == 4 {
            (red,green,blue) = (1,1,0)
        } else if sender.tag == 5 {
            (red,green,blue) = (0,1,1)
        } else if sender.tag == 6 {
            (red,green,blue) = (1,1,1)
        } else if sender.tag == 7 {
            (red,green,blue) = (0,0,0)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let settingsVC = segue.destination as! SettingsVC
        settingsVC.delegate = self
        settingsVC.red = red
        settingsVC.green = green
        settingsVC.blue = blue
        settingsVC.opacity = alpha
        settingsVC.brushSize = brushSize
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.highlight.frame.origin.y = self.colors_bg.frame.size.height + self.colors_bg.frame.origin.y + 2
            self.colorsPicked(self.currentColor)
            print("The thigs got ran?")
        }
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.addConstaintsToSuperview(leftOffset: (view.frame.size.width / 2) - 160, topOffset: view.frame.size.height - 50)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      // Add banner to view and add constraints as above.
      addBannerViewToView(bannerView)
    }
}

extension ViewController:UINavigationControllerDelegate,UIImagePickerControllerDelegate,SettingsVCDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagePicked = info[.originalImage] as? UIImage {
            // We got the user's image
            self.selectedImage = imagePicked
            self.imageView.image = selectedImage
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func settingsViewControllerDidFinish(_ settingsVC: SettingsVC) {
        self.red = settingsVC.red
        self.green = settingsVC.green
        self.blue = settingsVC.blue
        self.alpha = settingsVC.opacity
        self.brushSize = settingsVC.brushSize
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

extension UIView {

    public func addConstaintsToSuperview(leftOffset: CGFloat, topOffset: CGFloat) {

        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: self,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self.superview,
                           attribute: .leading,
                           multiplier: 1,
                           constant: leftOffset).isActive = true

        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self.superview,
                           attribute: .top,
                           multiplier: 1,
                           constant: topOffset).isActive = true
    }

    public func addConstaints(height: CGFloat, width: CGFloat) {

        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: self,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: height).isActive = true
        

        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: width).isActive = true
        
    }
}
