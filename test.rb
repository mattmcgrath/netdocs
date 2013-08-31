require 'savon'

class NDSession
  def initialize (username, password)
    # Get the WSDLs for the NetDocs SOAP API
    @directory = Savon.client(wsdl: "https://vault.netvoyage.com/ndApi/directory.aspx?WSDL")
    @storage = Savon.client(wsdl: "https://vault.netvoyage.com/ndApi/storage.aspx?WSDL")
    
    # Call Login() method of directory service
    @login = @directory.call(:login) do
      message username: username, password: password
    end
    
    @session_cookie = @login.http.headers["Set-Cookie"]
  end
  
  def set_session_cookie
    # Set before each request
    @directory.http.headers["Cookie"] = @session_cookie
    @storage.http.headers["Cookie"] = @session_cookie
  end
  private :set_session_cookie
  
  def search(criteria, attr_list)
    set_session_cookie
    @storage.request :envelope, :search, body: {
      criteria: criteria,
      attr_list: attr_list
    }
  end
end

m = NDSession.new("matt.mcgrath","ND4work")