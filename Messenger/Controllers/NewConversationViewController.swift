//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 10/07/23.
//

import UIKit
import JGProgressHUD


class NewConversationViewController: UIViewController {
  
    
    public var completion: ((SearchResults) -> (Void))? //

    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]]() //este es array donde se almacenaran los usuario que estan guardados en firebase cuando se haga la busqueda la primera vez. Por eso tiene que tener la misma estructura, para poderlos contener
    private var results = [SearchResults]() //aca se van a guardar los resultados que se van a mostrar en la tableView despues de haber realizado la busqueda
    
    private var hasFetched = false
    
    private let searchBar: UISearchBar = {
        let  searchBar = UISearchBar()
        searchBar.placeholder = "Search for users . . ."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewConversationCell.self, forCellReuseIdentifier: NewConversationCell.identifier)
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = .white
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        navigationController?.navigationBar.topItem?.titleView = searchBar  //asi le asigna la posicion correcta a la search Bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dissmissSelf))
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.heigth-200)/2,
                                      width: view.width/2,
                                      height: 200)
    }
    
    @objc private func dissmissSelf() {
        dismiss(animated: true, completion: nil)
    }

}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier,
                                                 for: indexPath) as! NewConversationCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //start conversation
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true) {[weak self] in
            
            self?.completion?(targetUserData) //le estamos pasando a este handler el usuario con el que se quiere iniciar una conversacion para ser usado en el conversationViewController
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder() //quita el teclado
        results.removeAll() //para que quede limpio el array de resultados cada vez que se hace una nueva busqueda
        
        spinner.show(in: view)
        
        self.searchUsers(query: text)

    }
    
    func searchUsers(query: String) {
        //check if array has firebase result
        if hasFetched {
            //if it does: filter
            filterUsers(with: query)
        } else {
            //if not, fetch then filter
            DatabaseManager.shared.getAllUsers { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            }
        }
    }
    
    func filterUsers(with term: String) {
        //update the UI: either show results or show no results label
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String,
              hasFetched else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        self.spinner.dismiss()
        
        let results: [SearchResults] = self.users.filter {
            guard let email = $0["email"] as? String,
                  email != safeEmail else {
                return false
            }
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        }.compactMap {
            guard let email = $0["email"],
                    let name = $0["name"] else {
                return nil
            }
            return SearchResults(name: name, email: email)
        }
        self.results = results
        
        updateUI()
    
    }
    
    func updateUI(){
        if results.isEmpty {
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
}

struct SearchResults {
    let name: String?
    let email: String?
}
