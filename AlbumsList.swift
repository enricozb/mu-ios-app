import SwiftUI

struct AlbumsList: View {
  let albums: [String: [Song]]

  init(albums: [String: [Song]]) {
    self.albums = albums
    UITableView.appearance().showsVerticalScrollIndicator = false
  }

  var body: some View {
    Text("albums")
  }
}
