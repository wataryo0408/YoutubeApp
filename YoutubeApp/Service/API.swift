//
//  APIRequest.swift
//  YoutubeApp
//
//  Created by 渡邉凌 on 2021/01/27.
//

import Foundation
import Alamofire


class API {
    
    enum PathType: String {
        case search
        case channels
    }
    
    static var shared = API()
    private let baseUrl = "https://www.googleapis.com/youtube/v3/"
    
    func request<T: Decodable>(path: PathType, params: [String: Any], type: T.Type, completion: @escaping (T) -> Void){
        
        let path = path.rawValue
        let url = baseUrl + path + "?"
        var params = params
        params["key"] = "AIzaSyB5X1YDBlpbuuAR00E7UyI1KM0pw6dhzyY"
        params["part"] = "snippet"
        //        let params = [
        //            "key": "AIzaSyB5X1YDBlpbuuAR00E7UyI1KM0pw6dhzyY",
        //            "part": "snippet",
        //            "id": ""
        //        ]
        let request = AF.request(url, method: .get, parameters: params)
        request.responseJSON { (response) in
            do{
                guard let data = response.data else { return }
                let decode = JSONDecoder()
                let value = try decode.decode(T.self, from: data)
                completion(value)
                //                self.videoItems.forEach { (item) in
                //                    item.channel = channel
                //                }
                //            self.videoListCollectionView.reloadData()
            }catch{
                print("変換に失敗しました。",error)
            }
        }
    }
}
