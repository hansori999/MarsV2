//
//  ViewController.swift
//  MarsV2
//
//  Created by Myoung-Wan Koo on 2018. 5. 16..
//  Copyright © 2018년 Myoung-Wan Koo. All rights reserved.
//

import UIKit

enum Feature: Int {
    case solarPanels = 0, greenhouses, size }

class ViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    
    
    /* Initialize CoreML Model */
    let model = MarsHabitatPricer()
    
    /// Formatter for the output.
    let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// When values are changed, update the predicted price.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(" Selected row=",row)
        updatePredictedPrice()
    }
    
    /**
     The main logic for the app, performing the integration with Core ML.
     First gather the values for input to the model. Then have the model generate
     a prediction with those inputs. Finally, present the predicted value to
     the user.
     */
    func updatePredictedPrice() {
        func selectedRow(for feature: Feature) -> Int {
            return pickerView.selectedRow(inComponent: feature.rawValue)
        }
        
        let solarPanels = self.value(for: selectedRow(for: .solarPanels), feature: .solarPanels)
        let greenhouses = self.value(for: selectedRow(for: .greenhouses), feature: .greenhouses)
        let size = self.value(for: selectedRow(for: .size), feature: .size)
        
        print("solarPanels =", solarPanels,greenhouses, size)
        
        guard let marsHabitatPricerOutput = try? model.prediction(solarPanels: solarPanels, greenhouses: greenhouses, size: size) else {
            fatalError("Unexpected runtime error.")
        }
        
        let price = marsHabitatPricerOutput.price
        print(" Result=",price)
        // priceLabel.text = priceFormatter.string(for: price)
    }

    /// Accessor for picker values.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let feature = Feature(rawValue: component) else {
            fatalError("Invalid component \(component) found to represent a \(Feature.self). This should not happen based on the configuration set in the storyboard.")
        }
        
        return self.title(for: row, feature: feature)
    }
    
    
    private let solarPanelsDataSource = SolarPanelDataSource()
    private let greenhousesDataSource = GreenhousesDataSource()
    private let sizeDataSource = SizeDataSource()
    
    // MARK: - Helpers
    
    /// Find the title for the given feature.
    func title(for row: Int, feature: Feature) -> String? {
        switch feature {
        case .solarPanels:  return solarPanelsDataSource.title(for: row)
        case .greenhouses:  return greenhousesDataSource.title(for: row)
        case .size:         return sizeDataSource.title(for: row)
        }
    }
    
    /// For the given feature, find the value for the given row.
    func value(for row: Int, feature: Feature) -> Double {
        let value: Double?
        
        switch feature {
        case .solarPanels:      value = solarPanelsDataSource.value(for: row)
        case .greenhouses:      value = greenhousesDataSource.value(for: row)
        case .size:             value = sizeDataSource.value(for: row)
        }
        
        return value!
    }
    
    // MARK: - UIPickerViewDataSource
    
    /// Hardcoded 3 items in the picker.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    /// Find the count of each column of the picker.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch Feature(rawValue: component)! {
        case .solarPanels:  return solarPanelsDataSource.values.count
        case .greenhouses:  return greenhousesDataSource.values.count
        case .size:         return sizeDataSource.values.count
        }
    }
}

struct SolarPanelDataSource {
    /// Possible values for solar panels in the habitat
    let values = [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]
    
    func title(for index: Int) -> String? {
        guard index < values.count else { return nil }
        return String(values[index])
    }
    
    func value(for index: Int) -> Double? {
        guard index < values.count else { return nil }
        return Double(values[index])
    }
}
struct GreenhousesDataSource {
    /// Possible values for greenhouses in the habitat
    let values = [1, 2, 3, 4, 5]
    
    func title(for index: Int) -> String? {
        guard index < values.count else { return nil }
        return String(values[index])
    }
    
    func value(for index: Int) -> Double? {
        guard index < values.count else { return nil }
        return Double(values[index])
    }
}
struct SizeDataSource {
    /// Helper formatter to represent large nubmers in the picker
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter
    }()
    
    /// Possible values for size of the habitat.
    let values = [
        750,
        1000,
        1500,
        2000,
        3000,
        4000,
        5000,
        10_000
    ]
    
    func title(for index: Int) -> String? {
        guard index < values.count else { return nil }
        return SizeDataSource.numberFormatter.string(from: NSNumber(value: values[index]))
    }
    
    func value(for index: Int) -> Double? {
        guard index < values.count else { return nil }
        return Double(values[index])
    }
}

