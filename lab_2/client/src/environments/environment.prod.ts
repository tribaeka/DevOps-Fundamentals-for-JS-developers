import { Config } from './config.interface';

export const environment: Config = {
  production: true,
  apiEndpoints: {
    product: 'https:localhost:8080',
    order: 'https:localhost:8080',
    import: 'https:localhost:8080',
    bff: 'https:localhost:8080',
    cart: 'https:localhost:8080',
  },
  apiEndpointsEnabled: {
    product: false,
    order: false,
    import: false,
    bff: false,
    cart: false,
  },
};
