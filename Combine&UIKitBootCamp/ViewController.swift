//
//  ViewController.swift
//  Combine&UIKitBootCamp
//
//  Created by Rijo Samuel on 26/12/21.
//

import UIKit
import Combine

//extension Notification.Name {
//	static let newBlogPost = Notification.Name("newPost")
//}
//
//struct BlogPost {
//	let title: String
//}

final class ViewController: UIViewController {
	
	//	@IBOutlet private weak var tncSwitch: UISwitch!
	//	@IBOutlet private weak var privacySwitch: UISwitch!
	//	@IBOutlet private weak var nameTextField: UITextField!
	//	@IBOutlet private weak var btnSubmit: UIButton!
	@IBOutlet private weak var txtName: UITextField!
	@IBOutlet private weak var txtPassword: UITextField!
	@IBOutlet private weak var txtConfirmPassword: UITextField!
	@IBOutlet private weak var btnCreateAccount: UIButton!
	
	// Define Publishers
	//	@Published private var isTermsAccepted: Bool = false
	//	@Published private var isPrivacyAccepted: Bool = false
	//	@Published private var name: String = ""
	@Published private var name: String = ""
	@Published private var password: String = ""
	@Published private var confirmPassword: String = ""
	
	// Combine Publishers into a single stream
	//	private var isFormValid: AnyPublisher<Bool, Never> {
	//
	//		return Publishers.CombineLatest3($isTermsAccepted, $isPrivacyAccepted, $name)
	//			.map { isTerm, isPrivacy, name in
	//				return isTerm && isPrivacy && !name.isEmpty
	//			}.eraseToAnyPublisher()
	//	}
	
	private var isValidName: AnyPublisher<String?, Never> {
		
		return $name
			.debounce(for: 0.5, scheduler: RunLoop.main)
			.removeDuplicates()
			.flatMap { name in
				
				return Future { promise in
					
					self.nameAvailable(name) { available in
						promise(.success(available ? name : nil))
					}
				}
			}
			.eraseToAnyPublisher()
	}
	
	private var isValidPassword: AnyPublisher<String?, Never> {
		
		return Publishers.CombineLatest($password, $confirmPassword)
			.map { password, confirmPassword in
				guard password == confirmPassword, password.count > 0 else { return nil }
				return password
			}
			.map {
				($0 ?? "") == "password1" ? nil : $0
			}
			.eraseToAnyPublisher()
	}
	
	private var isFormValid: AnyPublisher<(String, String)?, Never> {
		
		return Publishers.CombineLatest(isValidName, isValidPassword)
			.receive(on: RunLoop.main)
			.map { name, password in
				guard let name = name, let password = password else { return nil }
				return (name, password)
			}
			.eraseToAnyPublisher()
	}
	
	// Define Subscriber
	//	private var buttonSubscriber: AnyCancellable?
	private var createAccountButtonSubscriber: AnyCancellable?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		txtName.delegate = self
		txtPassword.delegate = self
		txtConfirmPassword.delegate = self
		
		//		nameTextField.delegate = self
		//		tncSwitch.isOn = false
		//		privacySwitch.isOn = false
		//
		//		buttonSubscriber = isFormValid
		//			.receive(on: RunLoop.main)
		//			.assign(to: \.isEnabled, on: btnSubmit)
		
		//		publishButton.addTarget(self, action: #selector(publishButtonTapped), for: .primaryActionTriggered)
		//
		//		// Create a publisher
		//		let publisher = NotificationCenter.Publisher(center: .default, name: .newBlogPost, object: nil)
		//			.map { (notification) -> String? in
		//				return (notification.object as? BlogPost)?.title ?? ""
		//			}
		//
		//		// Create a subscriber
		//		let subscriber = Subscribers.Assign(object: subscribedLabel, keyPath: \.text)
		//		publisher.subscribe(subscriber)
		
		createAccountButtonSubscriber = isFormValid
			.map { $0 != nil }
			.receive(on: RunLoop.main)
			.assign(to: \.isEnabled, on: btnCreateAccount)
	}
	
	func nameAvailable(_ username: String, completion: (Bool) -> Void) {
		completion(true) // Our fake asynchronous backend service
	}
	
	//	@objc func publishButtonTapped(_ sender: UIButton) {
	//
	//		// Post the notification
	//		let title = blogTextField.text ?? "Coming soon"
	//		let blogPost = BlogPost(title: title)
	//		NotificationCenter.default.post(name: .newBlogPost, object: blogPost)
	//	}
	
	//	@IBAction private func didFlipTncSwitch(_ sender: UISwitch) {
	//		isTermsAccepted = sender.isOn
	//	}
	//
	//	@IBAction private func didFlipPrivacySwitch(_ sender: UISwitch) {
	//		isPrivacyAccepted = sender.isOn
	//	}
	//
	//	@IBAction private func didChangeName(_ sender: UITextField) {
	//		name = sender.text ?? ""
	//	}
	//
	//	@IBAction private func didTapBtnSubmit(_ sender: UIButton) {
	//
	//	}
}

// MARK: - TextField Delegate Methods
extension ViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		textField.resignFirstResponder()
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let textFieldText = textField.text ?? ""
		let text = (textFieldText as NSString).replacingCharacters(in: range, with: string)
		
		switch textField {
			case txtName: name = text
			case txtPassword: password = text
			case txtConfirmPassword: confirmPassword = text
			default: break
		}
		
		return true
	}
}
