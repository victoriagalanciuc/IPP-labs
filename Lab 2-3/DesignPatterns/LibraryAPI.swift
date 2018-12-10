import UIKit

class LibraryAPI: NSObject {
    
    private let persistencyManager: PersistencyManager
    private let httpClient: HTTPClient
    private let isOnline: Bool
    
    class var sharedInstance: LibraryAPI{
    
        struct Singleton {
            static let instance = LibraryAPI()
        }
    
        return Singleton.instance
    }
    
    override init() {
        persistencyManager = PersistencyManager()
        httpClient = HTTPClient()
        isOnline = false
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: Selector("downloadImage:"), name: NSNotification.Name(rawValue: "BLDownoadImageNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getAlbums() -> [Album] {
        return persistencyManager.getAlbums()
    }
    
    func addAlbum(album: Album, index: Int) {
        persistencyManager.addAlbum(album: album, index: index)
        if isOnline {
            httpClient.postRequest("/api/addAlbum", body: album.description)
        }
    }
    
    func deleteAlbum(index: Int) {
        persistencyManager.deleteAlbumAtIndex(index: index)
        if isOnline {
            httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
        }
    }
    
    func saveAlbums() {
        persistencyManager.saveAlbums()
    }
    
    func downloadImage(notification: NSNotification) {
        //1
        let userInfo = notification.userInfo as! [String: AnyObject]
        var imageView = userInfo["imageView"] as! UIImageView?
        let coverUrl = userInfo["coverUrl"] as! String
        
        //2
        if let imageViewUnWrapped = imageView {
            imageViewUnWrapped.image = persistencyManager.getImage(filename: (coverUrl as NSString).lastPathComponent)
            if imageViewUnWrapped.image == nil {
                //3
               // dispatch_async(DispatchQueue.global(DispatchQueue.GlobalQueuePriority.default, 0), { () -> Void in
                DispatchQueue.main.async {
                    
                    let downloadedImage = self.httpClient.downloadImage(coverUrl as String)
                    //4
                    DispatchQueue.main.sync(execute: { () -> Void in
                        imageViewUnWrapped.image = downloadedImage
                        self.persistencyManager.saveImage(image: downloadedImage, filename: (coverUrl as NSString).lastPathComponent)
                    })
                }
            }
        }
    }
}
