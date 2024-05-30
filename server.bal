import ballerina/http;
import ballerina/io;

configurable int port = 8080;

listener http:Listener httpListener = new (port);

service http:InterceptableService on httpListener {
    public function createInterceptors() returns http:Interceptor|http:Interceptor[] {
        return [new InternalErrorInterceptor(), new ResponseInterceptor()];
    }

    isolated function init() {
        http:InferredListenerConfiguration configs = httpListener.getConfig();
        string protocol = configs.secureSocket is http:ListenerSecureSocket ? "https" : "http";
        io:println(string `Server started on ${protocol}://${httpListener.getConfig().host}:${port}`);
    }

    resource function get .() returns string|InternalError {
        return getIndex();
    }

    resource function get favicon\.ico() returns http:Response|error {
        byte[] favicon = check getFavicon();
        http:Response response = new;
        response.setBinaryPayload(favicon, "image/x-icon");
        return response;
    }

    resource function get [string project]/favicon\.ico() returns http:Response|error {
        byte[] favicon = check getFavicon(project);
        http:Response response = new;
        response.setBinaryPayload(favicon, "image/x-icon");
        return response;
    }

    resource function get [string project]() returns string|Error {
        if !isValidProject(project) {
            return error NotFoundError("Project not found");
        }
        return readStringContent(project, "");
    }

    resource function get [string project]/[string... paths]() returns http:Response|Error {
        if !isValidProject(project) {
            return error NotFoundError("Project not found");
        }
        string path = check sanitizePath(paths);
        string extension = getFileExtension(path);
        http:Response response = new;
        if extension is ImageExtension {
            byte[] imageContent = check readImageContent(project, path);
            response.setBinaryPayload(imageContent, IMAGE);
        } else {
            string fileContent = check readStringContent(project, path);
            response.setTextPayload(fileContent, HTML);
        }
        return response;
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

service class ResponseInterceptor {
    *http:ResponseInterceptor;

    remote function interceptResponse(http:RequestContext ctx, http:Response res) returns http:NextService|error? {
        res.setHeader("Content-Type", "text/html");
        return ctx.next();
    }
}
