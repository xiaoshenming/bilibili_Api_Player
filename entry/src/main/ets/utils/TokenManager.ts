// entry/src/main/ets/utils/TokenManager.ts

import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

const TOKEN_KEY = 'auth_token';
const PREFERENCES_NAME = 'app_prefs';

class TokenManager {
  private async getPreferences(context: common.UIAbilityContext): Promise<preferences.Preferences> {
    return await preferences.getPreferences(context, PREFERENCES_NAME);
  }

  async saveToken(context: common.UIAbilityContext, token: string): Promise<void> {
    try {
      const prefs = await this.getPreferences(context);
      await prefs.put(TOKEN_KEY, token);
      await prefs.flush();
      console.info('Token saved successfully.');
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to save token. Code:${error.code}, message:${error.message}`);
    }
  }

  async getToken(context: common.UIAbilityContext): Promise<string | null> {
    try {
      const prefs = await this.getPreferences(context);
      const token = await prefs.get(TOKEN_KEY, '');
      return (token as string) || null;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to get token. Code:${error.code}, message:${error.message}`);
      return null;
    }
  }

  async deleteToken(context: common.UIAbilityContext): Promise<void> {
    try {
      const prefs = await this.getPreferences(context);
      await prefs.delete(TOKEN_KEY);
      await prefs.flush();
      console.info('Token deleted successfully.');
    } catch (err) {
      const error = err as BusinessError;
      console.error(`Failed to delete token. Code:${error.code}, message:${error.message}`);
    }
  }
}

export const tokenManager = new TokenManager();