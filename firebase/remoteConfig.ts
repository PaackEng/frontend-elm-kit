import { RemoteConfig, Type, Value } from './types';
import { getValue } from 'firebase/remote-config';

export async function getConfigValue(
  remoteConfig: RemoteConfig,
  key: string,
  type: Type,
): Promise<Value> {
  const remoteValue = getValue(remoteConfig, key);

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
