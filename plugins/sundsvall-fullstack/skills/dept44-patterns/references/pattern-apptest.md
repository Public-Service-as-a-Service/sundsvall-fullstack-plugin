# AppTest / Integration Test Pattern Reference

Reference for dept44 end-to-end integration tests. Look at existing tests in `src/integration-test/` for exact style.

## AppTest Class

- Package: `src/integration-test/java/.../apptest/`
- Class name: `{Feature}IT`, extends `AbstractAppTest`
- `@WireMockAppTestSuite(files = "classpath:/{TestClassName}/", classes = Application.class)`
- `@Sql` for database setup/teardown before each test

## Fluent Test Builder

```java
// GET
setupCall()
    .withServicePath(path)
    .withHttpMethod(GET)
    .withExpectedResponseStatus(OK)
    .withExpectedResponseHeader(CONTENT_TYPE, List.of(APPLICATION_JSON_VALUE))
    .withExpectedResponse(RESPONSE_FILE)
    .sendRequestAndVerifyResponse();

// POST
setupCall()
    .withServicePath(path)
    .withHttpMethod(POST)
    .withRequest(REQUEST_FILE)
    .withExpectedResponseStatus(CREATED)
    .withExpectedResponseHeader(LOCATION, List.of("^/.*$"))
    .withExpectedResponse(RESPONSE_FILE)
    .sendRequestAndVerifyResponse();

// DELETE
setupCall()
    .withServicePath(path)
    .withHttpMethod(DELETE)
    .withExpectedResponseStatus(NO_CONTENT)
    .withExpectedResponseBodyIsNull()
    .sendRequestAndVerifyResponse();
```

- `sendRequestAndVerifyResponse()` — sends + verifies against expected response file
- `sendRequest()` — sends without verification (for multi-step tests)
- For update flows: GET before -> PUT -> GET after (verify state change)
- Can `@Autowired` repositories to assert database state directly

## Resource File Structure

```
src/integration-test/resources/
├── {TestClassName}/
│   └── __files/
│       ├── common/
│       │   └── responses/
│       │       └── api-gateway-token-response.json    # Shared OAuth token stub
│       └── {testMethodName}/                          # One folder per test method
│           ├── mappings/                              # WireMock stub mappings
│           │   ├── api-email-reader-getEmail.json
│           │   ├── api-gateway-token.json
│           │   └── ...
│           └── response/
│               └── response.json                      # Expected response body
├── db/scripts/
│   ├── truncate.sql
│   └── testdata-it.sql
└── application-junit.yml
```

## Conventions

- Test method names prefixed: `test01_`, `test02_`, etc. for ordering
- `REQUEST_FILE` and `RESPONSE_FILE` constants point to `request.json` / `response.json`
- PATH is typically a `UnaryOperator<String>` or constant with path template
- WireMock mappings in `{testMethodName}/mappings/` directory
- Common stubs (OAuth token) shared in `common/` directory
