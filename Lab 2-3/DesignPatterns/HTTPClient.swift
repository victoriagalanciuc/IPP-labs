
import UIKit

class HTTPClient {
	
	func getRequest(_ url: String) -> (AnyObject) {
		return Data() as (AnyObject)
	}
	
	func postRequest(_ url: String, body: String) -> (AnyObject){
		return Data() as (AnyObject)
	}
	
	func downloadImage(_ url: String) -> (UIImage) {
		let aUrl = URL(string: url)
		let data = try? Data(contentsOf: aUrl!)
		let image = UIImage(data: data!)
		return image!
	}
	
}
