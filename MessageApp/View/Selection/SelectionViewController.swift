//
//  SelectionViewController.swift
//  MessageApp
//
//  Created by Abhijana Agung Ramanda on 16/08/22.
//

import UIKit

class SelectionViewController: UITableViewController {
  private static let ROOTVC_SB_ID = "RootSelectionViewController"
  private let CELL_REUSE_ID = "SelectionCell"
  
  typealias SelectionSavedBlock = ([Int: ProfileListItem]) -> Void
  
  static func createFromStoryboard(dataSource: SelectionDataSource, didSaveSelections: SelectionSavedBlock? = nil) -> UIViewController {
    let storyboardName = String(describing: SelectionViewController.self)
    let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
    let viewController = storyboard.instantiateViewController(identifier: storyboardName) { coder in
      SelectionViewController(coder: coder,
                              dataSource: dataSource,
                              didSaveSelections: didSaveSelections)
    }
    return UINavigationController(rootViewController: viewController)
  }
  
  var didSaveSelections: SelectionSavedBlock?
  private var dataSource: SelectionDataSource
  
  init?(coder: NSCoder, dataSource: SelectionDataSource, didSaveSelections: SelectionSavedBlock?) {
    self.dataSource = dataSource
    self.didSaveSelections = didSaveSelections
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // clearsSelectionOnViewWillAppear = false
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.list.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CELL_REUSE_ID, for: indexPath) as! SelectionCell
    let item = dataSource.list[indexPath.row]
    cell.nameLabel.text = item.name
    cell.accessoryType = dataSource.getSelectedItems()[indexPath.row] == item ? .checkmark : .none
    return cell
  }
  
  // MARK: - Table view delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    dataSource.selected(at: indexPath.row)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
      tableView.reloadData()
    }
  }
  
  @IBAction func didTapCloseButton(_ sender: UIBarButtonItem) {
    dismiss(animated: true)
  }
  
  @IBAction func didTapDecideButton(_ sender: UIBarButtonItem) {
    didSaveSelections?(dataSource.getSelectedItems())
    dismiss(animated: true)
  }
}
