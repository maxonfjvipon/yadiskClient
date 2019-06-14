//
//  Model.swift
//  yd
//
//  Created by Максим Трунников on 22/04/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import Foundation
import WebKit

protocol loadResourceProtocol {
    func loadResource()
}

class YA_DISK_API {
    let authString = "https://oauth.yandex.ru/authorize?response_type=token&client_id="
    var token = ""
    let CLIENT_ID = "63322a1cfb6e47049cd8cce10fa07839"
    let RESOURCEURL = "https://cloud-api.yandex.net/v1/disk/resources?path="
    let COPYFROMRESOURCEURL = "https://cloud-api.yandex.net/v1/disk/resources/copy?from="
    let MOVEFROMRESOURCEURL = "https://cloud-api.yandex.net/v1/disk/resources/move?from="
    let DOWNLOADRESOURCEURL = "https://cloud-api.yandex.net/v1/disk/resources/download?path="
    let UPLOADFROMURLURL = "https://cloud-api.yandex.net/v1/disk/resources/upload?path="
    let UPLOADRESOURCEURL = "https://cloud-api.yandex.net/v1/disk/resources/upload?path="
    let USERDISKURL = "https://cloud-api.yandex.net/v1/disk/"
    let TRASHURL = "https://cloud-api.yandex.net/v1/disk/trash/resources?path="
    let PUBLICRESOURCELISTURL = "https://cloud-api.yandex.net:443/v1/disk/resources/public?limit=100"
    let PUBLISHRESOURCEURL = "https://cloud-api.yandex.net/v1/disk/resources/publish?path="
    let UNPUBLISHRESOURCEURL = "https://cloud-api.yandex.net/v1/disk/resources/unpublish?path="
    let PUBLICRESOURCEURL = "https://cloud-api.yandex.net/v1/disk/public/resources?public_key="
    let SAVEPUBLICRESOURCETODISKURL = "https://cloud-api.yandex.net/v1/disk/resources/download?public_key="
    let GETSAVELINKURL = "https://cloud-api.yandex.net/v1/disk/public/resources/download?public_key="
    let RESTORERESOURCEURL = "https://cloud-api.yandex.net/v1/disk/trash/resources/restore?path="
    let PATH = "&path="
    let URL = "&url="
    let LIMIT = "&limit=100"
    let NAME = "&name="
    let OAuth = "OAuth "
    let Authorization = "Authorization"
}

let yaDiskAPI = YA_DISK_API()

class Resource: Decodable {
    var antivirus_status : String?
    var resource_id : String?
    var share: ShareInfo?
    var file: String?
    var size: Int?
    var photoslice_time: String?
    var _embedded: ResourceList?
    var exif: Exif?
    var custom_properties: String?
    var media_type: String?
    var sha256: String?
    var type: String
    var mime_type: String?
    var revision: Int?
    var public_url : String?
    var path: String?
    var md5: String?
    var public_key: String?
    var preview : String?
    var name: String?
    var created: String?
    var modified: String?
    var comment_ids: CommentIds?
    
    init(antivirus_status: String?, resource_id: String?, share: ShareInfo?, file: String?, size: Int?, photoslice_time: String?, _embedded: ResourceList?, exif: Exif?, custom_properties: String?, media_type: String?, sha256: String?, type: String, mime_type: String?, revision: Int?, public_url: String?, path: String?, md5: String?, public_key: String?, preview: String?, name: String?, created: String?, modified: String?, comment_ids: CommentIds?) {
        self.antivirus_status = antivirus_status
        self.resource_id = resource_id
        self.share = share
        self.file = file
        self.size = size
        self.photoslice_time = photoslice_time
        self._embedded = _embedded
        self.exif = exif
        self.custom_properties = custom_properties
        self.media_type = media_type
        self.sha256 = sha256
        self.type = type
        self.mime_type = mime_type
        self.revision = revision
        self.public_url = public_url
        self.path = path
        self.md5 = md5
        self.public_key = public_key
        self.preview = preview
        self.name = name
        self.created = created
        self.modified = modified
        self.comment_ids = comment_ids
    }
}

