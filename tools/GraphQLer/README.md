# GraphQLer

## Authentication Handling

Authentication is handled automatically via the `auth.sh` script in the case study directory:

- **JWT Token (Authorization Header):**
  - If `auth.sh` outputs a line starting with `Authorization: Bearer ...`, the runner will extract the token and pass it to GraphQLer using the `--auth` flag.
  - Example output from `auth.sh`:
    ```
    Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
    ```
  - This will be used as:
    ```
    --auth "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    ```

- **Custom Authentication (e.g., Cookie):**
  - If `auth.sh` outputs a custom header (like `Cookie: ...`), the runner will inject this header into the `[CUSTOM_HEADERS]` section of the GraphQLer TOML config file.
  - This allows GraphQLer to send custom headers with every request.
    ```
    Cookie: sessionId=abc123
    ```
  - This will be used as:
    ```
    Cookie = sessionId=abc123
    ```

## Customizing GraphQLer Configuration

You can customise GraphQLer's advanced features by providing a TOML configuration file.

- **Custom Config:**
  - You can set the `GRAPHQLER_CONFIG` environment variable to point to your own TOML config file. (See an example in `utils/GraphQLer-config.toml`).
  - The runner will copy the contents of this file and pass it to GraphQLer using the `--config` flag.

- **How to Use:**
  1. Edit or create your custom TOML config (see [GraphQLer examples/config.toml](https://github.com/omar2535/GraphQLer/blob/main/examples/config.toml) for options).
  2. Set the environment variable before running:
     ```bash
     export GRAPHQLER_CONFIG=./utils/my-custom-config.toml
     ```
  3. Run the experiment as usual.

## Notes

- If both an auth header and a config file are provided, both will be used.
- If only a config file is provided, it will be passed with `--config`.
- If only an auth header is provided, it will be passed with `--auth`.