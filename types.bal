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

enum ContentType {
    JSON = "application/json",
    HTML = "text/html",
    TEXT = "text/plain",
    XML = "application/xml",
    FORM = "application/x-www-form-urlencoded",
    MULTIPART = "multipart/form-data",
    IMAGE = "image/*",
    VIDEO = "video/*",
    AUDIO = "audio/*",
    ANY = "*/*"
}