class PublicResource: Decodable {
    var antivirus_status : String?
    var views_count: Int?
    var resource_id : String?
    var share: ShareInfo?
    var file: String?
    var owner: UserPublicInformation?
    var size: Int?
    var photoslice_time: String?
    var _embedded: ResourceList?
    var exif: Exif?
    var media_type: String?
    var sha256: String?
    var type: String
    var mime_type: String?
    var revision: Int?
    var public_url : String
    var path: String?
    var md5: String?
    var public_key: String
    var preview : String?
    var name: String?
    var created: String?
    var modified: String?
    var comment_ids: CommentIds?
    
    init(antivirus_status: String?, views_count: Int?,  resource_id: String?, share: ShareInfo?, file: String?, owner: UserPublicInformation?, size: Int?, photoslice_time: String?, _embedded: ResourceList?, exif: Exif?, custom_properties: String?, media_type: String?, sha256: String?, type: String, mime_type: String?, revision: Int?, public_url: String, path: String?, md5: String?, public_key: String, preview: String?, name: String?, created: String?, modified: String?, comment_ids: CommentIds?) {
        self.antivirus_status = antivirus_status
        self.views_count = views_count
        self.resource_id = resource_id
        self.share = share
        self.file = file
        self.owner = owner
        self.size = size
        self.photoslice_time = photoslice_time
        self._embedded = _embedded
        self.exif = exif
        self.media_type = media_type
        self.sha256 = sha256
        self.type = type
        self.mime_type = mime_type
        self.revision = revision
        self.public_url = public_url
        self.path = path
        self.md5 = md5
        self.public_key = public_key
        self.preview = preview
        self.name = name
        self.created = created
        self.modified = modified
        self.comment_ids = comment_ids
    }
}

class TrashResource: Decodable {
    var antivirus_status : String?
    var views_count: Int?
    var resource_id : String?
    var share: ShareInfo?
    var file: String?
    var size: Int?
    var photoslice_time: String?
    var _embedded: TrashResourceList?
    var exif: Exif?
    var media_type: String?
    var sha256: String?
    var type: String
    var mime_type: String?
    var revision: Int?
    var deleted: String?
    var public_url : String?
    var path: String?
    var md5: String?
    var public_key: String?
    var preview : String?
    var name: String?
    var created: String?
    var modified: String?
    var comment_ids: CommentIds?
    
    init(antivirus_status: String?, views_count: Int?,  resource_id: String?, share: ShareInfo?, file: String?, owner: UserPublicInformation?, size: Int?, photoslice_time: String?, _embedded: TrashResourceList?, exif: Exif?, custom_properties: String?, media_type: String?, sha256: String?, type: String, mime_type: String?, revision: Int?, deleted: String?, public_url: String, path: String?, md5: String?, public_key: String, preview: String?, name: String?, created: String?, modified: String?, comment_ids: CommentIds?) {
        self.antivirus_status = antivirus_status
        self.views_count = views_count
        self.resource_id = resource_id
        self.share = share
        self.file = file
        self.size = size
        self.photoslice_time = photoslice_time
        self._embedded = _embedded
        self.exif = exif
        self.media_type = media_type
        self.sha256 = sha256
        self.type = type
        self.mime_type = mime_type
        self.revision = revision
        self.deleted = deleted
        self.public_url = public_url
        self.path = path
        self.md5 = md5
        self.public_key = public_key
        self.preview = preview
        self.name = name
        self.created = created
        self.modified = modified
        self.comment_ids = comment_ids
    }
}

class ShareInfo: Decodable {
    var is_root: Bool?
    var is_owned : Bool?
    var rights : String?
    
    init(is_root: Bool?, is_owned: Bool?, rights: String?) {
        self.is_root = is_root
        self.is_owned = is_owned
        self.rights = rights
    }
}

class TrashResourceList: Decodable {
    var sort: String?
    var items: [TrashResource]?
    var limit: Int?
    var offset: Int?
    var path: String?
    var total : Int?
    
    init(sort: String?, items: [TrashResource]?, limit: Int?, offset: Int?, path: String?, total : Int?) {
        self.sort = sort
        self.items = items
        self.limit = limit
        self.offset = offset
        self.path = path
        self.total = total
    }
}

