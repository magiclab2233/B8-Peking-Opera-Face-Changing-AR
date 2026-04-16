//
//  BottomSheetFacePickerView.swift
//  ARKitFaceExample
//
//  Created by SenseTime on 2025/5/7.
//  Copyright © 2025 Apple. All rights reserved.
//

import UIKit

class BottomSheetFacePickerView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    var showing:Bool = false
    var faceMaterials: [String] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var didSelectFace: ((String) -> Void)?
    private var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .white
        // 设置 collectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical  // 修改为纵向滚动
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "FaceCell")
        collectionView.backgroundColor = .white
        addSubview(collectionView)
    }
    
    // MARK: - UICollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return faceMaterials.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FaceCell", for: indexPath)
        
        // 设置图片
        let imageView = UIImageView(frame: cell.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: faceMaterials[indexPath.item])
        cell.contentView.addSubview(imageView)
        
        return cell
    }
    
    // MARK: - UICollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 选择了某个脸谱
        didSelectFace?(faceMaterials[indexPath.item])
    }
    
    // 显示和隐藏的动画效果
    func show(in view: UIView) {
        showing = true
        self.frame = CGRect(x: view.frame.width, y: 0, width: 250, height: view.frame.height) // 从右侧显示
        view.addSubview(self)
        
        UIView.animate(withDuration: 0.3) {
            self.frame.origin.x = view.frame.width - 250 // 滑动至右侧
        }
    }
    
    func hide() {
        if showing == true {
            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin.x = self.superview!.frame.width // 向右边隐藏
            }) { _ in
                self.removeFromSuperview()
                self.showing = false
            }
        }
       
    }
}
