//
//  ImageEntry.swift
//  SimplePhoto
//
//  Created by Naveen Goyal on 05/12/24.
//

import RealmSwift

class ImageEntry: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var filePath: String
    @Persisted var fileName: String
    @Persisted var captureDate: Date = Date()
    @Persisted var isUploaded: Bool = false
    @Persisted var uploadProgress: Float = 0.0
    @Persisted var uploadStatus: String = "Pending"
}

extension ImageEntry {
    var localFilePath: String {
        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName).path
        return filePath
    }
}
