import UIKit

class PersistencyManager: NSObject {
    
    private var albums = [Album]()
    
    override init() {
        super.init()
        if let data = NSData(contentsOfFile: NSHomeDirectory().appending("/Documents/albums.bin")){
            let unarchiveAlbums = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [Album]?
            if let unwrappedAlbum = unarchiveAlbums {
                albums = unwrappedAlbum
            }
        } else {
            createPlaceHolderAlbum()
        }
    }
    
    func createPlaceHolderAlbum() {
        let album1 = Album(title: "Best of Bowie",
                           artist: "David Bowie",
                           genre: "Pop",
                           coverUrl: "https://ksassets.timeincuk.net/wp/uploads/sites/55/2015/05/2013bowieddavidBowie600g080313.jpg",
                           year: "1992")
        
        let album2 = Album(title: "It's My Life",
                           artist: "No Doubt",
                           genre: "Pop",
                           coverUrl: "https://ksassets.timeincuk.net/wp/uploads/sites/55/2015/05/2013bowieddavidBowie600g080313.jpg",
                           year: "2003")
        
        let album3 = Album(title: "Nothing Like The Sun",
                           artist: "Sting",
                           genre: "Pop",
                           coverUrl: "https://ksassets.timeincuk.net/wp/uploads/sites/55/2015/05/2013bowieddavidBowie600g080313.jpg",
                           year: "1999")
        
        let album4 = Album(title: "Staring at the Sun",
                           artist: "U2",
                           genre: "Pop",
                           coverUrl: "https://ksassets.timeincuk.net/wp/uploads/sites/55/2015/05/2013bowieddavidBowie600g080313.jpg",
                           year: "2000")
        
        let album5 = Album(title: "American Pie",
                           artist: "Madonna",
                           genre: "Pop",
                           coverUrl: "https://ksassets.timeincuk.net/wp/uploads/sites/55/2015/05/2013bowieddavidBowie600g080313.jpg",
                           year: "2000")
        
        albums = [album1, album2, album3, album4, album5]
        saveAlbums()
    }
    
    func getAlbums() -> [Album] {
        return albums
    }
    
    func addAlbum(album: Album, index: Int) {
        if albums.count >= index {
            albums.insert(album, at: index)
        } else {
            albums.append(album)
        }
    }
    
    func deleteAlbumAtIndex(index: Int) {
        albums.remove(at: index)
    }
    
    func saveImage(image: UIImage, filename: String) {
        let path = NSHomeDirectory().appending("/Documents/\(filename)")
        let data = UIImagePNGRepresentation(image)
        
        do {
            try data?.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            print(error)
        }
    }

    func getImage(filename: String) -> UIImage? {
        let path = NSHomeDirectory().appending("/Documents/\(filename)")
        print(path)
        print(URL(fileURLWithPath: path))
    
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .uncachedRead){
            return UIImage(data: data)
        }
         return nil
    }
    
    func saveAlbums() {
        var filename = NSHomeDirectory().appending("/Documents/albums.bin")
        let data = NSKeyedArchiver.archivedData(withRootObject: albums)
        do {
            try data.write(to: URL(fileURLWithPath: filename), options: .atomic)
        } catch {
            print(error)
        }
    }
}
