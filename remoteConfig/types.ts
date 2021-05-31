import firebase from "firebase";

export type RemoteConfig = firebase.remoteConfig.RemoteConfig;

export type Type = 'string' | 'number' | 'boolean' | 'object';

export type Value = string | number | boolean | null;
