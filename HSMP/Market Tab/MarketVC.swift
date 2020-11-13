//
//  ViewController.swift
//  HSMP
//
//  Created by Kerry Zhou on 10/6/20.
//

import UIKit
import CoreData

class MarketVC: UIViewController {

    @IBOutlet weak var mainCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //claims collection belongs to vc
        mainCollection.register(MarketCollectionCell.nib(), forCellWithReuseIdentifier: MarketCollectionCell.identifier)
        mainCollection.dataSource = self
        mainCollection.delegate = self
        
        
        
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        useModeToUpdate(mode: "All Product")
    }
    
    
    var titleArray = [String]()
    var subTitleArray = [String]()
    var priceArray = [String]()
    var sellerArray = [String]()
    var imageArray = [UIImage]()
    var idArray = [UUID]()
    
    
    var currentId:UUID?
    
    func clearArrays(){
        titleArray = []
        subTitleArray = []
        priceArray = []
        sellerArray = []
        imageArray = []
        idArray = []
    }
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBAction func filterButtonPressed(_ sender: Any) {
        
        let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "All Product", style: .default, handler: { (_) in
            self.useModeToUpdate(mode: "All Product")
        }))
        action.addAction(UIAlertAction(title: "Favorite", style: .default, handler: { (_) in
            self.useModeToUpdate(mode: "Favorite")
        }))
        action.addAction(UIAlertAction(title: "Viewed", style: .default, handler: { (_) in
            self.useModeToUpdate(mode: "Viewed")
        }))
        action.addAction(UIAlertAction(title: "Posted", style: .default, handler: { (_) in
            self.useModeToUpdate(mode: "Posted")
        }))
        
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        action.popoverPresentationController?.barButtonItem = filterButton
        
        self.present(action, animated: true, completion: nil)
    }
    
    func useModeToUpdate(mode:String){
        switch mode {
        case "All Product":
            coreDataAction(action: "FetchAll", matchObject: nil)
            self.navigationItem.title = "Market"
        case "Favorite":
            coreDataAction(action: "FetchFavorite", matchObject: nil)
            self.navigationItem.title = "Favorite"
        case "Viewed":
            coreDataAction(action: "FetchViewed", matchObject: nil)
            self.navigationItem.title = "Viewed"
        case "Posted":
            coreDataAction(action: "FetchSelfPosted", matchObject: nil)
            self.navigationItem.title = "Posted"
        default:
            coreDataAction(action: "FetchAll", matchObject: nil)
            self.navigationItem.title = "Market"
        }
    }
    
    
    
    func coreDataAction(action:String, matchObject:Any?){
        clearArrays()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AllLocalProduct")
        fetchRequest.returnsObjectsAsFaults = false
        
        let sort = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        
        if action == "FetchAll"{
            
        }
        
        if action == "FetchFavorite"{
            fetchRequest.predicate = NSPredicate(format: "isFavorite = %@", NSNumber(true))
        }
        
        if action == "FetchViewed"{
            fetchRequest.predicate = NSPredicate(format: "isViewed = %@", NSNumber(true))
        }
        
        if action == "FetchSelfPosted"{
            fetchRequest.predicate = NSPredicate(format: "isSelfPosted = %@", NSNumber(true))
        }
        
        if action == "ContainsTitle"{
            fetchRequest.predicate = NSPredicate(format: "title CONTAINS %@", matchObject as! CVarArg)
        }
        
        do {
           let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    
                    
                    if let title = result.value(forKey: "title") as? String{
                        titleArray.append(title)
                    }else{
                        titleArray.append("")
                    }
                    
                    if let subTitle = result.value(forKey: "subTitle") as? String{
                        subTitleArray.append(subTitle)
                    }else{
                        subTitleArray.append("")
                    }
                    
                    if let price = result.value(forKey: "price") as? String{
                        priceArray.append(price)
                    }else{
                        priceArray.append("")
                    }
                    
                    if let seller = result.value(forKey: "seller") as? String{
                        sellerArray.append(seller)
                    }else{
                        priceArray.append("")
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID{
                        idArray.append(id)
                    }else{
                        idArray.append(UUID())
                    }
                    
                    if let imageData = result.value(forKey: "image") as? Data{
                        if let image = UIImage(data: imageData){
                            imageArray.append(image)
                        }else{
                            imageArray.append(UIImage(named: "imageBroken")!)
                        }
                    }else{
                        imageArray.append(UIImage(named: "imageBroken")!)
                    }
                }
            }

        } catch{
            print("error")
        }
        
        mainCollection.reloadData()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            let detailTVC = segue.destination as! GoodsDetailTVC
            detailTVC.id = currentId
        }
    }
    

}



extension MarketVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //prepare for segue
        currentId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    
    
}

extension MarketVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MarketCollectionCell.identifier, for: indexPath) as! MarketCollectionCell
        
        cell.configure(setAll: imageArray[indexPath.row], title: titleArray[indexPath.row], subTitle: subTitleArray[indexPath.row], seller: sellerArray[indexPath.row], price: priceArray[indexPath.row])
        
//        cell.configure(withBackgroundColor: UIColor.green)
//        cell.backgroundColor = UIColor.lightGray
//        cell.layer.cornerRadius = 20
//        cell.layer.borderWidth = 4
        return cell
    }
    
    
}

extension MarketVC: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return MarketCollectionCell.cellSize
    }
}
