//
//  ViewController.swift
//  MyTodoList
//
//  Created by Shiozawa Tomo on 2016/05/29.
//  Copyright © 2016年 Shiozawa Tomo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate{

    //TODOを格納する配列
    var todoList = [MyTodo]()
    
    //入力用のTextField
    var titleTextField: UITextField?
    var deadlineTextField: UITextField?
    var weightTextField: UITextField?
    
    //UIDatePickerの用意(deadline入力用)
    let datePicker = UIDatePicker()
    
    //UIPickerviewの用意(weight入力用)
    let weightPicker = UIPickerView()
    var weightOption = ["ASAP","Normal","In the future"]
    
    //Pickerのツールバー
    var pickerToolBar = UIToolbar()
    
    //日付データのフォーマット用
    let dateFormatter = NSDateFormatter()
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Todoデータの読み込み処理(ここは勉強不足)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let todoListData = userDefaults.objectForKey("todoList") as? NSData {
            if let storedTodoList = NSKeyedUnarchiver.unarchiveObjectWithData(todoListData) as? [MyTodo] {
                todoList.appendContentsOf(storedTodoList)
            }
        }
        
        //datePickerの設定
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.locale = NSLocale(localeIdentifier: NSLocale.currentLocale().localeIdentifier)
        datePicker.minimumDate = NSDate()
        datePicker.addTarget(self, action: #selector(ViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        
        //weightPickerの設定
        weightPicker.delegate = self
        
        // 各種Pickerに表示するツールバーの設定
        pickerToolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        pickerToolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        pickerToolBar.barStyle = .BlackTranslucent
        pickerToolBar.tintColor = UIColor.whiteColor()
        pickerToolBar.backgroundColor = UIColor.blackColor()
        
        //各種Pickerのツールバーに完了ボタンを設定
        let okBarBtn = UIBarButtonItem(title: "OK", style: .Done, target: self, action: #selector(ViewController.okBarBtnPush(_:)))
        let spaceBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace,target: self,action: Selector())
        pickerToolBar.items = [spaceBarBtn,okBarBtn]
        
        
        //dateFotmatterの設定
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        dateFormatter.dateFormat = "yyyy/MM/dd"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
    Addボタンをタップした際に呼ばれる処理
    */
    @IBAction func tapAddButton(sender: AnyObject) {
        //アラートダイアログ生成
        let alertController = UIAlertController(title: "TODO追加", message: "TODOを入力してください", preferredStyle: UIAlertControllerStyle.Alert)
        
        //テキストエリアを追加
        //title用
        alertController.addTextFieldWithConfigurationHandler( { (title: UITextField!) -> Void in
            self.titleTextField = title
            title.placeholder = "Title"
        })
        //deadline用
        alertController.addTextFieldWithConfigurationHandler( { (deadline: UITextField!) -> Void in
            self.deadlineTextField = deadline
            deadline.placeholder = "Deadline"
            deadline.inputView = self.datePicker
            deadline.inputAccessoryView = self.pickerToolBar
        })
        //weight用
        alertController.addTextFieldWithConfigurationHandler( { (weight: UITextField!) -> Void in
            self.weightTextField = weight
            weight.placeholder = "weight"
            weight.inputView = self.weightPicker
            weight.inputAccessoryView = self.pickerToolBar
        })
        
        //OKボタンが押された時の処理
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            (action:UIAlertAction) -> Void in
            
            //アラートのUITextFieldsを全部配列として取得
            let textFields:Array<UITextField>? = alertController.textFields as Array<UITextField>?
            
            //入力されたTodoをtodoListに追加
            if textFields != nil {
                let myTodo = MyTodo()
                //textFieldsの１個目がTitle
                myTodo.title = alertController.textFields![0].text!
                //textFieldsの2個目がDeadline
                myTodo.deadline = alertController.textFields![1].text!
                //作成日時を取得してcreatedAtに入れる
                myTodo.createdAt = self.dateFormatter.stringFromDate(NSDate())
                //重要度を入れる
                let weightText = alertController.textFields![2].text!
                if weightText == "ASAP" {
                    myTodo.weight = 3
                }
                else if weightText == "Normal" {
                    myTodo.weight = 2
                }
                else if weightText == "In the future" {
                    myTodo.weight = 1
                }
                //todoListに追加
                self.todoList.insert(myTodo, atIndex: 0)
            }
            
            //テーブルに行が追加されたことをテーブルに通知
            self.tableView.insertRowsAtIndexPaths(
                [NSIndexPath(forRow: 0, inSection: 0)],
                withRowAnimation: UITableViewRowAnimation.Right)
            
            //保存処理
            //NSData型にシリアライズする
            let data :NSData = NSKeyedArchiver.archivedDataWithRootObject(self.todoList)
            
            //NSUserDefaultsに保存
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(data, forKey: "todoList")
            userDefaults.synchronize()
        }
        //OKボタンを追加
        alertController.addAction(okAction)
        
        //CANCELボタンを追加
        let cancelAction = UIAlertAction(title: "CANCEL",
            style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        //アラートダイアログを表示
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /*
    PickerのOKボタンを押したらPickerを消す
    */
    func okBarBtnPush(sender: AnyObject?){
        deadlineTextField!.resignFirstResponder()
        weightTextField!.resignFirstResponder()
    }
    
    
    /*
    datePickerが変更されたきの処理
    */
    func datePickerValueChanged(sender:UIDatePicker) {
        //deadline用のTextFieldに日付を入れる
        deadlineTextField!.text = dateFormatter.stringFromDate(sender.date)
    }
    
    
    /*
    weightPickeのために必要な関数4つ
    */
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return weightOption[row]
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weightOption.count
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        weightTextField!.text = weightOption[row]
    }
    

    /*
    テーブルの行数を返す
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODOの配列の長さを返す
        return todoList.count
    }
    
    /*
    テーブルの行ごとのセルを返す
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //storyboardで指定したtodoCell識別子を利用して再利用可能なセルを取得する(メモリを有効活用するための処理らしい、勉強不足)
        let cell = tableView.dequeueReusableCellWithIdentifier("todoCell", forIndexPath: indexPath)
        
        //行番号に合ったTODOを取得
        let todo = todoList[indexPath.row]
        
        //セルのラベルにTODOのタイトルをセット
        cell.textLabel!.text = todo.title
        
        //状態によってチェックマークをつける
        if todo.status {
            //完了していたらチェックマーク
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            //未完だったら何もなし
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    /*
    セルをタップした時の処理
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let todo = todoList[indexPath.row]
        
        //完了にするかどうか
        if todo.status {
            //完了済みの場合は未完に変更
            todo.status = false
        }
        else {
            //未完の場合は完了済みに変更
            todo.status = true
            //完了した日付をdoneAtに入れる
            todo.doneAt = self.dateFormatter.stringFromDate(NSDate())
        }
        
        //セルの状態を更新
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        
        //データ保存
        //NSData型にシリアライズする
        let data :NSData = NSKeyedArchiver.archivedDataWithRootObject(todoList)
        
        //NSUserDefaultsに保存
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(data, forKey: "todoList")
        userDefaults.synchronize()
    }
    
    /*
    セルの削除許可(セルが編集可能かどうかを判定する、一応書いておいた)
    */
    func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }

    /*
    セルを削除した時の処理
    */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //削除処理かどうか
        if editingStyle == .Delete {
            
            //todoListから削除
            todoList.removeAtIndex(indexPath.row)
            
            //セルを削除
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            //データ保存
            //NSData型にシリアライズする
            let data :NSData = NSKeyedArchiver.archivedDataWithRootObject(todoList)
            
            //NSUserDefaultsに保存
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(data, forKey: "todoList")
            userDefaults.synchronize()
        }
    }
}

