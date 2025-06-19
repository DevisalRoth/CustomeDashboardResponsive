//
//  MetricCell.swift
//  CustomeDashboardResponsive
//
//  Created by Visalroth on 17/6/25.
//

import UIKit


class MetricCell: UICollectionViewCell {
    static let identifier = "MetricCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    // MARK: - Initializing Cell from XIB
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Ensure the cell is loaded from the XIB file
//        guard let contentView = Bundle.main.loadNibNamed("MetricCell", owner: self, options: nil)?.first as? UIView else {
//            fatalError("Could not load MetricCell from nib.")
//        }
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    func configure(title: String, value: String, colorType: DashboardViewController.Item.ColorType) {
        titleLabel.text = title
        valueLabel.text = value
        
        // Set the background color based on the colorType
        switch colorType {
        case .gray:
            backgroundColor = .systemGray4
        case .blue:
            backgroundColor = .systemBlue
        case .green:
            backgroundColor = .systemGreen
        }
    }
}

