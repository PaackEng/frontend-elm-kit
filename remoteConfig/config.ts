import { RemoteConfig, Type, Value } from './types';

export async function getConfigValue(
  remoteConfig: RemoteConfig,
  key: string,
  type: Type,
): Promise<Value> {
  const remoteValue = remoteConfig.getValue(key);

  switch (type) {
    case 'string':
      return remoteValue.asString();
    case 'number':
      return remoteValue.asNumber();
    case 'boolean':
      return remoteValue.asBoolean();
    case 'object':
      return JSON.parse(remoteValue.asString());
    default:
      return null;
  }
}
