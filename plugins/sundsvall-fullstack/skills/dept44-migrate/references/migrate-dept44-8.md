# dept44 8.0.0 Migration Guide

Migrate this service from dept44 7.x to 8.0.x (currently 8.0.2). dept44 8.0.x is built on Spring Boot 4, so also consult the Spring Boot 4.0 migration guide at https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide for any additional breaking changes (package relocations, removed deprecations, etc.).

Apply all applicable changes below. Check existing code for old patterns and update them.

## pom.xml
- Add explicit `org.springframework.boot:spring-boot-starter-flyway` dependency (no longer transitive)
- `org.testcontainers:junit-jupiter` -> `org.testcontainers:testcontainers-junit-jupiter` (artifact ID renamed)
- **Services without a database:** `dept44-starter-test` transitively pulls in `spring-boot-starter-data-jpa-test`, which brings JPA/Hibernate/JDBC/HikariCP onto the test classpath. In Spring Boot 4, this triggers `DataSourceAutoConfiguration` and fails with "Failed to determine a suitable driver class". Fix by excluding it and adding back `spring-data-commons` (needed by Feign's `PageableSpringQueryMapEncoder`):

```xml
<dependency>
    <groupId>se.sundsvall.dept44</groupId>
    <artifactId>dept44-starter-test</artifactId>
    <scope>test</scope>
    <exclusions>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa-test</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>org.springframework.data</groupId>
    <artifactId>spring-data-commons</artifactId>
    <scope>test</scope>
</dependency>
```

## Zalando Problem -> dept44 Problem

Bulk import rename (run from project root):

```bash
find src -name '*.java' -exec sed -i '' 's/org\.zalando\.problem/se.sundsvall.dept44.problem/g' {} +
```

Then handle `Status` separately — it moves to a different package:

```bash
find src -name '*.java' -exec sed -i '' 's/import se\.sundsvall\.dept44\.problem\.Status/import org.springframework.http.HttpStatus/g' {} +
find src -name '*.java' -exec sed -i '' 's/import static se\.sundsvall\.dept44\.problem\.Status\./import static org.springframework.http.HttpStatus./g' {} +
```

Manual fixes needed after sed:
- `Violation` is now a record: `getField()` -> `field()`, `getMessage()` -> `message()`

## Jackson 2 -> 3

**Only `core`, `databind`, and `dataformat` moved to Jackson 3.** Annotations and datatype modules stay as Jackson 2.

Selective import rename (run from project root):

```bash
find src -name '*.java' -exec sed -i '' 's/com\.fasterxml\.jackson\.core/tools.jackson.core/g' {} +
find src -name '*.java' -exec sed -i '' 's/com\.fasterxml\.jackson\.databind/tools.jackson.databind/g' {} +
find src -name '*.java' -exec sed -i '' 's/com\.fasterxml\.jackson\.dataformat/tools.jackson.dataformat/g' {} +
```

Do NOT rename `com.fasterxml.jackson.annotation` or `com.fasterxml.jackson.datatype` — these stay as Jackson 2.

Manual fixes needed after sed:
- `JsonProcessingException` no longer exists in `tools.jackson.core` — replace with `JacksonException` (which is unchecked / extends `RuntimeException`)
- Remove try-catch around `ObjectMapper.writeValueAsString()` / `readTree()` and remove `throws JsonProcessingException` declarations
- `JavaTimeModule` is no longer needed — Jackson 3's `ObjectMapper` handles Java time types natively. Remove `.registerModule(new JavaTimeModule())` calls and the import.
- `AbstractThrowableProblem` -> `ThrowableProblem`
- Remove `example` from `@Schema` on `JsonNode` fields
- Use Context7 or WebSearch for any Jackson 3 API changes not listed here — do NOT inspect JARs manually

## Cache
- Move `@EnableCaching` from `Application.java` to a `@Configuration` class
- `o.s.boot.autoconfigure.cache.CacheManagerCustomizer` -> `o.s.boot.cache.autoconfigure.CacheManagerCustomizer`

## FeignException handling
- `e.contentUTF8()` replaces `e.getDetail()`

## Tests
- `@Captor` requires `@ExtendWith(MockitoExtension.class)` on `@SpringBootTest` classes — Spring Boot 4 no longer processes Mockito annotations automatically. Add the extension to any test class using `@Captor` fields.
- Add `@AutoConfigureWebTestClient` (`o.s.boot.webtestclient.autoconfigure`) on all `@SpringBootTest` + `WebTestClient` classes
- `TestRestTemplate`: add `@AutoConfigureTestRestTemplate` (`o.s.boot.resttestclient.autoconfigure`), import `TestRestTemplate` from `o.s.boot.resttestclient` (was `o.s.boot.test.web.client`)
- `@DataJpaTest`: `o.s.boot.test.autoconfigure.orm.jpa` -> `o.s.boot.data.jpa.test.autoconfigure`
- `@AutoConfigureTestDatabase`: `o.s.boot.test.autoconfigure.jdbc` -> `o.s.boot.jdbc.test.autoconfigure`
- `FeignException` constructor now requires explicit `Request`:

```java
var request = Request.create(Request.HttpMethod.POST, "url", Map.of(), null, new RequestTemplate());
new FeignException.BadRequest("msg", request, "body".getBytes(), null);
```

## Generated OpenAPI sources
- Generated models (`generated.se.sundsvall.*`) use Jackson annotations and may need regeneration
- Check if the `openapi-generator-maven-plugin` version in pom.xml needs updating for Jackson 3 / Spring Boot 4 compatibility
- Run `mvn generate-sources` to regenerate, then verify the generated code compiles with the new Jackson `tools.jackson` packages

## WireMock mapping files (integration tests)

WireMock upgraded from 2.x to 3.x. Mapping JSON files in `src/integration-test/resources/` may need fixes:

- **Remove `"persistent": true`** from all mapping files. In WireMock 3.x, persistent stubs go through `JsonFileMappingsSource.remove()` when dept44's `resolveBodyFileNames` tries to inline `bodyFileName` content. The file source doesn't know about stubs loaded via `loadMappingsUsing`, so its `fileMetadata` map returns null → NPE. Removing `persistent` makes `shouldBePersisted()` return false, skipping the file source entirely. Also remove `"insertionIndex"` (WireMock recording artifact, not needed).
- **Remove duplicate `"id"` / `"uuid"` fields.** WireMock 3.x rejects stubs with duplicate UUIDs (`InvalidInputException: Duplicate stub mapping ID`). Old WireMock recordings often share a single UUID across all stubs. Remove the fields entirely — WireMock auto-generates unique IDs.
- **Fix corrupt XML escapes in `equalToXml` stubs.** WireMock 3.x is stricter about XML matching. Check for `\\\"` sequences (double-escaped backslash-quote) that should be `\"`. Common in `xmlns:xsi` attributes.
- **Update SOAP element order in `equalToXml` stubs.** JAXB serialization order may change with the new Java/Spring Boot version. Check `@XmlType(propOrder = ...)` in generated JAXB classes and update `equalToXml` stubs to match the new element order.
- **Update constraint violation `type` in response files.** The constraint violation type changed from `https://zalando.github.io/problem/constraint-violation` to `about:blank`.

Quick cleanup script (run from project root):

```python
import json, glob

files = glob.glob('src/integration-test/resources/**/*.json', recursive=True)
for f in files:
    with open(f) as fh:
        try:
            data = json.load(fh)
        except:
            continue
    if not isinstance(data, dict):
        continue
    changed = False
    # Remove WireMock recording artifacts
    for key in ['persistent', 'insertionIndex']:
        if key in data:
            del data[key]
            changed = True
    # Remove duplicate UUIDs (check if your stubs share a single UUID)
    if 'id' in data and 'uuid' in data and data.get('id') == data.get('uuid'):
        del data['id']
        del data['uuid']
        changed = True
    # Fix constraint violation type
    if data.get('type') == 'https://zalando.github.io/problem/constraint-violation':
        data['type'] = 'about:blank'
        changed = True
    if changed:
        with open(f, 'w') as fh:
            json.dump(data, fh, indent='\t', ensure_ascii=False)
            fh.write('\n')
```

After running the script, run `mvn dept44-formatting:apply` to normalize formatting.

## Steps

1. Check the parent POM version — update to `dept44-service-parent` 8.0.2 if not already done
2. Run `mvn generate-sources` to regenerate OpenAPI models with updated dependencies
3. Search all Java files for the old import patterns and replace them
4. Fix compilation errors from the changes above
5. Clean up WireMock mapping files (see section above)
6. Run `mvn clean verify` to confirm everything passes
