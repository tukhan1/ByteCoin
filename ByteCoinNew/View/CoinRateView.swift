//
//  CoinRateView.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 09.02.2022.
//

import UIKit
import SnapKit

class CoinRateView: UIView {
    var currency = ""
    let coinPickerView: UIPickerView = UIPickerView(frame: .zero)
    let coinLabel: UILabel = UILabel(frame: .zero)
    let coinView: UIView = UIView(frame: .zero)
    
    private let viewForPicker: UIView = UIView(frame: .zero)
    private let coinImageView: UIImageView = UIImageView(frame: .zero)
    private let currencyDesignation: UILabel = UILabel(frame: .zero)
    
    func commonInit() {
        configureView()
        makeConstraints()
    }
    
    private func configureView() {
        self.addSubview(coinView)
        coinView.addSubview(coinImageView)
        coinView.addSubview(coinLabel)
        coinView.addSubview(currencyDesignation)
        self.addSubview(viewForPicker)
        viewForPicker.addSubview(coinPickerView)
        
        self.backgroundColor = UIColor(named: "Background_Color")
        viewForPicker.backgroundColor = UIColor(named: "Background_Color")
        coinView.backgroundColor = UIColor(named: "Title_Color")
        coinView.layer.cornerRadius = 10.0
        coinImageView.image = UIImage(systemName: "bitcoinsign.circle.fill")
        coinLabel.textAlignment = .center
        coinLabel.numberOfLines = 0
        currencyDesignation.text = currency
        coinLabel.textColor = UIColor(named: "Icon_Color")
        currencyDesignation.textColor = UIColor(named: "Icon_Color")
        coinImageView.tintColor = UIColor(named: "Icon_Color")
    }
    
    private func makeConstraints() {
        coinView.snp.makeConstraints { maker in
            maker.centerX.equalTo(self.snp.centerX)
            maker.centerY.equalTo(self.snp.centerY)
            maker.right.equalTo(currencyDesignation.snp.right).offset(10.0)
            maker.height.equalTo(coinImageView.snp.height).offset(10.0)
        }
        coinImageView.snp.makeConstraints { maker in
            maker.left.equalTo(coinView.snp.left).offset(10.0)
            maker.centerY.equalTo(coinView.snp.centerY)
            maker.width.equalTo(self.snp.height).multipliedBy(0.1)
            maker.height.equalTo(coinImageView.snp.width)
        }
        coinLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(coinView.snp.centerY)
            maker.width.greaterThanOrEqualTo(self.snp.width).multipliedBy(0.2)
            maker.left.equalTo(coinImageView.snp.right).offset(10.0)
        }
        currencyDesignation.snp.makeConstraints { maker in
            maker.left.equalTo(coinLabel.snp.right).offset(10.0)
            maker.right.equalTo(coinView.snp.right).inset(10.0)
            maker.width.equalTo(50.0)
            maker.centerY.equalTo(coinView.snp.centerY)
        }
        viewForPicker.snp.makeConstraints { maker in
            maker.top.equalTo(coinView.snp.bottom).offset(10.0)
            maker.left.equalTo(self.snp.left)
            maker.right.equalTo(self.snp.right)
            maker.bottom.equalTo(self.snp.bottom)
        }
        coinPickerView.snp.makeConstraints { maker in
            maker.top.equalTo(viewForPicker.snp.top)
            maker.bottom.equalTo(viewForPicker.safeAreaLayoutGuide.snp.bottom)
            maker.left.equalTo(self.snp.left)
            maker.right.equalTo(self.snp.right)
        }
    }
}
