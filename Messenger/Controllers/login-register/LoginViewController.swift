//
//  LoginViewController.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 10/07/23.
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {
    
    // MARK: - Creation of subviews
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        
        return scrollView
    }()
    
    private let logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "logomessenger")
        logoImageView.contentMode = .scaleAspectFit
        return logoImageView
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue // para que cuando pulsen enter los lleve al field de la contraseña
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email address..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password.."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        
        return field
    }()
    
  
    private let loggintButton : UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemPink
        title = "Log in"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loggintButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        //add subViews
        
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loggintButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        //here we can give the frame to our imageView
        let size = scrollView.width/3
        logoImageView.frame = CGRect(x: (scrollView.width-size)/2 ,
                                     y: 90,
                                     width: size,
                                     height: size)
        
        emailField.frame = CGRect(x: 30 ,
                                  y: logoImageView.bottom + 10,
                                  width: scrollView.width - 60,
                                   height: 52)
        
        passwordField.frame = CGRect(x: 30 ,
                                  y: emailField.bottom + 10,
                                  width: scrollView.width - 60,
                                   height: 52)
        
        loggintButton.frame = CGRect(x: 30 ,
                                  y: passwordField.bottom + 10,
                                  width: scrollView.width - 60,
                                   height: 52)
        
    }
    
    // MARK: - Validations
    
    @objc private func loginButtonTapped(){
        //to get rid of the keyboard
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
    //Is there text in both textFields?
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLogginError()
            return
        }
        
        //Firebase Log in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            guard let result = authDataResult, error == nil else {
                print("Error singning In with email: \(email)")
                return
            }
            
            let user = result.user
            print("Logged In User: \(user)")
        }
    }
    
    func alertUserLogginError(){
        let alert = UIAlertController(title: "Woops", message: "Please enter all the information to log in", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Ccount"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    

}


extension LoginViewController: UITextFieldDelegate {
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //esta funcion se llama cuando el user pulsa enter = return
        
        if textField == emailField {
            //si el user esta en el email field y pulsa enter, el curso va a ir al password
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            //si ya esta en password entonces hace las veces del boton
            loginButtonTapped()
            
        }
        return true
    }
}
