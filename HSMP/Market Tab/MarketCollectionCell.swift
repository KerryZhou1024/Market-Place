//
//  MarketCollectionCell.swift
//  HSMP
//
//  Created by Kerry Zhou on 10/6/20.
//

import UIKit

class MarketCollectionCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLB: UILabel!
    @IBOutlet var subTitleLB: UILabel!
    @IBOutlet var sellerLB: UILabel!
    @IBOutlet var priceLB: UILabel!
    
    static let identifier = "MarketCollectionCell";
    
    static let cellSize = CGSize(width: 330, height: 170)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    static func nib() -> UINib {
        return UINib(nibName: "MarketCollectionCell", bundle: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    //configure cell
    public func configure(with image:UIImage){
        imageView.image = image
    }
    
    public func configure(withTitle title:String){
        titleLB.text = title
    }
    
    public func configure(withSubTitle subTitle:String){
        subTitleLB.text = subTitle
    }
    
    public func configure(withSeller seller:String){
        sellerLB.text = seller
    }
    
    public func configure(withPrice price:Double, using currency:String){
        priceLB.text = currency + String(price)
    }
    
    public func configure(withBackgroundColor backgoundColor:UIColor){
        self.backgroundView?.backgroundColor = backgroundColor
    }
    
    func setUpStyle(){
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 4
        self.layer.borderColor = CGColor(red: CGFloat(255.0), green: CGFloat(255.0), blue: CGFloat(255.0), alpha: CGFloat(100))

    }
    
    public func configure(setAll image: UIImage, title:String, subTitle:String, seller:String, price:String){
        imageView.image = image
        titleLB.text = title
        subTitleLB.text = subTitle
        sellerLB.text = seller
        priceLB.text = price
        
        setUpStyle()
        
    }
    
}
