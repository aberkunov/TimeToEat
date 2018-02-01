//
//  SettingsViewController.swift
//  TimeToEat
//
//  Created by Alexander Berkunov on 04.05.17.
//  Copyright © 2017 MB. All rights reserved.
//

import UIKit

protocol SettingsViewControllerInterface: class {
    func displaySettings(viewModel: SettingsModel.Load.ViewModel)
    func displaySavedSettings(viewModel: SettingsModel.Save.ViewModel)
    
    func displayDrinkingWaterPicker(viewModel: SettingsModel.Select.ViewModel)
    func displayMealsOrderSetting(viewModel: SettingsModel.Select.ViewModel)}

class SettingsViewController: UITableViewController, SettingsViewControllerInterface {
    fileprivate enum SettingsConstants {
        static let PickerGlassesCountComponent = 0      // the first column in the UIPickerView
        static let PickerGlassVolumeComponent = 1       // the second column in the UIPickerView
    }
    
    var interactor: SettingsInteractorInterface?
    var router: (SettingsRouting & SettingsDataPassing)?
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var consumedWaterLabel: UILabel!
    @IBOutlet weak var mealOrderLabel: UILabel!
    @IBOutlet weak var hiddenTextField: UITextField!
    
    // MARK: - Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let viewController = self
        let interactor = SettingsInteractor()
        let presenter = SettingsPresenter()
        let router = SettingsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Settings", comment: "")
        
        // configure UI elements
        configureSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // load current settings
        interactor?.loadSettings(request: SettingsModel.Load.Request())
    }
    
    // MARK: Routing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.passDataToNextScene(segue: segue)
    }
    
    @IBAction func toolbarDoneAction(_ sender: UIBarButtonItem?) {
        hiddenTextField.resignFirstResponder()
        
        // save consumed drinking water settings
        let selectedGlassCountIndex = pickerView.selectedRow(inComponent: SettingsConstants.PickerGlassesCountComponent)
        let selectedGlassVolumeIndex = pickerView.selectedRow(inComponent: SettingsConstants.PickerGlassVolumeComponent)
        let selectedGlassCount = Constants.Settings.GlassesRange[selectedGlassCountIndex]
        let selectedGlassVolume = Constants.Settings.GlassVolumeRange[selectedGlassVolumeIndex]
        interactor?.saveSettings(request: SettingsModel.Save.Request(numberOfGlasses: selectedGlassCount, glassVolume: selectedGlassVolume))
        
        // deselect the selected row in the tableview
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    // MARK: - Display logic
    func displaySettings(viewModel: SettingsModel.Load.ViewModel) {
        consumedWaterLabel.text = viewModel.consumedDrinkingWater
        mealOrderLabel.text = viewModel.orderedMeals
        
        // select rows in the picker
        let currentGlassCount = viewModel.numberOfGlasses
        let currentGlassVolume = viewModel.glassVolume
        if let indexGlassCount = Constants.Settings.GlassesRange.index(of: currentGlassCount), let indexGlassVolume = Constants.Settings.GlassVolumeRange.index(of: currentGlassVolume) {
            pickerView.selectRow(indexGlassCount, inComponent: SettingsConstants.PickerGlassesCountComponent, animated: true)
            pickerView.selectRow(indexGlassVolume, inComponent: SettingsConstants.PickerGlassVolumeComponent, animated: true)
        }
    }
    
    func displaySavedSettings(viewModel: SettingsModel.Save.ViewModel) {
        consumedWaterLabel.text = viewModel.consumedDrinkingWater
    }
    
    func displayDrinkingWaterPicker(viewModel: SettingsModel.Select.ViewModel) {
        hiddenTextField.becomeFirstResponder()
    }
    
    func displayMealsOrderSetting(viewModel: SettingsModel.Select.ViewModel) {
        // save consumed water settings before navigating to meal order
        if hiddenTextField.isFirstResponder {
            toolbarDoneAction(nil)
        }
        
        router?.navigateToMealsOrderScene()
    }
    
    // MARK: - Private
    func configureSubviews() {
        hiddenTextField.inputView = pickerView
        hiddenTextField.inputAccessoryView = toolbar
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let type = SettingType(rawValue: indexPath.row) {
            let request = SettingsModel.Select.Request(type: type)
            interactor?.selectSetting(request: request)
        }
    }
}

// MARK: - UIPickerView delegate methods
extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == SettingsConstants.PickerGlassesCountComponent ? Constants.Settings.GlassesRange.count : Constants.Settings.GlassVolumeRange.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == SettingsConstants.PickerGlassesCountComponent {
            let glassesCount = Constants.Settings.GlassesRange[row]
            let description = (glassesCount == 1) ? NSLocalizedString("glass", comment: "") : NSLocalizedString("glasses", comment: "")
            return "\(glassesCount) " + description
        }
        else {
            let glassVolume = Constants.Settings.GlassVolumeRange[row]
            return "\(glassVolume) " + NSLocalizedString("ml", comment: "")
        }
    }
}
