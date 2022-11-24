//  Magacinsko_poslovanje
//  Created by Ana Cvejic

import UIKit
import CoreData

class ProizvodiCell: UITableViewCell{
    
    @IBOutlet weak var lblNazivProizvoda: UILabel!
    @IBOutlet weak var lblSifraProizvoda: UILabel!
}


class ProizvodiViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate{
   
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var lblObavestenje: UILabel!
    
    
    var nazivProizvoda: String = ""
    var sifraProizvoda: String = ""
    var ukupnaKolicina: Int64 = 0
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Proizvod]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getProizvodi()
    }
    
    func getProizvodi(){
        
        do{
            
            self.items = try context.fetch(Proizvod.fetchRequest())
            
            if items?.count != 0{
            DispatchQueue.main.async {
                self.lblObavestenje.isHidden = true
                self.table.reloadData()
             }
            }else{
                lblObavestenje.isHidden = false
                table.isHidden = true
            }
            
        }catch{
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "proizvodi", for: indexPath) as! ProizvodiCell
        let product = items![indexPath.row]
        cell.lblNazivProizvoda.text = "Naziv: " + product.nazivProizvoda!
        cell.lblSifraProizvoda.text = "Šifra: " + product.sifraProizvoda!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = items![indexPath.row]
        
        self.nazivProizvoda = product.nazivProizvoda!
        self.sifraProizvoda = product.sifraProizvoda!
        self.ukupnaKolicina = product.ukupnoProizvoda
        self.performSegue(withIdentifier: "backToInsert", sender: self)
    }
    
}
