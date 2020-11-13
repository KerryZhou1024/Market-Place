//
//  GoodsDetailTVC.swift
//  HSMP
//
//  Created by Kerry Zhou on 10/7/20.
//

import UIKit
import CoreData

class GoodsDetailTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        
        coreDataFetch()
        
    }
    
    
    func coreDataFetch(){
        
        //Core Data
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AllLocalProduct")
        let idString = id?.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
        fetchRequest.returnsObjectsAsFaults = false
        

        
        do {
           let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                
                let result = results[0] as! NSManagedObject
                
                if let title = result.value(forKey: "title") as? String{
                    titleLB.text = title
                }
                
                if let subTitle = result.value(forKey: "subTitle") as? String{
                    subTitleLB.text = subTitle
                }
                
                if let price = result.value(forKey: "price") as? String{
                    priceLB.text = price
                }
                
                if let note = result.value(forKey: "note") as? String{
                    if note != ""{
                        noteTV.text = "NOTE: " + note
                        self.haveNote = true
                    }else{
                        //no note
                        noteTV.text = ""
                        self.haveNote = false
                    }
                }
                
                if let image = result.value(forKey: "image") as? Data{
                    imageView.image = UIImage(data: image)
                    self.havePhoto = true
                }else{
                    // no image
                    self.havePhoto = false
                }
                
                if let boolFavorite = result.value(forKey: "isFavorite") as? Bool{
                    self.isFavorite = boolFavorite
                    
                    if boolFavorite{
                        favoriteActionLB.text = "Remove From Favorite"
                    }else{
                        favoriteActionLB.text = "Add To Favorite"
                    }
                }
                
                if let date = result.value(forKey: "date") as? Date{
                    //date
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .short
                    dateLB.text = dateFormatter.string(from: date)
                }
                
                if let seller = result.value(forKey: "seller") as? String{
                    sellerLB.text = seller
                }else{
                    sellerLB.text = "Unknown Seller : Error"
                }

            }

        } catch{
            print("error")
        }
    }
    
    func coreDataEdit(action:String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AllLocalProduct")
        let idString = id?.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    
                    if action == "delete"{
                        if let temId = result.value(forKey: "id") as? UUID{
                            if temId == self.id{
                                context.delete(result)
                                do{
                                    try context.save()
                                    self.navigationController?.popViewController(animated: true)
                                }catch{
                                    print("error")
                                }
                            }
                        }
                    }
                    
                    if action == "addFavorite"{
                        result.setValue(true, forKey: "isFavorite")
                        
                        do{
                            try context.save()
                        }catch{
                            print("error")
                        }
                    }
                    
                    if action == "removeFavorite"{
                        result.setValue(false, forKey: "isFavorite")
                        
                        do{
                            try context.save()
                        }catch{
                            print("error")
                        }
                    }
                }
            }
        }catch{
            print("error")
        }
        
    }

    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var subTitleLB: UILabel!
    @IBOutlet weak var sellerLB: UILabel!
    @IBOutlet weak var priceLB: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noteTV: UITextView!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var favoriteActionLB: UILabel!
    
    
    var id:UUID?
    var isFavorite:Bool?
    var havePhoto:Bool = true
    var haveNote:Bool = true
    
    
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let zero = CGFloat(0.0)
        let photoHeight = CGFloat(320.0)
        let noteHeight = CGFloat(150.0)
        let ordinary = CGFloat(43.5)
        
        switch indexPath {
        case IndexPath(row: 5, section: 0):
            if havePhoto{
                return photoHeight
            }else{
                return zero
            }
        case IndexPath(row: 6, section: 0):
            if haveNote{
                return noteHeight
            }else{
                return zero
            }
        default:
            return ordinary
        }
    }
    
    
    
    
    func displayDataOnScreen(title:String, subTitle:String, seller:String, price:Double, currency:String, image:UIImage, note:String){
        titleLB.text = title
        subTitleLB.text = subTitle
        sellerLB.text = currency + String(price)
        imageView.image = image
        noteTV.text = note
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            switch indexPath.row{
            case 0:
                if isFavorite != nil{
                    if !isFavorite!{
                        // need to add to favorite
                        let alert = UIAlertController(title: "Add To Favorite?", message: "This action will add this product to your favorite set", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                            self.coreDataEdit(action: "addFavorite")
                            self.coreDataFetch()
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: "Remove from Favorite?", message: "This action will remove this product from your favorite set", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                            self.coreDataEdit(action: "removeFavorite")
                            self.coreDataFetch()
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    print("favorite error")
                }
                print("Add to favorite selected")
            case 1:
                print("Delete selected")
                let alert = UIAlertController(title: "Delete?", message: "This action will delete this product permanently.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                    self.coreDataEdit(action: "delete")
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            default:
                print("error in didSelectRowAt")
            }
        }
    }
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
