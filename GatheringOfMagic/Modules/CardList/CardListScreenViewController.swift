//
//  CardListScreenViewController.swift
//  GatheringOfMagic
//
//  Created by Eduardo Oliveira on 05/10/22.
//

import UIKit

protocol CardListCollectionViewCellDelegate {
}

class CardListScreenViewController: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cardListCollectionView: UICollectionView!
    
    // MARK: - Properties
    var presenter: CardListScreenPresenter!
    var timer: Timer?
    var isPaginating: Bool = false
    // MARK: - View Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.didLoad()
        self.blurBackground()
        configureUI()
        loadCards(name: "")
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.willAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.didAppear()
        self.reloadData()
    }
    
    // MARK: - Methods
    private func configureUI() {
        prepareImageTitle()
        prepareCollection()
        prepareSearchBar()
    }
    
    private func prepareImageTitle() {
        let navController = navigationController!
        let image = UIImage(named: "MagicIcon.png")
        let imageView = UIImageView(image: image)
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
        let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    
    private func prepareCollection() {
        self.cardListCollectionView.delegate = self
        self.cardListCollectionView.dataSource = self
        CardListCollectionViewCell.registerNib(for: cardListCollectionView)
        self.cardListCollectionView.contentMode = .center
        self.cardListCollectionView.showsHorizontalScrollIndicator = false
        self.cardListCollectionView.backgroundColor = UIColor.clear
    }
    
    private func prepareSearchBar() {
        self.searchBar.delegate = self
        self.searchBar.barTintColor = UIColor.clear
        self.searchBar.backgroundColor = UIColor.clear
        self.searchBar.isTranslucent = true
        self.searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
    }
    
    func loadCards(name: String) {
        presenter.loadCards(name: name, completion: { [self] in
            reloadData()
        })
    }
    
    func reloadData() {
        presenter.updateFavorites()
        cardListCollectionView.reloadData()
    }

    // MARK: - Actions    
    func navigateToCardDetail(cardId: String, isFavorited: Bool) {
        self.presenter.navigateToCardDetail(cardId: cardId, isFavorited: isFavorited)
    }
}

// MARK: - CardListScreenPresenterDelegate
extension CardListScreenViewController: CardListScreenPresenterDelegate {
    func didLoadRemoteConfig() {
    }
}

extension CardListScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.currentCards?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CardListCollectionViewCell.dequeueCell(from: collectionView, for: indexPath)
        cell.fill(
            name: presenter.currentCards?[indexPath.row].name,
            imageURL: presenter.currentCards?[indexPath.row].imageUrl,
            isFavorited: presenter.isFavorited(card: presenter.currentCards?[indexPath.row])
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let card = presenter.currentCards?[indexPath.row] else { return }
        navigateToCardDetail(
            cardId: card.id ?? "",
            isFavorited: presenter.isFavorited(card: presenter.currentCards?[indexPath.row]))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  25
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/3, height: 187)
    }
}

// MARK: - Search Bar Delegate
extension CardListScreenViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
            self.loadCards(name: searchText)
            self.timer?.invalidate()
        }
    }
}

// MARK: - Infinite Scroll
extension CardListScreenViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if ((position > cardListCollectionView.contentSize.height -  scrollView.frame.size.height + 100) && (!isPaginating)) {
            isPaginating = true
            SnackBarHelper.shared.showToast(message: CardListScreenTexts.loadingMoreCards.localized())
            presenter.loadMoreCards(name: searchBar.text ?? "", completion: { [self] in
                SnackBarHelper.shared.hideToast()
                reloadData()
                isPaginating = false
            })
        }
    }
}
