//
//  PostDefaultAPI.swift
//  SamplePost
//
//  Created by mtanaka on 2022/08/08.
//

import UIKit
import RxSwift
import Firebase

protocol PostAPI {
    func post(text:String, imageArray:[UIImage]) -> Single<Bool>
}

final class PostDefaultAPI: PostAPI {
    
    func post(text: String, imageArray: [UIImage]) -> Single<Bool> {
        //Observableを作成
        return Single.create { single in
            let dic = [
                    "text": text,
                    "imageArray": imageArray
            ] as [String : Any]
            
            Firestore.firestore().collection("post").document("hoge").setData(dic) { err in
                
                if let err = err {
                    
                    single(.failure(err))
                } else {
                
                single(.success(true))
                }
            }
            //disposableを作成
            return Disposables.create()
        }
    }
}
