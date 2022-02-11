//
//  CurrenciesView.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 09.02.2022.
//

import UIKit
import SnapKit

class CurrenciesView: UIView {
    let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    let textField: UITextField = UITextField(frame: .zero)
    
    private let headerView: UIView = UIView(frame: .zero)
    private let titleLabel: UILabel = UILabel(frame: .zero)
    private let viewForTextField: UIView = UIView(frame: .zero)
    
    private var observers: [NSObjectProtocol] = []
    private var bottomConstraint: Constraint?
    
    func commonInit() {
        configureView()
        makeConstraints()
        addObservers()
    }
    
    private func configureView() {
        self.addSubview(headerView)
        headerView.addSubview(titleLabel)
        self.addSubview(viewForTextField)
        viewForTextField.addSubview(textField)
        self.addSubview(tableView)
        
        textField.layer.cornerRadius = 10.0
        textField.backgroundColor = .lightGray
        textField.placeholder = "Tap to search"
        textField.textAlignment = .center
        viewForTextField.backgroundColor = .white
        self.backgroundColor = .white
        headerView.backgroundColor = .white
        tableView.backgroundColor = .white
        
        titleLabel.font = UIFont.systemFont(ofSize: 25.0)
        titleLabel.textColor = UIColor(named: "Title_Color")
        titleLabel.text = "Currencies"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
    }
    
    private func makeConstraints() {
        headerView.snp.makeConstraints { maker in
            maker.left.equalTo(self.snp.left)
            maker.right.equalTo(self.snp.right)
            maker.top.equalTo(self.snp.top)
            maker.height.equalTo(self.snp.height).multipliedBy(0.1)
        }
        titleLabel.snp.makeConstraints { maker in
            maker.centerX.equalTo(headerView.snp.centerX)
            maker.width.equalTo(headerView.snp.width).multipliedBy(0.5)
            maker.bottom.equalTo(headerView.snp.bottom).inset(5.0)
        }
        viewForTextField.snp.makeConstraints { maker in
            maker.top.equalTo(headerView.snp.bottom)
            maker.left.equalTo(headerView.snp.left)
            maker.right.equalTo(headerView.snp.right)
            maker.height.equalTo(50.0)
        }
        textField.snp.makeConstraints { maker in
            maker.top.equalTo(viewForTextField.snp.top).offset(5.0)
            maker.left.equalTo(viewForTextField.snp.left).offset(20.0)
            maker.right.equalTo(viewForTextField.snp.right).inset(20.0)
            maker.bottom.equalTo(viewForTextField.snp.bottom).inset(5.0)
        }
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(viewForTextField.snp.bottom)
            maker.left.equalTo(self.snp.left)
            maker.right.equalTo(self.snp.right)
            bottomConstraint = maker.bottom.equalTo(self.snp.bottom).constraint
        }
    }
    
    private func addObservers() {
        observers.append(NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: OperationQueue.main) { [weak self] notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRect = keyboardFrame.cgRectValue
                    self?.changeBottomConstraintUseKeyboard(rect: keyboardRect)
                }
            })
        observers.append(NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: OperationQueue.main) { [weak self] notification in
                self?.changeBottomConstraintUseKeyboard(rect: CGRect.zero)
            })
    }
    
    private func changeBottomConstraintUseKeyboard(rect: CGRect) {
        UIView.animate(withDuration: 0.25, animations: {
                self.bottomConstraint?.update(offset: -rect.height)
                self.layoutIfNeeded()
        })
    }
}
