//
//  FCollectionReference.swift
//  iChat
//
//  Created by zeyad on 9/30/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import Foundation
import FirebaseFirestore


enum FCollectionReference: String {
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
}


func reference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