class ResourceList: Decodable {
    var sort: String?
    var items: [Resource]?
    var limit: Int?
    var offset: Int?
    var path: String?
    var total : Int?
    
    init(sort: String?, items: [Resource]?, limit: Int?, offset: Int?, path: String?, total : Int?) {
        self.sort = sort
        self.items = items
        self.limit = limit
        self.offset = offset
        self.path = path
        self.total = total
    }
}
class Exif: Decodable {
    var date_time: String?
    
    init(date_time: String?) {
        self.date_time = date_time
    }
}

class CommentIds: Decodable {
    var private_resource: String?
    var public_resource: String?
    
    init(private_resource: String?, public_resource: String?) {
        self.private_resource = private_resource
        self.public_resource = public_resource
    }
}

class Link: Decodable {
    var href: String
    var method: String
    var templated: Bool?
    
    init(href: String, method: String, templated: Bool?) {
        self.href = href
        self.method = method
        self.templated = templated
    }
    
}

class ResourceUploadLink: Decodable {
    var operation_id: String
    var href: String
    var method: String
    var templated: Bool?
    
    init (operation_id: String, href: String, method: String, templated: Bool) {
        self.operation_id = operation_id
        self.href = href
        self.method = method
        self.templated = templated
    }
}

class Disk : Decodable {
    var max_file_size: Int?
    var unlimited_autoupload_enabled: Bool?
    var total_space: Int?
    var trash_size: Int?
    var is_paid: Bool?
    var used_space: Int?
    var system_folders: SystemFolders?
    var user: User?
    var revision: Int?
    
    init(max_file_size: Int?, unlimited_autoupload_enabled: Bool?, total_space: Int?, trash_size: Int?, is_paid: Bool?, used_space: Int?, system_folders: SystemFolders?, user: User?, revision: Int?) {
        self.max_file_size = max_file_size
        self.unlimited_autoupload_enabled = unlimited_autoupload_enabled
        self.total_space = total_space
        self.trash_size = trash_size
        self.is_paid = is_paid
        self.used_space = used_space
        self.system_folders = system_folders
        self.user = user
        self.revision = revision
    }
    
}
class SystemFolders: Decodable {
    var odnoklassniki: String?
    var google: String?
    var instagram: String?
    var vkontakte: String?
    var mailru: String?
    var downloads: String?
    var applications: String?
    var facebook: String?
    var social: String?
    var screenshots: String?
    var photostream: String?
    
    init(odnoklassniki: String, google: String?, instagram: String?, vkontakte: String?, mailru: String?, downloads: String?, applications: String?, facebook: String?, social: String?, screenshots: String?, photostream: String?) {
        self.odnoklassniki = odnoklassniki
        self.google = google
        self.instagram = instagram
        self.vkontakte = vkontakte
        self.mailru = mailru
        self.downloads = downloads
        self.applications = applications
        self.facebook = facebook
        self.social = social
        self.screenshots = screenshots
        self.photostream = photostream
    }
}

class User: Decodable {
    var country: String?
    var login: String?
    var display_name: String?
    var uid: String
    
    init(country: String?, login: String?, display_name: String?, uid: String) {
        self.country = country
        self.login = login
        self.display_name = display_name
        self.uid = uid
    }
}

class UserPublicInformation: Decodable {
    var login: String?
    var display_name: String?
    var uid: String?
    
    init(login: String?, display_name: String?, uid: String?) {
        self.login = login
        self.display_name = display_name
        self.uid = uid
    }
}

class PublicResourcesList: Decodable {
    var items: [Resource]
    var type: String?
    var limit: Int?
    var offset: Int?
    
    init(items: [Resource], type: String?, limit: Int?, offset: Int?) {
        self.items = items
        self.type = type
        self.limit = limit
        self.offset = offset
    }
}

let rootPath = "disk:/"

func simpleRequest(url: String) -> URLRequest {
    let _url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: _url!)!)
    request.httpMethod = "GET"
    return request
}

