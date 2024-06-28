# Simple Web Server in Ballerina

This is a simple web server written in Ballerina. It can be used to serve file-based web content like static web pages, images, etc.

## Configs

To serve the content via SSL, provide the configurations using a `Config.toml` file. The file should be placed in the project root directory.

```toml
port = 9090
certFile = "./path/to/server.crt"
keyFile = "./path/to/server.key"
```

Additionally, you can remove the `secureSocket` configuration in the HTTP service to remove SSL and test the server.

## How to run

1. Clone the repository.
    Use the following command to clone the repository:

    ```bash
    git clone https://github.com/ThisaruGuruge/web-server.git
    ```

2. Navigate to the project root directory.

    ```bash
    cd web-server
    ```

3. Run the Ballerina program.

    ```bash
    bal run .
    ```

4. Access the web server.

    Open a web browser and navigate to `http://localhost:9090/`.

## How to serve custom content

This server is designed to serve file-based web content, as websites. Each site should be treated as a separate project. Each project should be placed under a separate directory inside the `public` directory.

1. Add your content to the `public` directory, under a subdirectory.
2. Access the content using the following URL pattern:

    ```none
    http://localhost:9090/<subdirectory>/<filename>
    ```

When a specific file name is not provided under a subdirectory, the server will look for an `index.html` or `index.php` file in the subdirectory and serve it.
