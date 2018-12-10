# Design Patterns Laboratory Work 2-3
## Task
Implementing 3 structural patterns and 4 any other design patterns. 

*Creational patterns:*
+ Singleton

*Structural patterns:*
+ Decorator
+ Adapter
+ Facade
+ MVC

*Behavioural patterns:*
+ Observer
+ Memento

In order to illustrate the design patterns I have created a simple iOS application that displays music library albums and their relevant information.
Code written in Swift 4, iOS 11, Xcode 9.

## Singleton Pattern
**Intent**
Ensures that a class has only one instance, and there is a global point of access to that instance. It usually uses lazy loading to create the single instance when it’s needed the first time.
**Implementation**
To ensure there is only one instance of your singleton, it must be impossible for anyone else to make an instance. Swift allows to do this by marking the initializers as `private`. This pattern was implemented by creating a singleton class to manage all the album data.
```swift
final class LibraryAPI {
  // gives other objects access to the singleton object LibraryAPI.
  static let shared = LibraryAPI()
  // prevents creating new instances of LibraryAPI from outside
  private init() {

  }
}
```

## Factory Method Pattern
**Intent**
Creating an object without exposing the creation logic to the client and refer to newly created object using a common interface. The goal of this pattern is to encapsulate something that can often vary. In this case, this is the information about the albums we want to include in the application. 
**Implemenation**
```
class Album: NSObject, NSCoding {

var title: String!
var artist: String!
var genre: String!
var coverUrl: String!
var year: String!

init(title: String, artist: String, genre: String, coverUrl: String, year: String) {
self.title = title
self.artist = artist
self.genre = genre
self.coverUrl = coverUrl
self.year = year
}
```

## Facade Pattern
**Intent**
Hides the complexities of the system and provides an interface to the client using which the client can access the system. Instead of exposing the user to a set of classes and their APIs, you only expose one simple unified API. 
**Implementation**
The classes `PersistencyManager` saves the album data locally and the `HTTPClient` handles remote communication. The other classes in the project should not be exposed to this logic, because only `LibraryAPI` should hold instances of `PersistencyManager` and `HTTPClient`. Then, LibraryAPI will expose a simple API to access those services.
```swift
private let persistencyManager = PersistencyManager()
private let httpClient = HTTPClient()

func getAlbums() -> [Album] {
  return persistencyManager.getAlbums()    
}
  
func addAlbum(_ album: Album, at index: Int) {
  //the class first updates the data locally, and then if there’s an internet connection, it updates the remote server. 
  persistencyManager.addAlbum(album, at: index)
  if isOnline {
    httpClient.postRequest("/api/addAlbum", body: album.description)
  }  
}
  
func deleteAlbum(at index: Int) {
  persistencyManager.deleteAlbum(at: index)
  if isOnline {
    httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
  }   
}
```

## Decorator Pattern
**Intent**
Allows a user to add new functionality to an existing object without altering its structure.
**Implementation**
In Swift there are two very common implementations of this pattern: Extensions and Delegation. Adding extensions allows developers to add new functionality to existing classes, structures or enumeration types without having to subclass. Assuming that we'd need to reprsent the album information in a table view, an extension of `Album` struct has to be created in order to easily represent this information within a `UITableView`.
```swift
extension Album {
  var tableRepresentation: [AlbumData] {
    return [
      ("Artist", artist),
      ("Album", title),
      ("Genre", genre),
      ("Year", year)
    ]
  }
}
```
The other implementation of the Decorator design pattern, Delegation, is a mechanism in which one object acts on behalf of, or in coordination with, another object. In this case, `UITableView` has two delegate-type properties: data source and delegate. Data source is needed to know how many rows should be in a particular section, and delegate is needed to know what specifically to do when a row is selected. 
```swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  guard let albumData = currentAlbumData else {
    return 0
  }
  return albumData.count
  // returns the number of rows to display in the table view
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
  if let albumData = currentAlbumData {
    let row = indexPath.row
    cell.textLabel!.text = albumData[row].title
    cell.detailTextLabel!.text = albumData[row].value
  }
  return cell
  // creates and returns a cell with the title and its value.
}
```


## Adapter Pattern
**Intent**
Allows classes with incompatible interfaces to work together. It wraps itself around an object and exposes a standard interface to interact with that object.
**Implementation**
Apple uses protocols in order to achieve this result. In order to illustrate this pattern, a protocol named `HorizontalScrollerViewDataSource` has been defined, that performs two tasks: asks for the number of views to display inside the horizontal scroller and the view that should appear for a specific index and the `HorizontalScrollerDelegate`, which will let the horizontal scroller inform some other object that a view has been selected. Then, we implement the methods defined in the main `ViewController`.
```swift
extension ViewController: HorizontalScrollerViewDelegate {
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int) {
    // deselecting all albums
    let previousAlbumView = horizontalScrollerView.view(at: currentAlbumIndex) as! AlbumView
    previousAlbumView.highlightAlbum(false)
    // store the current selected album index
    currentAlbumIndex = index
    // highlight the album selected
    let albumView = horizontalScrollerView.view(at: currentAlbumIndex) as! AlbumView
    albumView.highlightAlbum(true)
    // display the data for that album
    showDataForAlbum(at: index)
  }
}
```

