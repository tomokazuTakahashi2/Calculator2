//
//  ViewController.swift
//  Calculator
//
//  Created by Raphael on 2020/09/28.
//コレクションビューを使った計算機

import UIKit

class ViewController: UIViewController {
    
     //状態の管理
     enum CalculateStatus {
         //none、たし算、ひき算、かけ算、わり算
         case none, plus, minus, multiplication, division
     }
     
     var firstNumber = ""
     var secondNumber = ""
     var calculateStatus: CalculateStatus = .none
     
     //４列が５行
     let numbers = [
     ["C","%","$","÷"],
     ["7","8","9","×"],
     ["4","5","6","-"],
     ["1","2","3","+"],
     ["0","00",".","="],
     ]

     @IBOutlet weak var label1: UILabel!
     @IBOutlet weak var collectionView: UICollectionView!
     @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         collectionView.delegate = self
         collectionView.dataSource = self
         collectionView.register(CalculatorViewCell.self, forCellWithReuseIdentifier: "cellId")
         collectionHeightConstraint.constant = view.frame.width * 1.4
         collectionView.backgroundColor = .clear
         collectionView.contentInset = .init(top: 0, left: 14, bottom: 0, right: 14)
         
         view.backgroundColor = .black
     }

    //クリアー
    func clear() {
        firstNumber = ""
        secondNumber = ""
        label1.text = "0"
        calculateStatus = .none
    }
}
//MARK: -コレクションビュー
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    //セクションの数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numbers.count
    }
    //セルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers[section].count
    }
    //UICollectionViewDelegateFlowLayout
    //ヘッダーの大きさの変更
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return .init(width: collectionView.frame.width, height: 10)
    }
    //セルの大きさを変更
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //幅＝(コレクションビューのフレームサイズ - 3 * 10) ÷４
        let width = ((collectionView.frame.width - 10) - 14 * 5) / 4
        
        return .init(width: width, height: width)
    }
    //セルの隙間の間隔
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
    //セルの情報
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! CalculatorViewCell
        //numbers配列の文字を表示
        cell.numberLabel.text = numbers[indexPath.section][indexPath.row]
        
        //各セクション、各ロー、それぞれ（forEach）に処理を行う
        numbers[indexPath.section][indexPath.row].forEach{(numberString) in
            //もし、"０〜９"または"."だったら、
            if "0"..."9" ~= numberString || numberString.description == "."{
                //ダークグレーにする
                cell.numberLabel.backgroundColor = .darkGray
            }else if numberString == "C" || numberString == "%" || numberString == "$" {
                cell.numberLabel.backgroundColor = UIColor.init(white: 1, alpha: 0.7)
                cell.numberLabel.textColor = .black
            }
        }
        
        return cell
    }
    //セルをタップしたら
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let number = numbers[indexPath.section][indexPath.row]
        
        switch calculateStatus {
        //.noneの時、
        case .none:
            switch number {
            //数字を押したら、
            case "0"..."9":
                firstNumber += number
                label1.text = firstNumber
                //0が連続で打てなくする
                if firstNumber.hasPrefix("0"){
                    firstNumber = ""
                }
            //"."を押したら、
            case ".":
                if !confirmIncludeDecimalPoint(numberString: firstNumber){
                    firstNumber += number
                    label1.text = firstNumber
                }
            //プラスボタンを押したら、
            case "+":
                //たし算を発動
                calculateStatus = .plus
            //マイナスボタンを押したら、
            case "-":
                //ひき算を発動
                calculateStatus = .minus
            //"×"ボタンを押したら、
            case "×":
                //かけ算を発動
                calculateStatus = .multiplication
            //"÷"ボタンを押したら、
            case "÷":
                //わり算を発動
                calculateStatus = .division
            //"C"を押したら、
            case "C" :
                clear()
            default:
                break
            }
        //たし算、ひき算、かけ算、わり算　の時、
        case .plus, .minus, .multiplication, .division:
            switch number {
            //数字を押したら、
            case "0"..."9":
                secondNumber += number
                label1.text = secondNumber
                //0が連続で打てなくする
                if secondNumber.hasPrefix("0"){
                    secondNumber = ""
                }
            //"."を押したら、
            case ".":
                if !confirmIncludeDecimalPoint(numberString: secondNumber){
                    secondNumber += number
                    label1.text = secondNumber
                }
            // = を押したら、
            case "=":
                
                let firstNum = Double(firstNumber) ?? 0
                let secondNum = Double(secondNumber) ?? 0
                
                var resultString: String?
                
                switch calculateStatus {
                //たし算の時
                case .plus:
                    resultString = String (firstNum + secondNum)
                //ひき算の時
                case .minus:
                    resultString = String (firstNum - secondNum)
                //かけ算の時
                case .multiplication:
                    resultString = String (firstNum * secondNum)
                //わり算の時
                case .division:
                    resultString = String (firstNum / secondNum)
                
                default:
                    break
                }
                //.0になるものは".0"を省く
                if let result = resultString,result.hasSuffix(".0"){
                    resultString = result.replacingOccurrences(of: ".0", with: "")
                }
                label1.text = resultString
                //一旦空にする
                firstNumber = ""
                secondNumber = ""
                
                firstNumber += resultString ?? ""
                calculateStatus = .none
                
            //"C"を押したら、
            case "C" :
                clear()
                
            default:
                break
            }
        }
    }
    //numberStringに"."または"0"が含まれているかどうか
    private func confirmIncludeDecimalPoint(numberString: String) -> Bool{
        if numberString.range(of: ".") != nil || numberString.count == 0{
            return true
        }else{
            return false
        }
    }
}
//MARK:- CalculatorViewCell
class CalculatorViewCell: UICollectionViewCell {
    //ボタンを押してる間だけ色を薄くする
    override var isHighlighted: Bool{
        didSet {
            if isHighlighted {
                self.numberLabel.alpha = 0.3
            }else {
                self.numberLabel.alpha = 1
            }
        }
    }
    
    let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = "1"
        label.font = .boldSystemFont(ofSize: 32)
        label.clipsToBounds = true
        label.backgroundColor = .orange
        return label
    }()
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        addSubview(numberLabel)
        
        numberLabel.frame.size = self.frame.size
        //丸み
        numberLabel.layer.cornerRadius = self.frame.height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
