//  Magacinsko_poslovanje
//  Created by Ana Cvejic

import UIKit
import CoreData

class AllProductsCell: UITableViewCell{
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblTotalQuantity: UILabel!
}

class AllProductsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    
   @IBOutlet weak var lblInformation: UILabel!
   @IBOutlet weak var table: UITableView!
   @IBOutlet weak var tfSearch: UITextField!
    
    var foundProduct: Proizvod?
    var searching: Bool = false
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Proizvod]?
    var filtredProizvod = [Proizvod]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tfSearch.addTarget(self, action: #selector(pretragaPro), for: .editingChanged)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        fetchProizvod()
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchProizvod()
    }
    
    @objc func pretragaPro(){
        self.filtredProizvod.removeAll()
        
                let search: Int = tfSearch.text!.count
                
                if search != 0{
                    searching = true
                    for pr in items!{
                        if let productSearch = tfSearch.text{
                            let rangeName = pr.nazivProizvoda?.lowercased().range(of: productSearch, options: .caseInsensitive, range: nil, locale: nil)
                            let rangeCode = pr.sifraProizvoda?.lowercased().range(of: productSearch, options: .caseInsensitive, range: nil, locale: nil)
                            if rangeName != nil || rangeCode != nil{
                                filtredProizvod.append(pr)
                            }
                        }
                    }
                }else{
                    filtredProizvod = items!
                    searching = false
                }
                table.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return filtredProizvod.count
        }else{
            return items!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allProduct", for: indexPath) as! AllProductsCell

        if searching{
            let products = filtredProizvod[indexPath.row]
            
            cell.lblName.text = "Naziv: " + products.nazivProizvoda!
            cell.lblCode.text = "Šifra: " + products.sifraProizvoda!
            cell.lblTotalQuantity.text = "Količina: " + String(products.ukupnoProizvoda)
        }else{
            let products = items![indexPath.row]
            
            cell.lblName.text = "Naziv: " + products.nazivProizvoda!
            cell.lblCode.text = "Šifra: " + products.sifraProizvoda!
            cell.lblTotalQuantity.text = "Količina: " + String(products.ukupnoProizvoda)
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = items![indexPath.row]
        foundProduct = cell
        self.performSegue(withIdentifier: "typeProduct", sender: self)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        let editAction = UIContextualAction(style: .normal, title: "Izmena") { [weak self] (action, view, completionHandler) in
            self?.editProduct(indexPath: indexPath, items: self!.items!)
            completionHandler(true)
        
      }
        let delteAction = UIContextualAction(style: .destructive, title: "Brisanje") { [weak self] (action, view, completionHandler) in
            self?.deleteProduct(indexPath: indexPath, items: self!.items!)
            completionHandler(true)
        }
            return UISwipeActionsConfiguration(actions: [editAction, delteAction])
    }
    func deleteProduct(indexPath: IndexPath, items: [Proizvod]){
        let proizvod = items[indexPath.row]
        let alert = UIAlertController(title: "Da li ste sigurni da želite da obrišete ovaj proizvod?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "DA", style: .destructive, handler: { [self] (_) in
            do{
                //AC Brisanje izabranog proizvoda - Delete selected product
                self.context.delete(proizvod)
                try self.context.save()
                print("PROIZVOD JE OBRISAN")
            }catch{
                
            }
            fetchProizvod()
        }))
        alert.addAction(UIAlertAction(title: "Otkaži", style: .default, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func editProduct(indexPath: IndexPath, items: [Proizvod]){
        let product = items[indexPath.row]
      
      let alert = UIAlertController(title: "Izmena proizvoda", message: "", preferredStyle: .alert)
      alert.addTextField { (name) in
          name.text = product.nazivProizvoda
      }
      alert.addTextField { (code) in
          code.text = product.sifraProizvoda
      }
        
      alert.addAction(UIAlertAction(title: "Izmeni", style: .default, handler: { [self, weak alert] (_) in
          
          let textName = alert?.textFields![0]
          let textCode = alert?.textFields![1]
          
          guard textName!.text! != "" else{
              alertPoruka(title: "Polje naziv proizvoda ne sme biti prazno")
              return
          }
          
          //AC Edit selected product - Izmena izabranog proizvoda
          product.nazivProizvoda = textName?.text!
          product.sifraProizvoda = textCode?.text!
          
          //AC Cuvanje izmene - save edit
          do{
              try self.context.save()
          }catch{
              print("GRESKA")
          }
          self.table.reloadData()
      }))
      alert.addAction(UIAlertAction(title: "Otkaži", style: .destructive, handler: { (_) in
          self.dismiss(animated: true, completion: nil)
      }))
      self.present(alert, animated: true, completion: nil)
        
    }
    
    func alertPoruka(title: String){
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }


    
    func fetchProizvod(){
       
        do{
            
            self.items = try context.fetch(Proizvod.fetchRequest())
            print("Proizvod: \(items!)")
            if items?.count != 0{
                self.lblInformation.isHidden = true
                table.isHidden = false
                self.table.reloadData()
            }else{
                lblInformation.isHidden = false
                table.isHidden = true
            }
            
        }catch{
            
        }
    }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "typeProduct"{
            let data = segue.destination as! TypeOfProductViewController
            data.foundProduct = foundProduct
        }
    }
}
