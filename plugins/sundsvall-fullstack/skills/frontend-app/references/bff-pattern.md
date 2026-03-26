# BFF (Backend-For-Frontend) Pattern

Architecture and conventions for the Express backend that proxies between the Next.js frontend and upstream Sundsvall APIs.

## Architecture

```
Browser → Next.js Frontend → Express BFF → Upstream Sundsvall APIs
                              (adds OAuth)
```

The BFF handles:
- OAuth token management (client_credentials flow)
- Request proxying with authorization headers
- Error mapping (upstream 5xx becomes 502 to the frontend)
- CORS, security headers, and logging

## Express App Setup (`app.ts`)

Uses `routing-controllers` for decorator-based routing:

```ts
import { BASE_URL_PREFIX, LOG_FORMAT, NODE_ENV, ORIGIN, PORT } from '@config';
import compression from 'compression';
import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import hpp from 'hpp';
import morgan from 'morgan';
import 'reflect-metadata';
import { useExpressServer } from 'routing-controllers';
import errorMiddleware from './middlewares/error.middleware';
import { stream } from './utils/logger';
import { existsSync, mkdirSync } from 'fs';
import { join } from 'path';

const corsWhitelist = (ORIGIN || '').split(',');

class App {
  public app: express.Application;
  public env: string;
  public port: string | number;

  constructor(Controllers: Function[]) {
    this.app = express();
    this.env = NODE_ENV || 'development';
    this.port = parseInt(PORT || '3000', 10);

    this.initializeDataFolders();
    this.initializeMiddlewares();
    this.initializeRoutes(Controllers);
    this.initializeErrorHandling();
  }

  public listen() {
    this.app.listen(this.port, () => {
      console.log(`App listening on port ${this.port}`);
    });
  }

  private initializeMiddlewares() {
    this.app.use(morgan(LOG_FORMAT || 'dev', { stream }));
    this.app.use(hpp());
    this.app.use(helmet());
    this.app.use(compression());
    this.app.use(express.json());
    this.app.use(express.urlencoded({ extended: true }));
    this.app.use(cors({ /* whitelist logic */ }));
  }

  private initializeRoutes(controllers: Function[]) {
    useExpressServer(this.app, {
      routePrefix: BASE_URL_PREFIX,
      controllers: controllers,
      defaultErrorHandler: false,
    });
  }

  private initializeErrorHandling() {
    this.app.use(errorMiddleware);
  }
}

export default App;
```

Key points:
- Controllers are passed to the constructor and registered via `useExpressServer`
- `routePrefix` comes from `BASE_URL_PREFIX` env var
- `defaultErrorHandler: false` — errors are handled by custom `errorMiddleware`
- Standard middleware stack: morgan, hpp, helmet, compression, cors

## Controller Pattern

Controllers use `routing-controllers` decorators (`@Controller`, `@Get`, `@Post`, `@Param`, `@Body`, `@Res`):

```ts
import { Controller, Get, Post, Param, Body, Res } from 'routing-controllers';
import { Response } from 'express';
import ApiService from '@services/api.service';
import { logger } from '@utils/logger';
import { HttpException } from '@/exceptions/http.exception';

@Controller()
export class DocumentController {
  private apiService = new ApiService();

  @Get('/documents')
  async getDocuments(@Res() response: Response) {
    try {
      const res = await this.apiService.get<{ content: unknown[] }>({
        url: '/documents',
      });

      return response.status(200).json({
        data: res.data.content || [],
        message: 'success',
      });
    } catch (error) {
      logger.error(`Failed to fetch documents: ${error}`);
      throw error instanceof HttpException ? error : new HttpException(500, 'Failed to fetch documents');
    }
  }

  @Get('/documents/:id')
  async getDocument(@Param('id') id: string, @Res() response: Response) {
    try {
      const res = await this.apiService.get<unknown>({
        url: `/documents/${id}`,
      });

      return response.status(200).json({
        data: res.data,
        message: 'success',
      });
    } catch (error) {
      logger.error(`Failed to fetch document ${id}: ${error}`);
      throw error instanceof HttpException ? error : new HttpException(500, 'Failed to fetch document');
    }
  }

  @Post('/documents')
  async createDocument(@Body() body: unknown, @Res() response: Response) {
    try {
      const res = await this.apiService.post<unknown>({
        url: '/documents',
        data: body,
      });

      return response.status(201).json({
        data: res.data,
        message: 'success',
      });
    } catch (error) {
      logger.error(`Failed to create document: ${error}`);
      throw error instanceof HttpException ? error : new HttpException(500, 'Failed to create document');
    }
  }
}
```

