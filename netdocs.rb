require 'savon'

module NetDocs
  class Session
    attr_accessor :cookies, :directory, :storage
    
    def initialize(username, password)
	  	@directory = Directory.new
	  	@storage = Storage.new
	  	@cookies = self.directory.login(message: {username: username, password:password}).http.cookies
	  	@directory.cookies = @cookies
	  	@storage.cookies = @cookies
	  	self
		end
  end  
  
	class Directory
		extend Savon::Model
		attr_accessor :cookies
		client wsdl: "https://vault.netvoyage.com/ndApi/directory.aspx?WSDL",  ssl_verify_mode: :none
		operations :login
	end

	class Storage
		extend Savon::Model
		attr_accessor :cookies
		client wsdl: "https://vault.netvoyage.com/ndApi/storage.aspx?WSDL", ssl_verify_mode: :none
		operations :search

		def search(criteria)
			response = (super message: {criteria: criteria, attrList: "3"}, cookies: @cookies).hash
			docs = response[:envelope][:body][:search_response][:search_result][:storage_list]
			return docs
		end
	end

	class DirectoryObject
		attr_accessor :nd_guid, :name
	end

	class User
		attr_accessor :guid, :first_name, :last_name, :full_name, :email, :organization, :phone_number
	end
	
	class Group < DirectoryObject
	end

	class Cabinet < DirectoryObject
	end

	class Repository < DirectoryObject
	end

	class StorageObject
		attr_accessor :name, :access_list, :access_level, :parent, :content, :doc_num
	end

	class Document < StorageObject
		attr_accessor :fileExtension
		#document field is "999" for document number
		
		#Save base64 document data to a file
		def self.write
			File.open('shipping_label.gif', 'wb') do|f|
  				f.write(Base64.decode64(base_64_encoded_data))
			end
		end
	end

	class Folder < StorageObject
	end

	class Category < StorageObject
	end

	class Workspace < StorageObject
	end
end

#sesh = NetDocs::Session.new("matt.mcgrath","ND4work")
#results = sesh.storage.search("2080 - NFHS Network - Checklist")