//
//  ViewController.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 10/07/23.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsViewController: UIViewController {
    
    private var spiner = JGProgressHUD(style: .dark)
    
    private let conversationsTableView: UITableView = {
        let table = UITableView()
        table.isHidden = true //para que cuando el usuario no tenga conversaciones activas no cargue la tableview vacia sino una etiqueta que dira "no conversations "
        
        table.register(UITableViewCell.self,
                        forCellReuseIdentifier: "cell")
        
        return table
    }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "no conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self, action: #selector(didTapComposeButton))
        
        view.addSubview(conversationsTableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        fetchConversations()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        conversationsTableView.frame = view.bounds
        
    }

    //check if they are singned in based on user defaults
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }

        private func validateAuth(){
            //si hay un usuario actual, quiere decir que alguien tiene iniciada una sesión
            if FirebaseAuth.Auth.auth().currentUser == nil {
                
                let vc = LoginViewController()
                
                //creación de un navigation controller que va a embeber el controller que ya tenemos vc
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen // si no se especifica esto sale como una tarjeta a la que el user puede hacer swipe down
                present(nav, animated: false)
            }
        
    }
   
    private func setupTableView() {
        conversationsTableView.delegate = self
        conversationsTableView.dataSource = self
    }
    
    private func fetchConversations() {
        conversationsTableView.isHidden = false
    }
    
    @objc private func didTapComposeButton(){
        let vc = NewConversationViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello world"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatViewController()
        vc.title = "Jenny Smith"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