Convention:
- Each controller instantiates its own `ApiService`
- All responses follow the `{ data, message }` envelope
- Errors are caught, logged, and re-thrown as `HttpException`
- Use type parameters on `apiService.get<T>()` for upstream response types

## ApiService — Upstream API Calls with OAuth

Central service that handles all upstream API communication with automatic OAuth token injection:

```ts
import { HttpException } from '@/exceptions/http.exception';
import { logger } from '@/utils/logger';
import { apiURL } from '@/utils/util';
import axios, { AxiosError, AxiosRequestConfig } from 'axios';
import ApiTokenService from './api-token.service';
import { v4 as uuidv4 } from 'uuid';

interface ApiResponse<T> {
  data: T;
  message: string;
}

class ApiService {
  private apiTokenService = new ApiTokenService();

  private async request<T>(config: AxiosRequestConfig): Promise<ApiResponse<T>> {
    const token = await this.apiTokenService.getToken();

    const defaultHeaders = {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'X-Request-Id': uuidv4(),
      'X-Sent-By': 'document-app',
    };

    const preparedConfig: AxiosRequestConfig = {
      ...config,
      headers: { ...defaultHeaders, ...config.headers },
      params: { ...config.params },
      url: config.baseURL ? config.url : apiURL(config.url || ''),
      timeout: config.timeout ?? 30000,
    };

    try {
      const res = await axios(preparedConfig);

      if (!res.headers.location) {
        return { data: res.data, message: 'success' };
      }

      // Follow Location header for async operations
      const getRes = await axios.get(res.headers.location, {
        baseURL: config.baseURL,
        headers: defaultHeaders,
      });
      return { data: getRes.data, message: 'success' };
    } catch (error: unknown | AxiosError) {
      if (axios.isAxiosError(error) && error.response?.status) {
        const status = error.response.status;
        // Map upstream 5xx to 502 (Bad Gateway)
        const mappedStatus = status >= 500 ? 502 : status;
        throw new HttpException(mappedStatus, this.getStatusMessage(status));
      }
      throw new HttpException(502, 'Upstream API is unavailable');
    }
  }

  public async get<T>(config: AxiosRequestConfig): Promise<ApiResponse<T>> {
    return this.request<T>({ ...config, method: 'GET' });
  }

  public async post<T>(config: AxiosRequestConfig): Promise<ApiResponse<T>> {
    return this.request<T>({ ...config, method: 'POST' });
  }

  public async put<T>(config: AxiosRequestConfig): Promise<ApiResponse<T>> {
    return this.request<T>({ ...config, method: 'PUT' });
  }

  public async patch<T>(config: AxiosRequestConfig): Promise<ApiResponse<T>> {
    return this.request<T>({ ...config, method: 'PATCH' });
  }

  public async delete<T>(config: AxiosRequestConfig): Promise<ApiResponse<T>> {
    return this.request<T>({ ...config, method: 'DELETE' });
  }
}

export default ApiService;
```

Key behaviors:
- Every request automatically gets a Bearer token from `ApiTokenService`
- Every request gets a unique `X-Request-Id` (UUID v4) for tracing
- Upstream 5xx errors are mapped to 502 to distinguish BFF errors from upstream failures
- Follows `Location` headers for async API operations
- Default 30-second timeout

## ApiTokenService — OAuth Token Management

Manages client_credentials OAuth tokens with in-memory caching:

