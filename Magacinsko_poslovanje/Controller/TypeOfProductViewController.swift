//  Magacinsko_poslovanje
//  Created by Ana Cvejic


import UIKit
import CoreData

class TypeOfProductCell: UITableViewCell{
    
    @IBOutlet weak var lblNumberOfInvoice: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDate: UILabel!
}

class TypeOfProductViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
 
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var lblInformation: UILabel!
    @IBOutlet weak var tfSearch: UITextField!
    var searching = false
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var foundProduct: Proizvod?
    var items: [VrstaProizvoda]?
    var filtredTypePro = [VrstaProizvoda]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = fetchData(proizvodi: foundProduct!)
        print("UKUPNO VRSTA PROIZVODA: \(items!.count)")
        if items!.count == 0{
            lblInformation.isHidden = false
            table.isHidden = true
        }else{
            lblInformation.isHidden = true
            table.isHidden = false
        }
        tfSearch.addTarget(self, action: #selector(pretragaVrstePro), for: .editingChanged)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func pretragaVrstePro(){
        self.filtredTypePro.removeAll()
        
                let search: Int = tfSearch.text!.count
        
                if search != 0{
                    searching = true
                    
                    for vrp in items!{
                        
                        if let typeSearch = tfSearch.text{
                            let rangeNumberInvoice = vrp.brojFakture?.lowercased().range(of: typeSearch, options: .caseInsensitive, range: nil, locale: nil)
                            let rangeQuantiy = vrp.kolkicinaUneto.description.lowercased().range(of: typeSearch, options: .caseInsensitive, range: nil, locale: nil)
                            let rangeDate = vrp.datumFakture?.description.lowercased().range(of: typeSearch, options: .caseInsensitive, range:  nil, locale: nil)
                            if rangeNumberInvoice != nil || rangeQuantiy != nil || rangeDate != nil{
                                filtredTypePro.append(vrp)
                            }
                        }
                    }
                }else{
                    
                    filtredTypePro = items!
                    searching = false
                }
                table.reloadData()
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return filtredTypePro.count
        }else{
            return items!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "typeProduct", for: indexPath) as! TypeOfProductCell
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        if searching{
            let typePro = filtredTypePro[indexPath.row]
            cell.lblNumberOfInvoice.text = "Broj fakture: " + typePro.brojFakture!
            cell.lblQuantity.text = "Uneta količina: " + "\(typePro.kolkicinaUneto)"
            cell.lblPrice.text = "Cena: " + "\(typePro.cena)"
            cell.lblDate.text = "Datum: " + formatter.string(from: typePro.datumFakture!)
        }else{
            let typePro = items![indexPath.row]
            cell.lblNumberOfInvoice.text = "Broj fakture: " + typePro.brojFakture!
            cell.lblQuantity.text = "Uneta količina: " + "\(typePro.kolkicinaUneto)"
            cell.lblPrice.text = "Cena: " + "\(typePro.cena)"
            cell.lblDate.text = "Datum: " + formatter.string(from: typePro.datumFakture!)
        }
        
        return cell
    }
   
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Izmena") { [weak self] (action, view, completionHandler) in
            self?.editTypeOfProduct(indexPath: indexPath, items: self!.items!)
            completionHandler(true)
        
      }
            return UISwipeActionsConfiguration(actions: [editAction])
    }

    
    private func editTypeOfProduct(indexPath: IndexPath, items: [VrstaProizvoda]) {
          let typePro = items[indexPath.row]
          let oldQuantity: Int64 =  typePro.kolkicinaUneto
        
        let alert = UIAlertController(title: "Izmena vrste proizvoda", message: "", preferredStyle: .alert)
        alert.addTextField { (numberInvoice) in
            numberInvoice.text = typePro.brojFakture
        }
        alert.addTextField { (price) in
            price.text = String(typePro.cena)
        }
        alert.addTextField { (insertesQuantity) in
            insertesQuantity.text = String(typePro.kolkicinaUneto)
        }
        alert.addAction(UIAlertAction(title: "Izmeni", style: .default, handler: { [self, weak alert] (_) in
            
            let textNumberInvoice = alert?.textFields![0]
            let textPrice = alert?.textFields![1]
            let textNewQuantity = alert?.textFields![2]
            
            guard Int64(textPrice!.text!) != nil && Int64(textNewQuantity!.text!) != nil else {
                self.alertPoruka(title: "Polja uneta količina i cena po komadu moraju biti numerička")
                return
            }
            guard textNumberInvoice!.text! != "" else{
                alertPoruka(title: "Polje broj fakture ne sme biti prazno")
                return
            }
            
            //AC Izmena vrste proizvoda
            typePro.brojFakture = textNumberInvoice?.text
            typePro.cena = Int64((textPrice?.text)!)!
            typePro.kolkicinaUneto = Int64((textNewQuantity?.text)!)!
            
            //AC Cuvanje izmene
            do{
                try self.context.save()
            }catch{
                print("GRESKA")
            }
            self.table.reloadData()
            updateProizvod(product: self.foundProduct!, typeProduct: oldQuantity, newQuantity: Int64(textNewQuantity?.text ?? "")!)
        }))
        alert.addAction(UIAlertAction(title: "Otkaži", style: .destructive, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateProizvod(product: Proizvod, typeProduct: Int64, newQuantity: Int64){
        let trenutnaKolicina = product.ukupnoProizvoda
        let newquantity = (trenutnaKolicina - typeProduct) + newQuantity
        product.ukupnoProizvoda = newquantity
        do{
            try self.context.save()
            print("UKUPNA KOLICINA JE IZMENJENA")
        }catch{

        }
    }
    
    func alertPoruka(title: String){
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    func fetchData(proizvodi: Proizvod)->[VrstaProizvoda]{
        let request: NSFetchRequest<VrstaProizvoda> = VrstaProizvoda.fetchRequest()
        request.predicate = NSPredicate(format: "proizvod = %@", proizvodi)
        var typeOfProduct: [VrstaProizvoda]?
        
        do{
            typeOfProduct = try self.context.fetch(request)
        }catch{
            print("GRESKA")
        }
        return typeOfProduct!
        
    }
}