func userDiskRequest() -> URLRequest {
    let url = yaDiskAPI.USERDISKURL
    var request = URLRequest.init(url: URL.init(string: url)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "GET"
    return request
}

func getResourcesRequest(path: String) -> URLRequest {
    let url = yaDiskAPI.RESOURCEURL + path
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: encodedURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "GET"
    return request
}

func createFolderRequest(path: String) -> URLRequest {
    let url = yaDiskAPI.RESOURCEURL + path
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: encodedURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "PUT"
    return request
}

func getResourceRequest(url: String) -> URLRequest {
    var request = URLRequest.init(url: URL.init(string: url)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "GET"
    return request
}

func deleteResourceRequest(path: String) -> URLRequest {
    let url = yaDiskAPI.RESOURCEURL + path
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: encodedURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "DELETE"
    return request
}

func copyResourceRequest(from: String, to: String) -> URLRequest {
    let url = yaDiskAPI.COPYFROMRESOURCEURL + from + yaDiskAPI.PATH + to
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: encodedURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "POST"
    return request
}

func moveResourceRequest(from: String, to: String) -> URLRequest {
    let url = yaDiskAPI.MOVEFROMRESOURCEURL + from + yaDiskAPI.PATH + to
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: encodedURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "POST"
    return request
}

func downloadURLRequest(path: String) -> URLRequest {
    let url = yaDiskAPI.DOWNLOADRESOURCEURL + path
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: encodedURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "GET"
    return request
}

func uploadURLRequest(path: String) -> URLRequest {
    let url = yaDiskAPI.UPLOADRESOURCEURL + path/* + yandexIDS.UPLOADOWERWRITE*/
    let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: encodedURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "GET"
    return request
}

func uploadResourceRequest(path: String) -> URLRequest {
    let url = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: url!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "PUT"
    return request
}

func emptyTrashRequest(path: String) -> URLRequest {
    let url = yaDiskAPI.TRASHURL + path
    let eURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: eURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "DELETE"
    return request
}

func publicResourceListRequest() -> URLRequest {
    let url = yaDiskAPI.PUBLICRESOURCELISTURL
    var request = URLRequest.init(url: URL.init(string: url)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "GET"
    return request
}

func publicResourceRequest(publicUrl: String) -> URLRequest {
    let url = yaDiskAPI.PUBLICRESOURCEURL + publicUrl
    let eURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: eURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "GET"
    return request
}

func publishResourceRequest(path: String) -> URLRequest {
    let url = yaDiskAPI.PUBLISHRESOURCEURL + path
    let eURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: eURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "PUT"
    return request
}

func unpublishResourceRequest(path: String) -> URLRequest {
    let url = yaDiskAPI.UNPUBLISHRESOURCEURL + path
    let eURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: eURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "PUT"
    return request
}

func savePublicResourceToDiskRequest(publicUrl: String) -> URLRequest {
    let url = yaDiskAPI.SAVEPUBLICRESOURCETODISKURL + publicUrl
    let eURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: eURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "POST"
    return request
}

func getSaveResourceLinkRequest(publicUrl: String, path: String) -> URLRequest {
    let url = yaDiskAPI.GETSAVELINKURL + publicUrl + yaDiskAPI.PATH + path
    let eURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: eURL!)!)
    request.httpMethod = "GET"
    return request
}

func uploadFromUrlRequest(url: String, path: String) -> URLRequest {
    let _url = yaDiskAPI.UPLOADFROMURLURL + path + yaDiskAPI.URL + url
    print(_url)
    let eURL = _url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: eURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "POST"
    return request
}

func trashResourceRequest(path: String) -> URLRequest {
    let url = yaDiskAPI.TRASHURL + path + yaDiskAPI.LIMIT
    let eURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: eURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "GET"
    return request
}

func restoreResourceRequest(path: String, name: String) -> URLRequest {
    let url = yaDiskAPI.RESTORERESOURCEURL + path + yaDiskAPI.NAME + name
    let eURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    var request = URLRequest.init(url: URL.init(string: eURL!)!)
    request.addValue(yaDiskAPI.OAuth + yaDiskAPI.token, forHTTPHeaderField: yaDiskAPI.Authorization)
    request.httpMethod = "PUT"
    return request
}
