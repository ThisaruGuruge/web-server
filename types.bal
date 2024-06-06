import ballerina/http;

type Error distinct error;
type InternalError distinct Error;
type NotFoundError distinct Error;
type BadRequestError distinct Error;

enum ImageExtension {
    JPG = "jpg",
    JPEG = "jpeg",
    PNG = "png",
    GIF = "gif",
    BMP = "bmp",
    WEBP = "webp",
    SVG = "svg",
    ICO = "ico"
}

const map<string> extensionToContentType = {
    jpg: "image/jpeg",
    jpeg: "image/jpeg",
    png: "image/png",
    gif: "image/gif",
    bmp: "image/bmp",
    webp: "image/webp",
    svg: "image/svg+xml",
    ico: "image/x-icon",
    css: "text/css",
    html: "text/html",
    php: "text/html",
    js: "application/javascript",
    'json: "application/json",
    txt: "text/plain",
    'xml: "application/xml",
    form: "application/x-www-form-urlencoded",
    multipart: "multipart/form-data"
};

public type Ok record {|
    *http:Ok;
    string|byte[] body;
    string mediaType = "text/html";
    record {|
        string Cache\-Control?;
        string Pragma?;
        string Expires?;
    |} headers = {};
|};

type Content record {|
    string|byte[] body;
    string mediaType = "text/html";
|};
