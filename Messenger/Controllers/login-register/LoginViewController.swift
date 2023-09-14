//
//  LoginViewController.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 10/07/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
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
    
  
    private let loginButton : UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    
    private let FBloginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
       
        return  button
    }()
    
    private let GoogleLoginButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 //       GIDSignIn.sharedInstance?.presentingViewController = self
        
        view.backgroundColor = .systemPink
        title = "Log in"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        GoogleLoginButton.addTarget(self, action: #selector(GoogleLoginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        FBloginButton.delegate = self
        
        //add subViews
        
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(FBloginButton)
        scrollView.addSubview(GoogleLoginButton)
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
        
        loginButton.frame = CGRect(x: 30 ,
                                  y: passwordField.bottom + 10,
                                  width: scrollView.width - 60,
                                   height: 52)
        
        
        FBloginButton.frame = CGRect(x: 30 ,
                                  y: loginButton.bottom + 10,
                                  width: scrollView.width - 60,
                                   height: 52)
        
        GoogleLoginButton.frame = CGRect(x: 30 ,
                                         y: FBloginButton.bottom + 10,
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
        spinner.show(in: view)
        //Firebase Log in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authDataResult, error in
            
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                //esto lo mete en el hilo principal porque firebase se ejecuta en el background
                strongSelf.spinner.dismiss()
            }
            
            
            guard let result = authDataResult, error == nil else {
                print("Error singnin In with email: \(email)")
                return
            }
            
            let user = result.user
            
            //lets save the users email address
            UserDefaults.standard.set(email, forKey: "email")
            
            print("Logged In User: \(user)")
            strongSelf.navigationController?.dismiss(animated: true)
        }
    }
    
    
    func alertUserLogginError(){
        let alert = UIAlertController(title: "Woops", message: "Please enter all the information to log in", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func GoogleLoginButtonTapped(){
        // google sing in
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            if let error = error {
                print("Error singing with google \(error.localizedDescription)")
              return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString else {
             
              return
          }
            print("User successfully singned in \(user)")
            
            guard let email = user.profile?.email,
                  let name = user.profile?.givenName,
                  let lastName = user.profile?.familyName else {
                return
                
            }
            
            //lets save the users email address
            UserDefaults.standard.set(email, forKey: "email")
            
        //validation to see if the email already exists in our database
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    //insert to database
                    
                    let chatUser = ChatAppUser(fisrtName: name,
                                               lastName: lastName,
                                               emailAddress: email)
                    
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        if success {
                            if user.profile?.hasImage != nil {
                                
                                guard let url = user.profile?.imageURL(withDimension: 200) else {
                                    return
                                }
                                
                                URLSession.shared.dataTask(with: url) { data, _, _ in
                                    guard let data = data else {
                                        return
                                    }
                                    //upload image
                                    let fileName = chatUser.profilePictureFileName
                                    StorageManager.shared.uploadProfilePicture(with: data,
                                                                               fileName: fileName,
                                                                               completion: {result in
                                        switch result {
                                        case .success(let downloadURL):
                                            UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                            print(downloadURL)
                                        case .failure(let error):
                                            print("Storage Manager error: \(error)")
                                        }
                                    })
                                }.resume()
                            }
                        }
                    })
                }
            }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)

          //let's sing them in with firebase now
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    print("Failed to log in with google credential")
                    return
                }
                
                print("Successfully singed in with google credential")
                strongSelf.navigationController?.dismiss(animated: true)
            }
        }
        
    }

}


extension LoginViewController: UITextFieldDelegate {
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //esta funcion se llama cuando el user pulsa enter = return
        
        if textField == emailField {
            //si el user esta en el email field y pulsa enter, el cursor va a ir al password
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            //si ya esta en password entonces hace las veces del boton
            loginButtonTapped()
            
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        //no operation
    }
    
//log in con facebook
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        
        guard let token = AccessToken.current else {
            print("user failed to log in with facebook")
            return
        }
                
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token.tokenString, version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("failed to make facebook graph request")
                return
            }
            
            print(result)
            
            
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result ["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String else {
                print("Failed to get email and name from fb result")
                return
            }
            
            //lets save the users email address
            UserDefaults.standard.set(email, forKey: "email")
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {  //sino existe el usuario lo agregamos a la base de datos
                    let chatUser = ChatAppUser(fisrtName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        if success {
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("downloading data from facebook image")
                            
                            URLSession.shared.dataTask(with: url) { data, _, _ in
                                
                                guard let data = data else {
                                    print("failed to get data from facebook image")
                                    return
                                }
                                
                            print("got data from facebook uploading")
                                
                                //upload image
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data,
                                                                           fileName: fileName,
                                                                           completion: {result in
                                    switch result {
                                    case .success(let downloadURL):
                                        UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                        print(downloadURL)
                                    case .failure(let error):
                                        print("Storage Manager error: \(error)")
                                    }
                                })
                            }.resume()
                        }
                    })
                }
            }
            
            //now we can create a credential and pass that to firebase
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard let result = authResult, error == nil else {
                    print("Facebook credential login failed,MFA may be needed")
                    return
                }
                
                print("Successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true)
            })
        }
       
    }
    
    
}
