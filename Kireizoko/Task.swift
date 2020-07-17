//
//  Task.swift
//  Kireizoko
//
//  Created by 佐々木瑠唯 on 2020/05/25.
//  Copyright © 2020 Rui.Sasaki. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // 画像
    @objc dynamic var image = Data()
    
    // 賞味期限
    @objc dynamic var shomikigen = Date()
    
    // 数量
    @objc dynamic var suryo = 0
    
    // 数量(変更後の値)
    @objc dynamic var suryoValue = 0
    
    // 購入日
    @objc dynamic var konyubi = Date()
    
    // カテゴリー
    @objc dynamic var category = String()
    
    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
