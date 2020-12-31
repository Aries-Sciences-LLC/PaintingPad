//
//  ViewController.swift
//  Drawing App
//
//  Created by roycetanjiashing on 17/9/16.
//  Copyright © 2016 examplecompany. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController, GADInterstitialDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var seperator: UIView!
    @IBOutlet weak var drawOverImageShadow: UIView!
    @IBOutlet weak var saveYourDrawingShadow: UIView!
    @IBOutlet weak var shadowPanel: UIView!
    @IBOutlet weak var shadowPanelY: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewLayout: UICollectionViewFlowLayout!
        
    private var dataSource: [[UIColor]] = [[.bittersweet(), .blizzardBlue(), .blue(), .blueBell(), .blueGreen(), .blueViolet(), .blush(), .brickRed()],
                                           [.almond(), .antiqueBrass(), .apricot(), .aquamarine(), .asparagus(), .atomicTangerine(), .bananaMania(), .beaver()],
                                           [.brilliantRose(), .brown(), .burntOrange(), .burntSienna(), .cadetBlue(), .canary(), .caribbeanGreen(), .carnationPink()],
                                           [.cerise(), .cerulean(), .chestnut(), .copperCrayolaAlternateColor(), .copper(), .cornflowerBlue(), .cottonCandy(), .dandelion()],
                                           [.denim(), .desertSand(), .eggplant(), .electricLime(), .fern(), .forestGreen(), .fuchsia(), .fuzzyWuzzy()],
                                           [.gold(), .goldenrod(), .grannySmithApple(), .gray(), .green(), .greenBlue(), .greenYellow(), .hotMagenta()],
                                           [.inchworm(), .indigo(), .jazzberryJam(), .jungleGreen(), .laserLemon(), .lavender(), .lemonYellow(), .lightBlue()]]
    
    private var indexOfCellBeforeDragging = 0
    
    var interstitialAd: GADInterstitial!
    
    var lastPoint = CGPoint.zero
    var swiped = false
    var isInMenu = false
    
    var red:CGFloat = 0.0
    var green:CGFloat = 0.0
    var blue:CGFloat = 0.0
    var alpha:CGFloat = 1.0
    
    var tool:UIImageView!
    var isDrawing = true
    var temp:CGFloat = 5
    var tempRBG: UIColor!
    var brushSize:CGFloat = 5
    var selectedImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        collectionViewLayout.minimumLineSpacing = 0
        
        toolbar.subviews.forEach { (subview) in
            (subview as! UIButton).imageView?.contentMode = .scaleAspectFit
        }
        
        tool = UIImageView()
        tool.frame = CGRect(x: self.view.bounds.size.width, y: self.view.bounds.size.height, width: 38, height: 38)
        self.view.addSubview(tool)
        
        UIColor.systemBackground.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        createAd()
        
        drawOverImageShadow.layer.shadowColor = UIColor.gray.cgColor
        drawOverImageShadow.layer.shadowOffset = CGSize(width: 2, height: 5)
        drawOverImageShadow.layer.shadowRadius = 12
        drawOverImageShadow.layer.shadowOpacity = 0.96
        
        saveYourDrawingShadow.layer.shadowColor = UIColor.gray.cgColor
        saveYourDrawingShadow.layer.shadowOffset = CGSize(width: 2, height: 5)
        saveYourDrawingShadow.layer.shadowRadius = 12
        saveYourDrawingShadow.layer.shadowOpacity = 0.96
        
        shadowPanel.layer.shadowColor = UIColor.gray.cgColor
        shadowPanel.layer.shadowOffset = CGSize(width: 2, height: 5)
        shadowPanel.layer.shadowRadius = 12
        shadowPanel.layer.shadowOpacity = 0.96
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize()
    }
    
    private func calculateSectionInset() -> CGFloat {
        let deviceIsIpad = UIDevice.current.userInterfaceIdiom == .pad
        let deviceOrientationIsLandscape = UIDevice.current.orientation.isLandscape
        let cellBodyViewIsExpended = deviceIsIpad || deviceOrientationIsLandscape
        let cellBodyWidth: CGFloat = 200 + (cellBodyViewIsExpended ? 174 : 0)
        
        let buttonWidth: CGFloat = 25
        
        let inset = (collectionViewLayout.collectionView!.frame.width - cellBodyWidth + buttonWidth) / 4
        return inset
    }
    
    private func configureCollectionViewLayoutItemSize() {
            let inset: CGFloat = calculateSectionInset() // This inset calculation is some magic so the next and the previous cells will peek from the sides. Don't worry about it
            collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
            
        collectionViewLayout.itemSize = CGSize(width: collectionViewLayout.collectionView!.frame.size.width - inset * 4, height: collectionViewLayout.collectionView!.frame.size.height)
        }
        
        private func indexOfMajorCell() -> Int {
            let itemWidth = collectionViewLayout.itemSize.width
            let proportionalOffset = collectionViewLayout.collectionView!.contentOffset.x / itemWidth
            let index = Int(round(proportionalOffset))
            let safeIndex = max(0, min(dataSource.count - 1, index))
            return safeIndex
        }
        
        // ===================================
        // MARK: - UICollectionViewDataSource:
        // ===================================
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return dataSource.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorsPaletteCollectionViewCell", for: indexPath) as! ColorsPaletteCollectionViewCell
            
            cell.configure(colors: dataSource[indexPath.row]) { (selectedColor: UIColor) in
                self.colorsPicked(color: selectedColor)
            }
            
            // You can color the cells so you could see how they behave:
            //        let isEvenCell = CGFloat(indexPath.row).truncatingRemainder(dividingBy: 2) == 0
            //        cell.backgroundColor = isEvenCell ? UIColor(white: 0.9, alpha: 1) : .white
            
            return cell
        }
        
        // =================================
        // MARK: - UICollectionViewDelegate:
        // =================================
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            indexOfCellBeforeDragging = indexOfMajorCell()
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            // Stop scrollView sliding:
            targetContentOffset.pointee = scrollView.contentOffset
            
            // calculate where scrollView should snap to:
            let indexOfMajorCell = self.indexOfMajorCell()
            
            // calculate conditions:
            let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
            let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSource.count && velocity.x > swipeVelocityThreshold
            let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
            let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
            let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
            
            if didUseSwipeToSkipCell {
                
                let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
                let toValue = collectionViewLayout.itemSize.width * CGFloat(snapToIndex)
                
                // Damping equal 1 => no oscillations => decay animation:
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                    scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                    scrollView.layoutIfNeeded()
                }, completion: nil)
                
            } else {
                // This is a much better way to scroll to a cell:
                let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
                collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        createAd()
    }
    
    func createAd() {
        interstitialAd = GADInterstitial(adUnitID: "ca-app-pub-7352520433824678/7264302804")
        interstitialAd.delegate = self
        interstitialAd.load(GADRequest())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isInMenu {
            swiped = false
            UIView.animate(withDuration: 0.5) {
                self.toolbar.alpha = 0
                self.seperator.alpha = 0
                self.collectionView.alpha = 0
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
            self.toolbar.alpha = 1
            self.seperator.alpha = 1
            self.collectionView.alpha = 1
        }
        if !swiped {
            drawLines(fromPoint: lastPoint, toPoint: lastPoint)
        }
    }
    @IBAction func shareDrawing(_ sender: Any) {
        if let image = imageView.image {
            let imageToShare = [ image ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    @IBAction func reset(_ sender: AnyObject) {
        self.imageView.image = nil
        self.imageView.backgroundColor = UIColor(named: "Color")
        
        if interstitialAd.isReady {
            interstitialAd.present(fromRootViewController: self)
        }
    }
    @IBAction func save(_ sender: AnyObject) {
        isInMenu = true
        
        shadowPanelY.constant = -10
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func dismissPanel(_ sender: AnyObject) {
        isInMenu = false
        
        shadowPanelY.constant = -320
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func addImage(_ sender: UIButton!) {
        UIView.animate(withDuration: 0.5) {
            sender.superview!.superview!.superview!.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.isInMenu = false
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveDrawing(_ sender: UIButton!) {
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
                    if self.interstitialAd.isReady {
                        self.interstitialAd.present(fromRootViewController: self)
                    }
                }
            }
        }
    }
    
    @IBAction func erase(_ sender: UIButton) {
        if (isDrawing) {
            self.tempRBG = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            imageView.backgroundColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            sender.setImage(UIImage(systemName: "paintbrush"), for: .normal)
            self.temp = self.brushSize
            self.brushSize = 20
        } else {
            tempRBG.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            sender.setImage(UIImage(systemName: "delete.right"), for: .normal)
            self.brushSize = self.temp
        }
        
        isDrawing = !isDrawing
    }
    
    @IBAction func settings(_ sender: AnyObject) {}
    
    func colorsPicked(color: UIColor) {
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
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
        if settingsVC.shouldAcceptBg {
            self.imageView.backgroundColor = UIColor(red: settingsVC.bgRed, green: settingsVC.bgGreen, blue: settingsVC.bgBlue, alpha: 1)
        }
        
        UIView.animate(withDuration: 0.5) {
            self.toolbar.alpha = 1
            self.seperator.alpha = 1
            self.collectionView.alpha = 1
        }
    }
    
    func settingsViewControllerDidCancel() {
        if interstitialAd.isReady {
            interstitialAd.present(fromRootViewController: self)
        }
        
        UIView.animate(withDuration: 0.5) {
            self.toolbar.alpha = 1
            self.seperator.alpha = 1
            self.collectionView.alpha = 1
        }
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