//Todo用のクラス
class MyTodo: NSObject, NSCoding {

    //Todoのタイトル
    var title :String?
    
    //Todoを完了したかどうかを表すフラグ
    var status :Bool = false
    
    //Todoの締め切り
    var deadline :String?
    
    //重要度
    var weight :Int32?
    
    //作成した日時    
    var createdAt :String?
    
    //完了した日時
    var doneAt :String?
    
    //コンストラクタ
    override init() {

    }
    
    //デシリアライズ処理(デコード)
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey("todoTitle") as? String
        status = aDecoder.decodeBoolForKey("todoStatus")
        deadline = aDecoder.decodeObjectForKey("todoDeadline") as? String
        weight = aDecoder.decodeIntForKey("todoWeight") as? Int32
        createdAt = aDecoder.decodeObjectForKey("todoCreatedAt") as? String
        doneAt = aDecoder.decodeObjectForKey("todoDoneAt") as? String
    }
    
    //シリアライズ処理(エンコード)
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "todoTitle")
        aCoder.encodeBool(status, forKey: "todoStatus")
        aCoder.encodeObject(deadline, forKey: "todoDeadline")
        aCoder.encodeInt(weight!, forKey: "todoWeight")
        aCoder.encodeObject(createdAt, forKey: "todoCreatedAt")
        aCoder.encodeObject(doneAt, forKey: "todoDoneAT")
    }
}

