import UIKit

/**
 * DashboardViewController - A responsive dashboard that adapts to iPhone and iPad
 * Uses UICollectionView with Compositional Layout for maximum flexibility
 */
class DashboardViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Main collection view that holds all dashboard content
    private var collectionView: UICollectionView!
    
    /// Diffable data source for managing collection view data efficiently
    /// Provides automatic animations when data changes
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    // MARK: - Data Models
    
    /**
     * Defines the different sections of the dashboard
     * Each section has its own layout configuration
     */
    enum Section: Int, CaseIterable {
        case header      // User profile and date range
        case metrics     // Total, Unpaid, Paid Bills cards
        case features    // Shop, Users, Items, Report tiles
        case sentUsages  // Bottom section with usage info
        
        /// Section titles (most are empty as they don't need headers)
        var title: String {
            switch self {
            case .header: return ""
            case .metrics: return ""
            case .features: return ""
            case .sentUsages: return "Sent Usages"
            }
        }
    }
    
    /**
     * Data model for individual items in the collection view
     * Flexible structure that can represent different types of content
     */
    struct Item: Hashable {
        let id = UUID()          // Unique identifier for diffable data source
        let title: String        // Main text content
        let subtitle: String?    // Secondary text (optional)
        let value: String?       // Numeric value for metrics (optional)
        let type: ItemType       // Determines which cell type to use
        let colorType: ColorType? // For different metric colors
        
        /// Different types of items that can be displayed
        enum ItemType {
            case header      // Profile header with name and date
            case metric      // Colored metric cards (Total, Unpaid, etc.)
            case feature     // Feature tiles with icons
            case sentUsage   // Usage information rows
        }
        
        enum ColorType {
            case gray    // Total
            case blue    // Unpaid
            case green   // Paid
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()     // Configure collection view and constraints
        configureDataSource()     // Set up diffable data source
        loadData()               // Populate with initial data
        setupNavigationBar()     // Hide navigation bar for custom header
    }
    
    /**
     * Hides the navigation bar since we're using a custom header
     * This gives us full control over the top section appearance
     */
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    /**
     * Sets up the main collection view with proper constraints and cell registration
     * Uses compositional layout for responsive behavior
     */
    private func setupCollectionView() {
        // Create collection view with custom compositional layout
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGray6  // Light gray background like in image
        view.addSubview(collectionView)
        
        // Pin collection view to safe area edges
        // This ensures proper spacing on all devices (iPhone X+, iPad, etc.)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Register all custom cell types with their reuse identifiers
        // Each cell type handles different content (header, metrics, features, etc.)
        collectionView.register(HeaderCell.self, forCellWithReuseIdentifier: HeaderCell.identifier)
//        collectionView.register(MetricCell.self, forCellWithReuseIdentifier: MetricCell.identifier)
        collectionView.register(FeatureCell.self, forCellWithReuseIdentifier: FeatureCell.identifier)
        collectionView.register(SentUsageCell.self, forCellWithReuseIdentifier: SentUsageCell.identifier)
        collectionView.register(UINib(nibName: "MetricCell", bundle: nil), forCellWithReuseIdentifier: MetricCell.identifier)

    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .header:
                return self.createHeaderSection()
            case .metrics:
                return self.createMetricsSection(environment: environment)
            case .features:
                return self.createFeaturesSection(environment: environment)
            case .sentUsages:
                return self.createSentUsagesSection()
            }
        }
        return layout
    }
    
    private func createHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        return section
    }
    
    private func createMetricsSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let containerWidth = environment.container.contentSize.width
        let itemsPerRow: Int
        let itemHeight: CGFloat
        
        // Responsive layout based on container width
        if containerWidth > 768 {
            // iPad or large screens - 3 items per row with larger height
            itemsPerRow = 3
            itemHeight = 100
        } else if containerWidth > 480 {
            // Large phones in landscape - 3 items per row
            itemsPerRow = 3
            itemHeight = 80
        } else if containerWidth > 320 {
            // Standard phones - 3 items per row but smaller
            itemsPerRow = 3
            itemHeight = 70
        } else {
            // Very small screens - 2 items per row, stack vertically
            itemsPerRow = 2
            itemHeight = 80
        }
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / CGFloat(itemsPerRow)),
            heightDimension: .absolute(itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(itemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 20, trailing: 20)
        
        // Add background decoration for the metrics section
        let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: "MetricsBackground")
        backgroundItem.contentInsets = NSDirectionalEdgeInsets(top: -8, leading: -8, bottom: -8, trailing: -8)
        section.decorationItems = [backgroundItem]
        
        return section
    }
    
    private func createFeaturesSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let containerWidth = environment.container.contentSize.width
        let itemsPerRow: Int
        let itemHeight: CGFloat = 100
        
        // Responsive layout based on container width
        if containerWidth > 768 {
            // iPad or large screens - 4 items per row
            itemsPerRow = 4
        } else if containerWidth > 480 {
            // Large phones in landscape - 3 items per row
            itemsPerRow = 3
        } else {
            // Standard phones - 2 items per row
            itemsPerRow = 2
        }
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / CGFloat(itemsPerRow)),
            heightDimension: .absolute(itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        // Calculate number of rows needed
        let totalItems = 4 // We have 4 feature items
        let numberOfRows = Int(ceil(Double(totalItems) / Double(itemsPerRow)))
        
        var groups: [NSCollectionLayoutGroup] = []
        for _ in 0..<numberOfRows {
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(itemHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            groups.append(group)
        }
        
        let containerGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(CGFloat(numberOfRows) * (itemHeight + 8)) // Add spacing between rows
        )
        let containerGroup = NSCollectionLayoutGroup.vertical(layoutSize: containerGroupSize, subitems: groups)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        
        // Add background decoration for the features section
        let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: "FeaturesBackground")
        backgroundItem.contentInsets = NSDirectionalEdgeInsets(top: -8, leading: -8, bottom: -8, trailing: -8)
        section.decorationItems = [backgroundItem]
        
        return section
    }
    
    private func createSentUsagesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16)
        return section
    }
    
    private func configureDataSource() {
        // Register background decoration views
        collectionView.collectionViewLayout.register(BackgroundMetricsDecorationView.self, forDecorationViewOfKind: "MetricsBackground")
        collectionView.collectionViewLayout.register(BackgroundFeatureDecorationView.self, forDecorationViewOfKind: "FeaturesBackground")
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            
            switch item.type {
            case .header:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderCell.identifier, for: indexPath) as! HeaderCell
                cell.configure(title: item.title, subtitle: item.subtitle ?? "")
                return cell
            case .metric:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MetricCell.identifier, for: indexPath) as! MetricCell
                cell.configure(title: item.title, value: item.value ?? "", colorType: item.colorType ?? .gray)
                return cell
            case .feature:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeatureCell.identifier, for: indexPath) as! FeatureCell
                cell.configure(title: item.title, subtitle: item.subtitle ?? "")
                return cell
            case .sentUsage:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SentUsageCell.identifier, for: indexPath) as! SentUsageCell
                cell.configure(title: item.title, subtitle: item.subtitle ?? "")
                return cell
            }
        }
    }
    
    private func loadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        // Header
        snapshot.appendSections([.header])
        snapshot.appendItems([
            Item(title: "Krong Kampuchea", subtitle: "01 JAN → 31 DEC 2025", value: nil, type: .header, colorType: nil)
        ], toSection: .header)
        
        // Metrics
        snapshot.appendSections([.metrics])
        snapshot.appendItems([
            Item(title: "Total", subtitle: nil, value: "$121K", type: .metric, colorType: .gray),
            Item(title: "Unpaid Bills", subtitle: nil, value: "$1K", type: .metric, colorType: .blue),
            Item(title: "Paid Bills", subtitle: nil, value: "$120K", type: .metric, colorType: .green)
        ], toSection: .metrics)
        
        // Features
        snapshot.appendSections([.features])
        snapshot.appendItems([
            Item(title: "Shop", subtitle: "Setup info", value: nil, type: .feature, colorType: nil),
            Item(title: "Users", subtitle: "See last activity", value: nil, type: .feature, colorType: nil),
            Item(title: "Items", subtitle: "View all in stock", value: nil, type: .feature, colorType: nil),
            Item(title: "Report", subtitle: "View summary of sale", value: nil, type: .feature, colorType: nil)
        ], toSection: .features)
        
        // Sent Usages
        snapshot.appendSections([.sentUsages])
        snapshot.appendItems([
            Item(title: "Sent Usages", subtitle: "View data has been sent via Telegram, SMS, and Email", value: nil, type: .sentUsage, colorType: nil)
        ], toSection: .sentUsages)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}


class BackgroundFeatureDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray4
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - Custom Cells

class HeaderCell: UICollectionViewCell {
    static let identifier = "HeaderCell"
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let profileImageView = UIImageView()
    private let calendarButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        profileImageView.backgroundColor = .systemGray4
        profileImageView.layer.cornerRadius = 20
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        calendarButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        calendarButton.tintColor = .systemGray
        calendarButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(profileImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(calendarButton)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            calendarButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            calendarButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            calendarButton.widthAnchor.constraint(equalToConstant: 30),
            calendarButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

class FeatureCell: UICollectionViewCell {
    static let identifier = "FeatureCell"
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 8
        
        iconImageView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        iconImageView.layer.cornerRadius = 8
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.font = .systemFont(ofSize: 11)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

class SentUsageCell: UICollectionViewCell {
    static let identifier = "SentUsageCell"
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.1
        
        iconImageView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        iconImageView.layer.cornerRadius = 8
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
    }
}


//class DashboardViewController: UIViewController {
//    
//    let counterLabel = RollingCounterLabel()
//        let refreshButton = UIButton(type: .system)
//
//        override func viewDidLoad() {
//            super.viewDidLoad()
//            view.backgroundColor = .white
//
//            setupCounterLabel()
//            setupRefreshButton()
//
//            // Initial animation
//            counterLabel.startCounting(from: 0, to: 100, duration: 2.0)
//        }
//
//        private func setupCounterLabel() {
//            counterLabel.frame = CGRect(x: 50, y: 200, width: 300, height: 80)
//            counterLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
//            counterLabel.textColor = .systemBlue
//            counterLabel.textAlignment = .center
//            view.addSubview(counterLabel)
//        }
//
//        private func setupRefreshButton() {
//            refreshButton.setTitle("Refresh Counter", for: .normal)
//            refreshButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
//            refreshButton.tintColor = .white
//            refreshButton.backgroundColor = .systemGreen
//            refreshButton.layer.cornerRadius = 10
//            refreshButton.frame = CGRect(x: 100, y: 300, width: 200, height: 50)
//            refreshButton.center.x = view.center.x
//            refreshButton.addTarget(self, action: #selector(refreshCounter), for: .touchUpInside)
//            view.addSubview(refreshButton)
//        }
//
//        @objc private func refreshCounter() {
//            let randomTo = Int.random(in: 50...200)
//            counterLabel.startCounting(from: 0, to: randomTo, duration: 2.0)
//        }
//    
//}
//
//import UIKit
//
//class RollingCounterLabel: UILabel {
//    
//    private var startValue: Int = 0
//    private var endValue: Int = 0
//    private var animationDuration: TimeInterval = 1.0
//    private var animationStartDate: Date?
//    private var displayLink: CADisplayLink?
//
//    func startCounting(from: Int, to: Int, duration: TimeInterval = 1.0) {
//        self.startValue = from
//        self.endValue = to
//        self.animationDuration = duration
//        self.animationStartDate = Date()
//
//        // Stop any previous animations
//        self.displayLink?.invalidate()
//
//        // Start display link
//        self.displayLink = CADisplayLink(target: self, selector: #selector(updateValue))
//        self.displayLink?.add(to: .main, forMode: .default)
//    }
//
//    @objc private func updateValue() {
//        guard let startDate = animationStartDate else { return }
//
//        let now = Date()
//        let elapsed = now.timeIntervalSince(startDate)
//        let percentage = min(elapsed / animationDuration, 1.0)
//
//        let value = Int(Double(startValue) + percentage * Double(endValue - startValue))
//        self.text = "\(value)"
//
//        if percentage >= 1.0 {
//            displayLink?.invalidate()
//            displayLink = nil
//        }
//    }
//}



// MARK: - Background Decoration View

//class BackgroundMetricsDecorationView: UICollectionReusableView {createMetricsSection(environment
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .white
//        layer.cornerRadius = 20
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 1)
//        layer.shadowRadius = 3
//        layer.shadowOpacity = 0.1
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}




//class MetricCell: UICollectionViewCell {
//    static let identifier = "MetricCell"
//
//    private let titleLabel = UILabel()
//    private let valueLabel = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupViews() {
//        layer.cornerRadius = 8
//
//        titleLabel.font = .systemFont(ofSize: 11)
//        titleLabel.textColor = .white
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        valueLabel.font = .boldSystemFont(ofSize: 16)
//        valueLabel.textColor = .white
//        valueLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        addSubview(titleLabel)
//        addSubview(valueLabel)
//
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
//            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
//
//            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
//            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
//            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
//        ])
//    }
//
//    func configure(title: String, value: String, colorType: DashboardViewController.Item.ColorType) {
//        titleLabel.text = title
//        valueLabel.text = value
//
//        switch colorType {
//        case .gray:
//            backgroundColor = .systemGray4
//        case .blue:
//            backgroundColor = .systemBlue
//        case .green:
//            backgroundColor = .systemGreen
//        }
//    }
//}