## MVC Pattern
**Intent**
Specifies that an application consist of a data model, presentation information, and control information. The pattern requires that each of these be separated into different objects according to their general role in the application and encourages clean separation of code based on role:
+ Model: The objects that hold the application data and define how to manipulate it. For example, the Model, here, is the `Album` struct.
+ View: The objects that are in charge of the visual representation of the Model and the controls the user can interact with; basically, all the UIView-derived objects, that being the `AlbumView.swift`.
+ Controller: The controller (here, the `ViewController`) is the mediator that coordinates all the work. It accesses the data from the model and displays it, listens to events and manipulates the data as necessary. 
The communication between View to Model through Controller occurs in the following way: the Model notifies the Controller of any data changes, and then, the Controller updates the data in the Views. The View can notify the Controller of actions the user performed and the Controller will either update the Model if necessary or retrieve any requested data.
**Implementation**
In order to make sure I implemented the MVC Pattern, I ensured that each class in my project is either a Controller, a Model or a View and that there is no class that combines the functionality of two roles in the same one.

## Observer Pattern
**Intent**
One object notifies other objects of any state changes. 
**Implementation**
Cocoa implements Observer Pattern using Notifications. Notifications are based on a subscribe-and-publish model that allows an object (the publisher) to send messages to other objects (subscribers). The publisher never needs to know anything about the subscribers. In iOS development, notifications are used, for example, when the keyboard is shown/hidden and the system sends a `UIKeyboardWillShow/UIKeyboardWillHide` notification. Or, when the app enters the background mode, the system sends a `UIApplicationDidEnterBackground` notification.
```swift
NotificationCenter.default.post(name: .BLDownloadImage, object: self, userInfo: ["imageView": coverImageView, "coverUrl" : coverUrl])
```
This line sends a notification through the NotificationCenter singleton. The notification info contains the `UIImageView` and the URL of the cover image to be downloaded. 
```swift
NotificationCenter.default.addObserver(self, selector: #selector(downloadImage(with:)), name: .BLDownloadImage, object: nil)
```
Now this is the other side of the equation: the observer. Every time an `AlbumView` posts a `BLDownloadImage` notification, since `LibraryAPI` has registered as an observer for the same notification, the system notifies `LibraryAPI`. Then `LibraryAPI` calls `downloadImage(with:)` in response.

## Memento Pattern
**Intent**
Restores state of an object to a previous state. In other words, it saves your stuff somewhere. Later on, this previous state can be restored without violating encapsulation; private data remains private.

**Implementation**
In order to implement the Memento Pattern, we are saving the index (this will happen when your app enters the background) and restoring it (this will happen when the app is launched, after the view of your view controller is loaded). After you restore the index, you update the table and scroller to reflect the updated selection. 
```swift

override func encodeRestorableState(with coder: NSCoder) {
  coder.encode(currentAlbumIndex, forKey: Constants.IndexRestorationKey)
  super.encodeRestorableState(with: coder)
}

override func decodeRestorableState(with coder: NSCoder) {
  super.decodeRestorableState(with: coder)
  currentAlbumIndex = coder.decodeInteger(forKey: Constants.IndexRestorationKey)
  showDataForAlbum(at: currentAlbumIndex)
  horizontalScrollerView.reload()
}
```
Another Apple's specialized implementations of the Memento pattern can be achieved through archiving and serialization. 
```swift
private var documents: URL {
  return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

private enum Filenames {
  static let Albums = "albums.json"
}

func saveAlbums() {
  let url = documents.appendingPathComponent(Filenames.Albums)
  let encoder = JSONEncoder()
  guard let encodedData = try? encoder.encode(albums) else {
    return
  }
  try? encodedData.write(to: url)
}
```
We are defining a URL where the file would be saved, a constant for the filename, then a method which writes the albums to the file. The other part of the process is decode back the data into a concrete object. Instead of "making" the albums, we'll load them from a file.
```swift
let savedURL = documents.appendingPathComponent(Filenames.Albums)
var data = try? Data(contentsOf: savedURL)
if data == nil, let bundleURL = Bundle.main.url(forResource: Filenames.Albums, withExtension: nil) {
  data = try? Data(contentsOf: bundleURL)
}

if let albumData = data,
  let decodedAlbums = try? JSONDecoder().decode([Album].self, from: albumData) {
  albums = decodedAlbums
  saveAlbums()
}
```


