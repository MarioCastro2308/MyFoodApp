//
//  MealCell.swift
//  MyFoodApp
//
//  Created by Mario Castro on 20/07/23.
//

import UIKit

class MealCell: UITableViewCell {

    @IBOutlet weak var complementsTableView: UITableView!
    @IBOutlet weak var mealTitleLabel: UILabel!
    
    var complements : [String]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        complementsTableView.dataSource = self
        complementsTableView.delegate = self
//        complementsTableView.tag = 90
        complementsTableView.register(UINib(nibName: "ComplementCell", bundle: nil), forCellReuseIdentifier: "ComplementCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//MARK: - UITableViewDelegate Methods

extension MealCell : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
}

//MARK: - UITableViewDataSource Methods

extension MealCell : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return complements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComplementCell", for: indexPath) as! ComplementCell
        cell.complementTitleLbl.text = complements![indexPath.row]
        cell.layoutIfNeeded()
        return cell
    }
}

//extension MealCell {
//    func setTableViewDataSourceDelegate<D: UITableViewDelegate & UITableViewDataSource>(_ dataSourceDelegate : D, forRow row : Int){
//        complementsTableView.dataSource = dataSourceDelegate
//        complementsTableView.delegate = dataSourceDelegate
//        complementsTableView.reloadData()
//    }
//}
