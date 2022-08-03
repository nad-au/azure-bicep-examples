import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return `Hello App3.\nConfig: ${JSON.stringify(process.env, null, 2)}`;
  }
}
