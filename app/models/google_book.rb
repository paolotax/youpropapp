class GoogleBook

  API_KEY = "AIzaSyB1ICqFSnVr7ZjlcgdVRMTkAnbC35YwS90"
  
  #See google places documentation at https://developers.google.com/places/documentation/ to obtain a key

  attr_accessor :title, :authors, :publisher, :isbn, :image

  def self.initWithJSON(json)
    book = GoogleBook.new
    book.title = json[:volumeInfo][:title]
    book.authors = json[:volumeInfo][:authors]
    book.publisher = json[:volumeInfo][:publisher]
    if json[:volumeInfo][:imageLinks]
      book.image = json[:volumeInfo][:imageLinks][:thumbnail]
    end
    identifiers = json[:volumeInfo][:industryIdentifiers]
    ean13 = identifiers.select {|i| i[:type] == "ISBN_13"}
    unless ean13.empty?
      book.isbn = ean13[0][:identifier]
    else
      book.isbn = ""
    end
    
    book
  end

  def self.search(ean)

    url = NSURL.URLWithString "https://www.googleapis.com/books/v1/volumes?q=isbn=#{ean}"
    if (url) 
      task = App.delegate.url_session.dataTaskWithURL(url,
        completionHandler: 
          lambda do |data, response, error|
            if error
              NSLog("ERROR: %@", error)
            else
              httpResponse = response;
              if (httpResponse.statusCode == 200)
                
                jsonError = Pointer.new(:object)
                booksJSON = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingAllowFragments, error:jsonError)

                if booksJSON[:totalItems] >= 1
                  book = GoogleBook.initWithJSON(booksJSON[:items][0])
                  
                  NSLog("200 #{booksJSON[:items][0]} -#{book.isbn}-#{ean}")
                  
                  if book.isbn != ean
                    book.title = ""
                    book.authors = []
                    book.publisher = ""
                    book.image = nil
                    book.isbn = ean
                  end
                  
                else

                  book = GoogleBook.new
                  book.isbn = ean
                  book.authors = []
                end
                
                "didFindBook".post_notification(self, book: book)

                # Dispatch::Queue.main.async do
                #   "didFindBook".post_notification(self, book: book)
                # end

              else

                NSLog("Couldn't load image at URL: %@", url)
                NSLog("HTTP %d", httpResponse.statusCode)

              end
            end
          end
        )

      task.resume
    end
  end
end