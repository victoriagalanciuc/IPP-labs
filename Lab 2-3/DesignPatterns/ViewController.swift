import UIKit

class ViewController: UIViewController  {

	@IBOutlet var dataTable: UITableView!
	@IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var scroller: HorizontalScroller!
    
    var allAlbums = [Album]()
    var currentAlbumData :  (titles:[String], values:[String])?
    var currentAlbumIndex = 0
    var undoStack: [(Album, Int)] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()

        self.navigationController?.navigationBar.isTranslucent = false
        currentAlbumIndex = 0
        
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        
        dataTable.delegate = self
        dataTable.dataSource = self
        dataTable.backgroundView = nil
        view.addSubview(dataTable!)
        
        self.showDataForAlbum(albumIndex: currentAlbumIndex)
        
        scroller.delegate = self
        reloadScroller()
        
        let undoButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: Selector(("undoAction")))
        undoButton.isEnabled = false
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: Selector(("deleteAlbum")))
        let toolbarButtonItems = [undoButton, space, trashButton]
        toolbar.setItems(toolbarButtonItems, animated: true)
        
        loadPreviousState()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.saveCurrentState), name: .UIApplicationDidEnterBackground , object: nil)
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    func showDataForAlbum(albumIndex: Int) {
        if (albumIndex < allAlbums.count && albumIndex > -1) {
            let album = allAlbums[albumIndex]
            
            currentAlbumData = album.ae_tableRepresentation()
        } else {
            currentAlbumData = nil
        }
        
        dataTable!.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Memento Pattern
    func saveCurrentState() {
        UserDefaults.standard.integer(forKey: "currentAlbumIndex")
        LibraryAPI.sharedInstance.saveAlbums()
    }
    
    func loadPreviousState() {
        currentAlbumIndex = UserDefaults.standard.integer(forKey: "currentAlbumIndex")
        showDataForAlbum(albumIndex: currentAlbumIndex)
    }
    
    func initialViewIndex(scroller: HorizontalScroller) -> Int {
        return currentAlbumIndex
    }
    
    func addAlbumAtIndex(album: Album, index: Int) {
        LibraryAPI.sharedInstance.addAlbum(album: album, index: index)
        currentAlbumIndex = index
        reloadScroller()
    }
    
    func deleteAlbum() {
        let deletedAlbum : Album = allAlbums[currentAlbumIndex]
        
        let undoAction = (deletedAlbum, currentAlbumIndex)
        undoStack.insert(undoAction, at: 0)
        
        LibraryAPI.sharedInstance.deleteAlbum(index: currentAlbumIndex)
        reloadScroller()
        
        let barButtonItems = toolbar.items! as? [UIBarButtonItem]
        let undoButton : UIBarButtonItem = barButtonItems![0]
        undoButton.isEnabled = true
        
        if (allAlbums.count == 0){
            let trashButton: UIBarButtonItem = barButtonItems![2]
            trashButton.isEnabled = false
        }
    }
    
    func undoAction() {
        let barButtonItems = toolbar.items! as? [UIBarButtonItem]
        
        if undoStack.count > 0 {
            let (deletedAlbum, index) = undoStack.remove(at: 0)
            addAlbumAtIndex(album: deletedAlbum, index: index)
        }
        if undoStack.count == 0 {
            let undoButton : UIBarButtonItem = barButtonItems![0]
            undoButton.isEnabled = false
        }
        
        let trashButton : UIBarButtonItem = barButtonItems![2]
        trashButton.isEnabled = true
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let albumData = currentAlbumData {
            return albumData.titles.count
        } else {
        return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        if let albumData = currentAlbumData {
            cell.textLabel!.text = albumData.titles[indexPath.row]
            cell.detailTextLabel!.text = albumData.values[indexPath.row]
        }
        return cell
    }
}

extension ViewController: HorizontalScrollerDelegate {
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index: Int) {
        let previousAlbumView = scroller.viewAtIndex(index: currentAlbumIndex) as! AlbumView
        previousAlbumView.highlightAlbum(didHighlightView: false)
        
        currentAlbumIndex = index
        
        let albumView = scroller.viewAtIndex(index: index) as! AlbumView
        albumView.highlightAlbum(didHighlightView: true)
        
        showDataForAlbum(albumIndex: index)
    }
    
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> Int {
        return allAlbums.count
    }
    
    func horizontalScollerViewAtIndex(scroller: HorizontalScroller, index: Int) -> UIView {
        let album = allAlbums[index]
        let albumView = AlbumView(frame: CGRect(0,0,100,100), albumCover: album.coverUrl)
        if currentAlbumIndex == index {
            albumView.highlightAlbum(didHighlightView: true)
        } else {
            albumView.highlightAlbum(didHighlightView: false)
        }
        return albumView
    }
    
    func reloadScroller() {
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        if currentAlbumIndex < 0 {
            currentAlbumIndex = 0
        } else if currentAlbumIndex >= allAlbums.count {
            currentAlbumIndex = allAlbums.count - 1
        }
        scroller.reload()
        showDataForAlbum(albumIndex: currentAlbumIndex)
    }

}

extension ViewController: UITableViewDelegate {
    
}
