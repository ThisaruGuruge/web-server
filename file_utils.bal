import ballerina/file;
import ballerina/io;
import ballerina/log;

const BASE_PATH = "./public";

const string[] PATH_APPENDS = ["", ".html", ".php", "/index.html", "/index.php"];

isolated function isValidProject(string project) returns boolean {
    string projectPath = string `${BASE_PATH}/${project}`;
    boolean|error isProjectExists = file:test(projectPath, file:IS_DIR);
    if isProjectExists is error || !isProjectExists {
        return false;
    }
    return true;
}

function getFileContent(string project, string path) returns Content|Error {
    foreach string suffix in PATH_APPENDS {
        string filePath = string `${BASE_PATH}/${project}/${path}${suffix}`;
        if check isValidFile(filePath) {
            return readFileContent(filePath);
        }
    }
    log:printError(string `File not found: ${path}`, error NotFoundError(string `File not found: ${path}`));
    return error NotFoundError("Requested file not found");
}

isolated function readFileContent(string path) returns Content|Error {
    string extension = getFileExtension(path);
    string mediaType = extensionToContentType.hasKey(extension) ? extensionToContentType.get(extension) : "text/plain";
    if extension is ImageExtension {
        byte[] body = check readImageContent(path);
        return {
            body,
            mediaType
        };
    }
    string body = check readStringContentNew(path);
    return {
        body,
        mediaType
    };
}

isolated function readStringContentNew(string path) returns string|Error {
    string|error fileContent = io:fileReadString(path);
    if fileContent is error {
        log:printError(string `Failed to read the file "${path}"`, fileContent);
        return error InternalError(string `Internal server error`);
    }
    return fileContent;
}

isolated function readImageContent(string path) returns byte[]|InternalError {
    byte[]|error fileContent = io:fileReadBytes(path);
    if fileContent is error {
        log:printError(string `Failed to read the file "${path}"`, fileContent);
        return error InternalError(string `Internal server error`);
    }
    return fileContent;
}

isolated function sanitizePath(string[] paths) returns string|Error {
    string[] sanitizedSegments = [];
    foreach string pathSegment in paths {
        if pathSegment == "" {
            continue;
        } else if re `^[a-zA-Z0-9_.\\\-/]+$`.isFullMatch(pathSegment) {
            sanitizedSegments.push(pathSegment);
        } else {
            io:println(string `Invalid path segment: ${pathSegment}`);
        }
    }
    string|error joinedPath = file:joinPath(...sanitizedSegments);
    if joinedPath is error {
        log:printError("Failed to construct the path", joinedPath);
        return error InternalError("Invalid resource path");
    }
    return joinedPath;
}

isolated function getFavicon(string path = "./resources") returns byte[]|error {
    string faviconPath = string `${path}/favicon.ico`;
    return io:fileReadBytes(faviconPath);
}

isolated function isValidFile(string path) returns boolean|InternalError {
    boolean|error isExists = file:test(path, file:EXISTS);
    if isExists is error {
        InternalError err = error InternalError(string `Error checking the path "${path}": ${isExists.message()}`);
        log:printError("Error checking the path", err);
        return err;
    }
    if !isExists {
        return false;
    }
    boolean|error isDir = file:test(path, file:IS_DIR);
    if isDir is error {
        InternalError err = error InternalError(string `Error checking the path "${path}": ${isDir.message()}`);
        log:printError("Error checking the path", err);
        return err;
    }
    return !isDir;
}

isolated function getIndex() returns string|InternalError {
    string|error indexFile = io:fileReadString("./resources/index.html");
    if indexFile is error {
        InternalError err = error InternalError(string `Failed to read the index file: ${indexFile.message()}`);
        return err;
    }
    readonly & file:MetaData[]|error files = file:readDir(BASE_PATH);
    if files is error {
        InternalError err = error InternalError(string `Failed to read the directory: ${files.message()}`);
        log:printError("Failed to read the directory", err);
        return err;
    }
    string[] projects = [];
    foreach readonly & file:MetaData file in files {
        if file.dir {
            string|error directoryName = file:basename(file.absPath);
            if directoryName is error {
                InternalError err = error InternalError(string `Failed to get the directory name: ${directoryName.message()}`);
                log:printError("Failed to get the directory name", err);
                continue;
            }
            projects.push(string `            <li><a href="${directoryName}">${directoryName}</li>`);
        }
    }
    string rows = "\n".'join(...projects);
    string result = re `@@list@@`.replace(indexFile, rows);
    return result;
}

isolated function getFileExtension(string fileName) returns string {
    string[] pathSegments = re `\.`.split(fileName);
    int pathSegmentsLength = pathSegments.length();
    if pathSegmentsLength == 1 {
        return "";
    }
    return pathSegments[pathSegmentsLength - 1];
}

isolated function get404Response() returns string|InternalError {
    string|error errorFile = io:fileReadString("./resources/404.html");
    if errorFile is error {
        InternalError err = error InternalError(string `Failed to read the 404 file: ${errorFile.message()}`);
        log:printError("Failed to read the 404 file", err);
        return err;
    }
    return errorFile;
}
