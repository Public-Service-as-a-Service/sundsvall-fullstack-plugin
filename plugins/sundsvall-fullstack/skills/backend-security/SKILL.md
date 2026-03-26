---
description: "OAuth2 and API gateway security patterns for dept44 Spring Boot microservices. Use when configuring resource server security, setting up OAuth2 token flows (client_credentials, authorization_code), integrating with the WSO2 API gateway, configuring FeignMultiCustomizer for OAuth2 service-to-service calls, or troubleshooting 401/403 errors in a dept44 service. Also use when the user asks about authentication, authorization, token management, or API security in the Sundsvall stack."
---

# Backend Security Patterns

Security configuration for dept44 microservices behind the WSO2 API gateway.

## Architecture

```
Client → WSO2 Gateway (validates JWT) → dept44 Service (resource server)
dept44 Service → FeignMultiCustomizer (client_credentials) → Other dept44 Service
```

All public-facing APIs go through WSO2. Service-to-service calls use OAuth2 `client_credentials` flow via Feign.

## Resource Server Configuration

dept44 services are Spring Security resource servers. The parent POM provides the auto-configuration — most services only need `application.yml`:

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${TOKEN_ISSUER_URI:https://wso2.sundsvall.se/oauth2/token}
```

For services that need custom security rules (e.g., public health endpoints):

```java
@Configuration
public class SecurityConfiguration {

  @Bean
  SecurityFilterChain filterChain(final HttpSecurity http) throws Exception {
    http.authorizeHttpRequests(auth -> auth
        .requestMatchers("/api-docs/**", "/actuator/health/**").permitAll()
        .anyRequest().authenticated())
      .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()));
    return http.build();
  }
}
```

## Service-to-Service OAuth2 (Feign)

Use `FeignMultiCustomizer` to add OAuth2 to Feign clients — see `/dept44-source` for the full API. The configuration pattern:

```java
@Import(FeignConfiguration.class)
public class SomeServiceConfiguration {

  @Bean
  FeignMultiCustomizer feignMultiCustomizer(final ClientProperties properties) {
    return FeignMultiCustomizer.create()
      .withRetryableOAuth2InterceptorForClientRegistration(properties.oauth2().registrationId())
      .withErrorDecoder(new ProblemErrorDecoder("SomeService"))
      .withRequestTimeoutsInSeconds(properties.connectTimeout(), properties.readTimeout())
      .composeCustomizersToOne();
  }
}
```

The `application.yml` for the OAuth2 client registration:

```yaml
spring:
  security:
    oauth2:
      client:
        provider:
          some-service:
            token-uri: ${TOKEN_URI:https://wso2.sundsvall.se/oauth2/token}
        registration:
          some-service:
            authorization-grant-type: client_credentials
            client-id: ${SOME_SERVICE_CLIENT_ID}
            client-secret: ${SOME_SERVICE_CLIENT_SECRET}
            provider: some-service
```

## Token Flows

| Flow | When | Configuration |
|------|------|--------------|
| `client_credentials` | Service-to-service calls via Feign | `FeignMultiCustomizer` + `ConfigurationProperties` record |
| JWT validation | Incoming requests through WSO2 gateway | `spring.security.oauth2.resourceserver.jwt.issuer-uri` |

## Common Security Mistakes

- Forgetting `@CircuitBreaker` on OAuth-configured Feign clients — token endpoint failures need circuit breaking too
- Hardcoding client secrets instead of using environment variables (`${SOME_CLIENT_SECRET}`)
- Not adding `/actuator/health/**` to `permitAll()` — breaks Kubernetes health checks
- Using `@EnableWebSecurity` — dept44 parent already configures this

## Verification

1. Run `mvn verify` — security config is tested via AppTests
2. Check that no secrets are hardcoded in `application.yml` (should use `${}` placeholders)
3. Verify health endpoints are accessible without auth: `curl http://localhost:8080/actuator/health`

## When NOT to Use

- Do NOT use for frontend OAuth/token patterns (BFF token management) — use `/frontend-app` bff-pattern reference.
- Do NOT use for general dept44 patterns — use `/dept44-patterns`.

## Improvement Log
<!-- Append entries when this skill causes errors or misses edge cases -->
<!-- Format: YYYY-MM-DD: <what went wrong, what to do differently> -->
