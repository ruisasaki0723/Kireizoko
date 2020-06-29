//
//  TableViewCell.swift
//  Kireizoko
//
//  Created by 佐々木瑠唯 on 2020/06/17.
//  Copyright © 2020 Rui.Sasaki. All rights reserved.
//

import UIKit
import RealmSwift

class TableViewCell: UITableViewCell {

    @IBOutlet weak var cellimageView: UIImageView!
    @IBOutlet weak var konyubiLabel: UILabel!
    @IBOutlet weak var zannissuLabel: UILabel!
    @IBOutlet weak var suryoSlider: UISlider!
    @IBOutlet weak var suryoLabel: UILabel!
    
    // スライダーを動かした際にその位置の値をラベルに設定
    @IBAction func suryoSliderAction(_ sender: Any) {
        let value = Int(suryoSlider.value)
        self.suryoLabel.text = String(value)
        let actionValue = Int(suryoSlider.value)
        
        try! realm.write {
            self.task.suryoValue = actionValue
        }
    }
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    var task: Task!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setTaskData(_ taskData: Task) {
        
        self.cellimageView.image = UIImage(data: taskData.image)
        
        // 購入日ラベルに追加した日時を
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString:String = formatter.string(from: taskData.konyubi)
        self.konyubiLabel.text = dateString
        
        // 残日数の設定(賞味期限 - 購入日)
        let interval = taskData.shomikigen.timeIntervalSince(taskData.konyubi)
        let zannissu: Int = Int(interval/60/60/24+1)
        // 残日数をStringに変換してラベルに設定
        let zannissuString: String = String(zannissu)
        self.zannissuLabel.text = zannissuString
        
        // 数量スライダーの設定
        suryoSlider.minimumValue = 0;
        suryoSlider.maximumValue = Float(taskData.suryo);
        suryoSlider.value = Float(taskData.suryoValue);
        let value = Int(suryoSlider.value)
        self.suryoLabel.text = String(value)
        self.suryoLabel.text = String(taskData.suryo)
        
        self.task = taskData
    }
}
