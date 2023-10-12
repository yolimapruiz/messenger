//
//  ViewController.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 10/07/23.
//

import UIKit
import FirebaseAuth
import JGProgressHUD


struct Conversation {
    let id: String
    let name:String
    let otherUserEmail: String
    let latesMessage: LatesMessage
}

struct LatesMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class ConversationsViewController: UIViewController {
    
    private var spiner = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()
    
    private let conversationsTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .brown
        table.isHidden = false //para que cuando el usuario no tenga conversaciones activas no cargue la tableview vacia sino una etiqueta que dira "no conversations "
        
        table.register(ConversationTableViewCell.self,
                       forCellReuseIdentifier: ConversationTableViewCell.identifier)
        
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
        view.backgroundColor = .blue
        view.addSubview(conversationsTableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        fetchConversations()
        startListeningForConversations()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       conversationsTableView.frame = view.bounds
      noConversationsLabel.frame = CGRect(x: 10,
                                            y: (view.heigth - 100)/2,
                                            width: view.width - 20,
                                            height: 100)
        
    }

    //check if they are singned in based on user defaults
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }

    private func startListeningForConversations(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConverations(for: safeEmail) { [weak self] result in
            switch result {
                
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    print("no hay conversaciones")
                    return
                }
                self?.conversationsTableView.isHidden = false
            
                self?.conversations = conversations
                
                print("si hay conversaciones \(conversations.count)")
                DispatchQueue.main.async {
                    self?.conversationsTableView.reloadData()
                }
            case .failure(let error):
                print("failed to get convos: \(error)")
            }
        }
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
        //aca estamos accediendo al NewConversationViewController, especificamente al completions
        vc.completion = {[weak self] result in
           
            self?.createNewConversation(result: result)
        }
        
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createNewConversation(result: SearchResults){
        guard let name = result.name,
              let email = result.email else {
            
            return
        }
        let vc = ChatViewController(with: email, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}
