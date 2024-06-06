import ballerina/http;
import ballerina/io;

configurable int port = 8000;
configurable string certFile = ?;
configurable string keyFile = ?;

listener http:Listener httpListener = new (port,
    secureSocket = {
        key: {
            certFile,
            keyFile
        }
    }
);

service http:InterceptableService on httpListener {
    public function createInterceptors() returns http:Interceptor|http:Interceptor[] {
        return [new InternalErrorInterceptor()];
    }

    isolated function init() {
        http:InferredListenerConfiguration configs = httpListener.getConfig();
        string protocol = configs.secureSocket is http:ListenerSecureSocket ? "https" : "http";
        io:println(string `Server started on ${protocol}://${httpListener.getConfig().host}:${port}`);
    }

    resource function get .() returns Ok|InternalError {
        string body = check getIndex();
        return {
            body
        };
    }

    resource function get favicon\.ico() returns Ok|error {
        byte[] body = check getFavicon();
        return {
            body,
            mediaType: extensionToContentType.get("ico")
        };
    }

    resource function get [string project]() returns Ok|Error {
        if !isValidProject(project) {
            return error NotFoundError("Project not found");
        }
        Content content = check getFileContent(project, "");
        return {
            ...content
        };
    }

    resource function get [string project]/[string... paths]() returns Ok|Error {
        if !isValidProject(project) {
            return error NotFoundError("Project not found");
        }
        string path = check sanitizePath(paths);
        Content content = check getFileContent(project, path);
        return {
            ...content
        };
    }
}

service class InternalErrorInterceptor {
    *http:ResponseErrorInterceptor;

    remote function interceptResponseError(error err) returns http:Ok|http:BadRequest|http:NotFound|http:InternalServerError {
        if err is InternalError {
            return <http:InternalServerError>{
                body: "Internal server error"
            };
        } else if err is NotFoundError {
            string|Error response = get404Response();
            if response is string {
                return <http:Ok>{
                    headers: {
                        "Content-Type": "text/html"
                    },
                    body: response
                };
            } else {
                return <http:NotFound>{
                    body: "Not found"
                };
            }
        } else {
            return <http:BadRequest>{
                body: "Bad request"
            };
        }
    }
}