```ts
import qs from 'qs';
import axios from 'axios';
import { CLIENT_KEY, CLIENT_SECRET } from '@config';
import { HttpException } from '@/exceptions/http.exception';
import { logger } from '@utils/logger';
import { API_BASE_URL } from '@config';

export interface Token {
  access_token: string;
  expires_in: number;
}

// In-memory token cache
let c_access_token = '';
let c_token_expires = 0;

class ApiTokenService {
  public async getToken(): Promise<string> {
    if (Date.now() >= c_token_expires) {
      await this.fetchToken();
    }
    return c_access_token;
  }

  public async setToken(token: Token) {
    c_access_token = token.access_token;
    // Refresh 10 seconds before actual expiry
    c_token_expires = Date.now() + (token.expires_in * 1000 - 10000);
  }

  public async fetchToken(): Promise<string> {
    const authString = Buffer.from(`${CLIENT_KEY}:${CLIENT_SECRET}`, 'utf-8').toString('base64');

    try {
      const { data } = await axios({
        timeout: 30000,
        method: 'POST',
        headers: {
          Authorization: 'Basic ' + authString,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        data: qs.stringify({ grant_type: 'client_credentials' }),
        url: `${API_BASE_URL}/token`,
      });
      const token = data as Token;

      if (!token) throw new HttpException(502, 'Bad Gateway');
      this.setToken(token);

      return this.getToken();
    } catch (error) {
      logger.error(`Failed to fetch JWT access token: ${JSON.stringify(error)}`);
      throw new HttpException(502, 'Bad Gateway');
    }
  }
}

export default ApiTokenService;
```

Key behaviors:
- Uses `client_credentials` OAuth grant type
- Token is cached in module-level variables (shared across requests)
- Refreshes 10 seconds before expiry to avoid race conditions
- `CLIENT_KEY` and `CLIENT_SECRET` come from environment config

## Error Middleware

Catches all unhandled errors and returns a consistent JSON response:

```ts
import { NextFunction, Request, Response } from 'express';
import { HttpException } from '@exceptions/http.exception';
import { logger } from '@utils/logger';

function sanitizeLogInput(input: string): string {
  return input.replace(/[\r\n]/g, '');
}

const mapKnownError = (error: unknown): HttpException => {
  if (error instanceof HttpException) {
    return error;
  }
  return new HttpException(500, 'Something went wrong');
};

const errorMiddleware = (error: unknown, req: Request, res: Response, next: NextFunction) => {
  try {
    const mappedError = mapKnownError(error);
    const status: number = mappedError.status;
    const message: string = mappedError.message;

    const safeMethod = sanitizeLogInput(String(req.method));
    const safePath = sanitizeLogInput(String(req.path));
    const safeMessage = sanitizeLogInput(String(message));

    logger.error(`[${safeMethod}] ${safePath} >> StatusCode:: ${status}, Message:: ${safeMessage}`);
    res.status(status).json({ message });
  } catch (error) {
    next(error);
  }
};

export default errorMiddleware;
```

Note the log sanitization — `\r\n` characters are stripped to prevent log injection attacks.

## HttpException

```ts
import { HttpError } from 'routing-controllers';

export class HttpException extends HttpError {
  public status: number;
  public message: string;

  constructor(status: number, message: string) {
    super(status, message);
    this.status = status;
    this.message = message;
  }
}
```

## Environment Config

```ts
// config/index.ts
import { config } from 'dotenv';

const env = process.env.NODE_ENV || 'development';
const envFiles = [`.env.${env}`, '.env'];

envFiles.forEach((envFile) => {
  if (existsSync(envFile)) {
    config({ path: envFile });
  }
});

export const {
  NODE_ENV,
  PORT,
  API_BASE_URL,
  LOG_FORMAT,
  LOG_DIR,
  ORIGIN,
  CLIENT_KEY,
  CLIENT_SECRET,
  BASE_URL_PREFIX,
  MUNICIPALITY_ID,
  NAMESPACE,
} = process.env;
```

Required environment variables:
- `API_BASE_URL` — upstream API base URL (includes `/token` endpoint)
- `CLIENT_KEY`, `CLIENT_SECRET` — OAuth credentials
- `BASE_URL_PREFIX` — route prefix for all controllers (e.g., `/api`)
- `ORIGIN` — comma-separated CORS whitelist
- `PORT` — server port (default 3000)
- `MUNICIPALITY_ID`, `NAMESPACE` — Sundsvall-specific identifiers

## When to Use

- Creating a new controller: follow the decorator pattern with `@Controller`, `@Get`, etc.
- Adding upstream API calls: use `ApiService`, never call axios directly
- Need a new environment variable: add it to `config/index.ts` exports
- Custom error responses: throw `HttpException` with appropriate status code
