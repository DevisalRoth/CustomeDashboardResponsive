//
//  BackgroundMetricsDecorationView.swift
//  CustomeDashboardResponsive
//
//  Created by Chou visalroth on 18/6/25.
//

import UIKit

class BackgroundMetricsDecorationView: UICollectionReusableView {
    
    // MARK: - Initializing View from XIB
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Ensure the view is loaded from the XIB file
        guard let contentView = Bundle.main.loadNibNamed("BackgroundMetricsDecorationView", owner: self, options: nil)?.first as? UIView else {
            fatalError("Could not load BackgroundMetricsDecorationView from nib.")
        }
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Custom initialization if necessary
    }
}

