//
//  ViewController.swift
//  YoutubeApp
//
//  Created by 渡邉凌 on 2021/01/26.
//

import UIKit
import Alamofire

class VideoListViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var videoListCollectionView: UICollectionView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
    private var prevContentOffset: CGPoint = .init(x: 0, y: 0)
    private let headerMoveHeight: CGFloat = 7
    
    
    private let cellId = "cellId"
    private let atentionCellId = "atentionCellId"
    private var videoItems = [Item]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpViews()
        fetchYoutubeSerachInfo()
    }
    
    private func setUpViews(){
        
        videoListCollectionView.delegate = self
        videoListCollectionView.dataSource = self
        videoListCollectionView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
        videoListCollectionView.register(AtentionCell.self, forCellWithReuseIdentifier: atentionCellId)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        
    }
    
    private func fetchYoutubeSerachInfo(){
        
        let params = ["q": "tokaionair"]
        
        API.shared.request(path: .search, params: params, type: Video.self) { (video) in
            self.videoItems = video.items
            let id = self.videoItems[0].snippet.channelId
            self.fetchYoutubeChannelInfo(id: id)
        }
    }
    private func fetchYoutubeChannelInfo(id: String){
        
        let params = [
            "id": id
        ]
        API.shared.request(path: .channels, params: params, type: Channel.self) { (channel) in
            self.videoItems.forEach { (item) in
                item.channel = channel
            }
            self.videoListCollectionView.reloadData()
        }
    }

    
    private func headerViewEndAnimation(){
        if headerTopConstraint.constant < -headerHeightConstraint.constant / 2{
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: [], animations: {
                
                self.headerTopConstraint.constant = -self.headerHeightConstraint.constant
                self.headerView.alpha = 0
                self.view.layoutIfNeeded()
            })
        }else{
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: [], animations: {
                
                self.headerTopConstraint.constant = 0
                self.headerView.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
    }
}
//MARK: - scrollViewのDelegateメソッド
extension VideoListViewController{
    
    //    scrollviewがscrollしたとき
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            headerAnimation(scrollView: scrollView)
        }
        
        private func headerAnimation(scrollView: UIScrollView){
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                self.prevContentOffset = scrollView.contentOffset
            }
            
            guard let presentIndexPath = videoListCollectionView.indexPathForItem(at: scrollView.contentOffset) else { return }
            if scrollView.contentOffset.y < 0 { return }
            if presentIndexPath.row >= videoItems.count - 2 { return }
            let alphaRatio = 1 / headerHeightConstraint.constant
            if self.prevContentOffset.y < scrollView.contentOffset.y{
                if headerTopConstraint.constant <= -headerHeightConstraint.constant{ return }
                headerTopConstraint.constant -= headerMoveHeight
                headerView.alpha -= alphaRatio * headerMoveHeight
            }else if self.prevContentOffset.y > scrollView.contentOffset.y{
                if headerTopConstraint.constant >= 0{ return }
                headerTopConstraint.constant += headerMoveHeight
                headerView.alpha += alphaRatio * headerMoveHeight
            }
            
        }
    //    scrollviewのscrollを自分で止めたとき
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate{
                headerViewEndAnimation()
            }
        }
    //    scrollviewのscrollが惰性で止まったとき
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            headerViewEndAnimation()
        }
    
}
//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension VideoListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        
        if indexPath.row == 2{
            
            return .init(width: width, height: 200)
        }
        return .init(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoItems.count + 1
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 2{
            let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: atentionCellId, for: indexPath) as! AtentionCell
            cell.videoItems = self.videoItems
            return cell
            
        }else{
            let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! VideoListCell
            
            if self.videoItems.count == 0{ return cell }
            if indexPath.row > 2{
                cell.videoItem = videoItems[indexPath.row - 1]
            }else{
                cell.videoItem = videoItems[indexPath.row]
            }
            return cell
        }
    }
}
