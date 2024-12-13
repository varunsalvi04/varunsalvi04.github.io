import SwiftUI
import UIKit

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search here"
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}

struct searchView: View {
    @State private var searchText = ""
    @State private var options = [
        "Minneapolis", "Minnetonka", "Minneola", "Minnesota",
        "Miami", "Memphis", "Montgomery", "Mobile",
        "Madison", "Macon", "Mesa", "Modesto"
    ]
    
    
    var filteredOptions: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return options.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText)
            
            // Display autocomplete options
            if !filteredOptions.isEmpty {
                
                List(filteredOptions, id: \.self) { option in
                    Text(option)
                        .onTapGesture {
                            // Update search text with the selected option
                            searchText = option
                        }
                }
                .frame(height: 200) // Limit height of the dropdown
                .listStyle(PlainListStyle()) // Make the list style plain
                .zIndex(1)
                
                
            }
            
            //            Spacer()
        }
    }
}

struct searchView_Previews: PreviewProvider {
    static var previews: some View {
        searchView()
    }
}
